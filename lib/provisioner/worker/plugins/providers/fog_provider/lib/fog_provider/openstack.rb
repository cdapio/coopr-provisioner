#!/usr/bin/env ruby
# encoding: UTF-8
#
# Copyright © 2012-2016 Cask Data, Inc.
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

class FogProviderOpenstack < Coopr::Plugin::Provider
  include FogProvider

  # plugin defined resources
  @ssh_key_dir = 'ssh_keys'
  @user_data_dir = 'user_data'
  class << self
    attr_accessor :ssh_key_dir, :user_data_dir
  end

  def create(inputmap)
    flavor = inputmap['flavor']
    image = inputmap['image']
    hostname = inputmap['hostname']
    fields = inputmap['fields']
    begin
      # Our fields are fog symbols
      fields.each do |k, v|
        instance_variable_set('@' + k, v)
      end
      # Create the server
      log.debug "Creating #{hostname} on Openstack using flavor: #{flavor}, image: #{image}"
      log.debug 'Invoking server create'
      create_options = {
        flavor_ref: flavor,
        image_ref: image,
        name: hostname,
        security_groups: @security_groups,
        key_name: @ssh_keypair
      }

      create_options[:user_data] = open(File.join(Dir.pwd, self.class.user_data_dir, @user_data_resource), &:read) if @user_data_resource
      create_options[:nics] = @network_ids.split(',').map { |nic| { 'net_id' => nic.strip } } if @network_ids

      server = connection.servers.create(create_options)

      # Process results
      @result['result']['providerid'] = server.id.to_s
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
      log.error('Unexpected Error Occurred in FogProviderOpenstack.create: ' + e.inspect)
      @result['stderr'] = "Unexpected Error Occurred in FogProviderOpenstack.create: #{e.inspect}"
    else
      log.debug "Create finished successfully: #{@result}"
    ensure
      @result['status'] = 1 if @result['status'].nil? || (@result['status'].is_a?(Hash) && @result['status'].empty?)
    end
  end

  def confirm(inputmap)
    providerid = inputmap['providerid']
    fields = inputmap['fields']
    begin
      # Our fields are fog symbols
      fields.each do |k, v|
        instance_variable_set('@' + k, v)
      end
      # Confirm server
      log.debug "Invoking server confirm for id: #{providerid}"
      server = connection.servers.get(providerid)
      # Wait until the server is ready
      raise "Server #{server.name} is in ERROR state" if server.state == 'ERROR'
      log.debug "waiting for server to come up: #{providerid}"
      server.wait_for(600) { ready? }

      # associate public ip if requested
      if @floating_ip
        addresses = connection.addresses
        free_floating = addresses.find_index { |a| a.fixed_ip.nil? }
        raise 'No available floating IP found' if free_floating.nil?
        floating_address = addresses[free_floating].ip
        server.associate_address(floating_address)
        # a bit of a hack, but server.reload takes a long time
        (server.addresses['public'] ||= []) << { 'version' => 4, 'addr' => floating_address }
      end

      bootstrap_ip =
        primary_public_ip_address(server.addresses) ||
        primary_private_ip_address(server.addresses) ||
        server.addresses.first[1][0]['addr']
      if bootstrap_ip.nil?
        log.error 'No IP address available for bootstrapping.'
        raise 'No IP address available for bootstrapping.'
      else
        log.debug "Bootstrap IP address #{bootstrap_ip}"
      end

      wait_for_sshd(bootstrap_ip, 22)
      log.debug "Server #{server.name} sshd is up"

      bind_ip = primary_private_ip_address(server.addresses) || bootstrap_ip

      # Process results
      @result['ipaddresses'] = {
        'access_v4' => bootstrap_ip,
        'bind_v4' => bind_ip
      }
      @result['result']['ssh_host_keys'] = {
        'rsa' => ssh_keyscan(bootstrap_ip)
      }
      # do we need sudo bash?
      sudo = 'sudo -E' unless @task['config']['ssh-auth']['user'] == 'root'
      set_credentials(@task['config']['ssh-auth'])

      # login with pseudotty and turn off sudo requiretty option
      log.debug "Attempting to ssh to #{bootstrap_ip} as #{@task['config']['ssh-auth']['user']} with credentials: #{@credentials} and pseudotty"
      Net::SSH.start(bootstrap_ip, @task['config']['ssh-auth']['user'], @credentials) do |ssh|
        sudoers = true
        begin
          ssh_exec!(ssh, 'test -e /etc/sudoers', 'Checking for /etc/sudoers')
        rescue CommandExecutionError
          log.debug 'No /etc/sudoers file present'
          sudoers = false
        end
        cmd = "#{sudo} sed -i -e '/^Defaults[[:space:]]*requiretty/ s/^/#/' /etc/sudoers"
        ssh_exec!(ssh, cmd, 'Disabling requiretty via pseudotty session', true) if sudoers
      end

      # Validate connectivity
      Net::SSH.start(bootstrap_ip, @task['config']['ssh-auth']['user'], @credentials) do |ssh|
        ssh_exec!(ssh, 'ping -c1 www.google.com', 'Validating external connectivity and DNS resolution via ping')
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
      log.error('Unexpected Error Occurred in FogProviderOpenstack.confirm: ' + e.inspect)
      @result['stderr'] = "Unexpected Error Occurred in FogProviderOpenstack.confirm: #{e.inspect}"
    else
      log.debug "Confirm finished successfully: #{@result}"
    ensure
      @result['status'] = 1 if @result['status'].nil? || (@result['status'].is_a?(Hash) && @result['status'].empty?)
    end
  end

  def delete(inputmap)
    providerid = inputmap['providerid']
    fields = inputmap['fields']
    begin
      # Our fields are fog symbols
      fields.each do |k, v|
        instance_variable_set('@' + k, v)
      end
      # Delete server
      log.debug 'Invoking server delete'
      begin
        raise ArgumentError if providerid.nil? || providerid.empty?
        server = connection.servers.get(providerid)
        server.destroy
      rescue ArgumentError
        log.debug "Invalid provider id #{providerid} specified on delete... skipping"
      rescue NoMethodError
        log.warn "Could not locate server '#{providerid}'... skipping"
      end
      # Return 0
      @result['status'] = 0
    rescue => e
      log.error('Unexpected Error Occurred in FogProviderOpenstack.delete: ' + e.inspect)
      @result['stderr'] = "Unexpected Error Occurred in FogProviderOpenstack.delete: #{e.inspect}"
    else
      log.debug "Delete finished sucessfully: #{@result}"
    ensure
      @result['status'] = 1 if @result['status'].nil? || (@result['status'].is_a?(Hash) && @result['status'].empty?)
    end
  end

  # Shared definitions (borrowed from knife-openstack gem, Apache 2.0 license)

  def connection
    # Create connection
    @connection ||= begin
      Fog::Compute.new(
        provider: 'OpenStack',
        openstack_auth_url: @openstack_auth_url,
        openstack_username: @api_user,
        openstack_tenant: @openstack_tenant,
        openstack_api_key: @api_password,
        connection_options: {
          ssl_verify_peer: @openstack_ssl_verify_peer
        }
      )
    end
  end

  def connection_network
    # Create connection to Network service
    @connection_network ||= begin
      Fog::Network.new(
        provider: 'OpenStack',
        openstack_auth_url: @openstack_auth_url,
        openstack_username: @api_user,
        openstack_tenant: @openstack_tenant,
        openstack_api_key: @api_password,
        connection_options: {
          ssl_verify_peer: @openstack_ssl_verify_peer
        }
      )
    end
  end

  def network_names
    # returns an array of the network names corresponding to the current @network_ids
    @network_names ||= begin
      network_names = []

      all_networks = connection_network.networks
      if all_networks
        @network_ids.split(',').each do |id|
          found_network = all_networks.find { |n| n.id == id }
          network_names.push(found_network.name) if found_network.name
        end
      end
      network_names
    end
  end

  def ip_address(server, network = 'public')
    network_ips = server.addresses[network]
    extract_ipv4_address(network_ips) if network_ips
  end

  def extract_ipv4_address(ip_addresses)
    address = ip_addresses.find { |ip| ip['version'] == 4 }
    address ? address['addr'] : ''
  end

  def primary_private_ip_address(addresses)
    # OS-EXT-IP metadata extension strongly recommended
    # First determine list of network names to consider
    # Historically 'private' was assumed.
    # Instead, search through any specified @network_ids in order, and return the first address of type 'fixed'
    # Fall back to 'private' as before
    names = network_names
    names.push('private')

    names.each do |name|
      next unless addresses[name]
      addresses[name].reverse_each do |addr|
        return addr['addr'] if addr['OS-EXT-IPS:type'] == 'fixed'
      end
    end

    # Fall back default
    return addresses['private'].last['addr'] if addresses['private']
  end

  def attached_floating_ip_address(addresses)
    # requires OS-EXT-IP extension metadata
    names = network_names
    names.push('private')

    names.each do |name|
      next unless addresses[name]
      addresses[name].reverse_each do |addr|
        return addr['addr'] if addr['OS-EXT-IPS:type'] == 'floating'
      end
    end
  end

  def primary_public_ip_address(addresses)
    # OS-EXT-IP metadata extension strongly recommended
    # Historically 'public' was assumed.
    # Instead, search through any specified @network_ids in order, and return the first address of type 'floating'
    # Fall back to 'public' as before

    # Assume floating ip is public
    floating_ip = attached_floating_ip_address(addresses)
    return floating_ip if floating_ip

    # Fall back to default behavior
    return addresses['public'].last['addr'] if addresses['public']
  end
end
