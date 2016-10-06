#!/usr/bin/env ruby
# encoding: UTF-8
#
# Copyright © 2015-2016 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative 'utils'
require 'azure'
require 'azure/core'
require 'fog/azure'

class FogProviderAzure < Coopr::Plugin::Provider
  include FogProvider

  # plugin defined resources
  @ssh_key_dir = 'ssh_keys'
  @cert_dir = 'certificates'
  @mgmt_cert_dir = 'management'

  class << self
    attr_accessor :ssh_key_dir, :cert_dir, :mgmt_cert_dir
  end

  # FOO

  def create(inputmap)
    ########################################################################
    # Note: successful creates return the following output: (instead of nothing)
    #     Creating deployment...
    #     Cloud service [...] already exists. Skipped...
    #     Storage Account [...] already exists. Skipped...
    #     Deployment in progress...
    #     # # # # # # # # # # succeeded (200)
    ########################################################################
    @flavor = inputmap['flavor']
    @image = inputmap['image']
    @hostname = inputmap['hostname']
    fields = inputmap['fields']
    begin
      # Our fields are fog symbols
      fields.each do |k, v|
        instance_variable_set('@' + k, v)
      end

      region =
        if @azure_region
           @azure_region
        else
          'East US'
        end

      # Microsoft Azure does not like 'vm_name's with .local in them (mostlikely because of the '.')
      # Note: while vm_name will look like blah19-1000-local, deploy_name will still just be blah (original host name used in Coopr)
      # Create the server
      @providerid = @hostname.split('.').first
      log.debug "Creating #{hostname} on Azure using flavor: #{flavor}, image: #{image}"
      begin
        server = connection.servers.create(
          image: @image,
          vm_name: @providerid,
          vm_size: @flavor,
          location: region,
          vm_user: @vm_user,
          cloud_service_name: @cloud_service_name,
          storage_account_name: @storage_account_name,
          availability_set_name: @availability_set_name,
          password: @vm_password,
          private_key_file: File.join(self.class.ssh_key_dir, @ssh_key_resource),
          certificate_file: File.join(self.class.cert_dir, @certificate_resource)
        )
      end
      # Process results
      @result['result']['providerid'] = @providerid
      @result['result']['ssh-auth']['user'] = @task['config']['sshuser'] || 'root'
      @result['result']['ssh-auth']['password'] = server.password unless server.password.nil?
      @result['result']['ssh-auth']['identityfile'] = File.join(Dir.pwd, self.class.ssh_key_dir, @ssh_key_resource) unless @ssh_key_resource.nil?
      @result['status'] = 0
    rescue Excon::Errors::Unauthorized
      msg = 'Provider credentials invalid/unauthorized'
      @result['status'] = 201
      @result['stderr'] = msg
      log.error(msg)
    rescue => e
      log.error('Unexpected Error Occurred in FogProviderAzure.create: ' + e.inspect)
      @result['stderr'] = "Unexpected Error Occurred in FogProviderAzure.create: #{e.inspect}"
    else
      log.debug "Create finished successfully: #{@result}"
    ensure
      @result['status'] = 1 if @result['status'].nil? || (@result['status'].is_a?(Hash) && @result['status'].empty?)
    end
  end

  def confirm(inputmap)
    providerid = inputmap['providerid']
    log.debug "confirm: providerid=#{providerid}" # fqdn
    fields = inputmap['fields']
    begin
      # Our fields are fog symbols
      fields.each do |k, v|
        #log.debug "k=#{k}, v=#{v}"
        log.debug "#{k}=#{v}"
        instance_variable_set('@' + k, v)
      end
      # Confirm server
      log.debug "Invoking server confirm for id: #{providerid}"
      server = connection.servers.get(providerid, @cloud_service_name)
      # Wait until the server is ready
      # fail "Server #{server.vm_name} is in ERROR state" if server.state == 'ERROR'
      log.debug "waiting for server to come up: #{providerid}"
      server.wait_for { sshable? } unless server.private_key_file.nil?
      log.debug 'proceeding'

      bootstrap_ip =
      if server.ipaddress
        log.debug "server.ipaddress is good: #{server.ipaddress}"
        server.ipaddress
      else
        fail 'No IP address available for bootstrapping.'
      end
      wait_for_sshd(bootstrap_ip, 22)
      log.debug "Server #{server.vm_name} sshd is up"

      # Process results
      @result['ipaddresses'] = {
        'access_v4' => bootstrap_ip,
        'bind_v4' => bootstrap_ip
      }
      @result['result']['ssh_host_keys'] = {
        'rsa' => ssh_keyscan(bootstrap_ip)
      }
      # do we need sudo bash?
      sudo = 'sudo' unless @task['config']['ssh-auth']['user'] == 'root'
      set_credentials(@task['config']['ssh-auth'])

      # login with pseudotty and turn off sudo requiretty option
      #log.debug "Attempting to ssh to #{bootstrap_ip} as #{@task['config']['ssh-auth']['user']} with credentials: #{@credentials} and pseudotty"
      log.debug "Attempting to ssh to #{bootstrap_ip} as #{@vm_user} with credentials: #{@credentials} and pseudotty"
      ###stty_cmd = "stty cbreak -echo <&2"
      ###exec( stty_cmd )
      #Net::SSH.start(bootstrap_ip, @task['config']['ssh-auth']['user'], @credentials) do |ssh|
      Net::SSH.start(bootstrap_ip, @vm_user, @credentials) do |ssh|
        sudoers = true
        begin
          ssh_exec!(ssh, 'test -e /etc/sudoers', 'Checking for /etc/sudoers')
        rescue CommandExecutionError
          log.debug 'No /etc/sudoers file present'
          sudoers = false
        end
        cmd = "#{sudo} sed -i -e '/^Defaults[[:space:]]*requiretty/ s/^/#/' /etc/sudoers"
        ssh_exec!(ssh, cmd, 'Disabling requiretty via pseudotty session', false) if sudoers
      end

      # Validate connectivity and Mount data disk
      #Net::SSH.start(bootstrap_ip, @task['config']['ssh-auth']['user'], @credentials) do |ssh|
      Net::SSH.start(bootstrap_ip, @vm_user, @credentials) do |ssh|
        begin
          ssh_exec!(ssh, 'ping -c1 www.opscode.com', 'Validating external connectivity and DNS resolution via ping')
	rescue
	  log.debug 'unable to validate external connectivity and DNS resolution via ping'
	end
	begin
          ssh_exec!(ssh, "#{sudo} sed -i -e 's:/mnt:/data:' /etc/fstab", 'Updating /etc/fstab for /data')
          ssh_exec!(ssh, "test -e /dev/sdb1 && (#{sudo} mkdir -p /data && #{sudo} mount --bind /mnt /data) || true", 'Create /data and bind mount point from /mnt')
	rescue
	  log.debug 'unable to create /data or mount it'
	end
      end
      # Return 0
      @result['status'] = 0
    rescue Fog::Errors::TimeoutError
      log.error 'Timeout waiting for the server to be created'
      @result['stderr'] = 'Timed out waiting for server to be created'
    rescue Net::SSH::AuthenticationFailed => e
      log.error("SSH Authentication failure for #{providerid}/#{bootstrap_ip}")
      @result['stderr'] = "SSH Authentication failure for #{providerid}/#{bootstrap_ip}: #{e.inspect}"
    rescue => e
      log.error('Unexpected Error Occurred in FogProviderAzure.confirm: ' + e.inspect)
      @result['stderr'] = "Unexpected Error Occurred in FogProviderAzure.confirm: #{e.inspect}"
    else
      log.debug "Confirm finished successfully: #{@result}"
    ensure
      @result['status'] = 1 if @result['status'].nil? || (@result['status'].is_a?(Hash) && @result['status'].empty?)
    end
  end

  def delete(inputmap)
    log.debug 'starting delete'
    providerid = inputmap['providerid']
    log.debug "providerid=#{providerid}"
    fields = inputmap['fields']
    begin
      # Our fields are fog symbols
      fields.each do |k, v|
        instance_variable_set('@' + k, v)
      end
      # Delete server
      log.debug 'Invoking server delete'
      begin
        fail ArgumentError if providerid.nil? || providerid.empty?
        server = connection.servers.get(providerid, @cloud_service_name)
        server.destroy
      rescue ArgumentError
        log.debug "Invalid provider id #{providerid} specified on delete... skipping"
      rescue NoMethodError
        log.warn "Could not locate server '#{providerid}'... skipping"
      end
      # Return 0
      @result['status'] = 0
    rescue => e
      log.error('Unexpected Error Occurred in FogProviderAzure.delete: ' + e.inspect)
      @result['stderr'] = "Unexpected Error Occurred in FogProviderAzure.delete: #{e.inspect}"
    else
      log.debug "Delete finished sucessfully: #{@result}"
    ensure
      @result['status'] = 1 if @result['status'].nil? || (@result['status'].is_a?(Hash) && @result['status'].empty?)
    end
  end

  def connection
    # Create connection
    # rubocop:disable UselessAssignment
    @connection ||= begin
      connection = Fog::Compute.new(
        provider: 'Azure',
        azure_sub_id: @azure_subscription_id,
        azure_pem: File.join(self.class.mgmt_cert_dir, @mgmt_cert_resource),
        azure_api_url: @azure_api_url
      )
    end
    # rubocop:enable UselessAssignment
  end
end
