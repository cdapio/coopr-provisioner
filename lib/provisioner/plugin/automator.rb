#!/usr/bin/env ruby
# encoding: UTF-8

#
# Copyright © 2012-2015 Cask Data, Inc.
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

require_relative '../logging'
require_relative 'utils'

module Coopr
  module Plugin
    # Base class for all automator plugins.  This should be extended, not modified
    class Automator
      include Coopr::Logging
      include Coopr::Plugin::Utils
      attr_accessor :task, :flavor, :image, :hostname, :providerid, :result
      attr_reader :env
      def initialize(env, task)
        @task = task
        @env = env
        @result = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      end

      def runTask
        sshauth = @task['config']['ssh-auth']
        hostname = @task['config']['hostname']
        ipaddress = @task['config']['ipaddresses']['access_v4']
        fields = begin
                   @task['config']['service']['action']['fields']
                 rescue
                   nil
                 end

        verify_ssh_host_key(ipaddress, 'rsa')

        case task['taskName'].downcase
        when 'bootstrap'
          bootstrap('hostname' => hostname, 'ipaddress' => ipaddress, 'sshauth' => sshauth)
          return @result
        when 'install'
          install('hostname' => hostname, 'ipaddress' => ipaddress, 'sshauth' => sshauth, 'fields' => fields)
          return @result
        when 'configure'
          configure('hostname' => hostname, 'ipaddress' => ipaddress, 'sshauth' => sshauth, 'fields' => fields)
          return @result
        when 'initialize'
          init('hostname' => hostname, 'ipaddress' => ipaddress, 'sshauth' => sshauth, 'fields' => fields)
          return @result
        when 'start'
          start('hostname' => hostname, 'ipaddress' => ipaddress, 'sshauth' => sshauth, 'fields' => fields)
          return @result
        when 'stop'
          stop('hostname' => hostname, 'ipaddress' => ipaddress, 'sshauth' => sshauth, 'fields' => fields)
          return @result
        when 'remove'
          remove('hostname' => hostname, 'ipaddress' => ipaddress, 'sshauth' => sshauth, 'fields' => fields)
          return @result
        else
          raise "unhandled automator task type: #{task['taskName']}"
        end
      end

      def verify_ssh_host_key(host, type = 'rsa')
        log.debug "Verifying SSH host key for #{@task['config']['hostname']}/#{host}"
        if @task['config'].key?('ssh_host_keys') && @task['config']['ssh_host_keys'].key?(type)
          message = "SSH host key verification failed for #{@task['config']['hostname']}/#{host}"
          raise message unless @task['config']['ssh_host_keys'][type] == ssh_keyscan(host, type)
        else
          message = "SSH Host key not stored for #{@task['config']['hostname']}... Skipping verification"
          log.warn message
        end
      end

      def bootstrap(_inputmap)
        @result['status'] = 1
        @result['message'] = "Unimplemented task bootstrap in class #{self.class.name}"
        raise "Unimplemented task bootstrap in class #{self.class.name}"
      end

      def install(_inputmap)
        @result['status'] = 1
        @result['message'] = "Unimplemented task install in class #{self.class.name}"
        raise "Unimplemented task install in class #{self.class.name}"
      end

      def configure(_inputmap)
        @result['status'] = 1
        @result['message'] = "Unimplemented task configure in class #{self.class.name}"
        raise "Unimplemented task configure in class #{self.class.name}"
      end

      def init(_inputmap)
        @result['status'] = 1
        @result['message'] = "Unimplemented task initialize in class #{self.class.name}"
        raise "Unimplemented task initialize in class #{self.class.name}"
      end

      def start(_inputmap)
        @result['status'] = 1
        @result['message'] = "Unimplemented task start in class #{self.class.name}"
        raise "Unimplemented task start in class #{self.class.name}"
      end

      def stop(_inputmap)
        @result['status'] = 1
        @result['message'] = "Unimplemented task stop in class #{self.class.name}"
        raise "Unimplemented task stop in class #{self.class.name}"
      end

      def remove(_inputmap)
        @result['status'] = 1
        @result['message'] = "Unimplemented task remove in class #{self.class.name}"
        raise "Unimplemented task remove in class #{self.class.name}"
      end
    end
  end
end
