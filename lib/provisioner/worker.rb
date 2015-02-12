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

require 'json'
require 'optparse'
require 'rest_client'
require 'socket'
require 'logger'
require 'fileutils'

require_relative 'worker/signalhandler'
require_relative 'worker/pluginmanager'
require_relative 'plugin/provider'
require_relative 'plugin/automator'
require_relative 'worker/cli'
require_relative 'rest-helper'

require_relative 'config'
require_relative 'logging'
require_relative 'constants'

$stdout.sync = true

module Coopr
  class Worker
    include Coopr::Logging

    # Passed in options and configuration
    attr_reader :options, :config

    # Options that must be passed (cmdline) or set (by master)
    attr_accessor :tenant, :file, :provisioner_id, :name, :register, :once

    def initialize(options, config)
      @options = options
      @config = config
      pid = Process.pid
      host = Socket.gethostname.downcase
      @worker_id = "#{host}.#{pid}"

      # Set logging process name field
      Logging.process_name = @worker_id

      # Logging module is already configured via the master provisioner or self.run
      # TODO: reimplement functionality to log each worker to a different file
      #   if (new config option)
      #     Logging.configure(config.get(PROVISIONER_LOG_DIR) ? "#{config.get(PROVISIONER_LOG_DIR)}/#{@name}" : nil)
      #   end

      # Log configuration
      log.debug 'Worker is starting up with configuration:'
      config.properties.each do |k, v|
        log.debug "  #{k}: #{v}"
      end

      # Process options, only in case of cmdline startup
      log.debug 'Cmdline options' unless options.empty?
      options.each do |k, v|
        instance_variable_set("@#{k}", v)
        log.debug "  #{k}: #{v}"
      end

      # Initialize PluginManager
      @pluginmanager = Coopr::Worker::PluginManager.new

      # TODO: re-evaluate if this is needed as it appears to only be used by shell automator
      # Env passed to all plugins
      # TODO: this generates a mixture of strings and symbols (only symbols used currently)
      @plugin_env = @config.properties.merge(@options)
      # TODO: plugins refer to the prior cmdline option names, should use constants instead
      @plugin_env[:work_dir] = @config.get(PROVISIONER_WORK_DIR)

      # Run validation checks
      validate

      log.debug "Worker initialized with providertypes: #{@pluginmanager.providermap.keys}"
      log.debug "Worker initialized with automatortypes: #{@pluginmanager.automatormap.keys}"
    end

    def validate
      if @pluginmanager.providermap.empty? or @pluginmanager.automatormap.empty?
        log.fatal 'Error: at least one provider plugin and one automator plugin must be installed'
        exit(1)
      end
    end

    # Cmdline entry point
    def self.run(options)
      # Read configuration xml
      config = Coopr::Config.new(options)
      config.load
      # Initialize logging
      Coopr::Logging.configure(config.get(PROVISIONER_LOG_DIR) ? "#{config.get(PROVISIONER_LOG_DIR)}/provisioner.log" : nil)
      Coopr::Logging.level = config.get(PROVISIONER_LOG_LEVEL)
      Coopr::Logging.shift_age = config.get(PROVISIONER_LOG_ROTATION_SHIFT_AGE)
      Coopr::Logging.shift_size = config.get(PROVISIONER_LOG_ROTATION_SHIFT_SIZE)

      # If run from command line, validate required options
      unless options[:tenant] || options[:register]
        puts 'Either --tenant or --register options must be specified'
        exit(1)
      end

      worker = Coopr::Worker.new(options, config)
      if options[:register]
        worker.register_plugins
      elsif options[:file]
        worker.run_task_from_file
      else
        worker.work
      end
    end

    # Register plugins with the server
    def register_plugins
      @pluginmanager.register_plugins(@config.get(PROVISIONER_SERVER_URI))
      if @pluginmanager.load_errors?
        log.error 'There was at least one provisioner plugin load failure'
        exit(1)
      end
      if @pluginmanager.register_errors?
        log.error 'There was at least one provisioner plugin register failure'
        exit(1)
      end
      exit(0)
    end

    # Instantiate and run an instance of given plugin for a task
    def _run_plugin(clazz, env, cwd, task)
      clusterId = task['clusterId']
      hostname = task['config']['hostname']
      provider = task['config']['provider']['description']
      imagetype = task['config']['imagetype']
      hardware = task['config']['hardwaretype']
      taskName = task['taskName'].downcase
      log.info "Creating node #{hostname} on #{provider} for #{clusterId} using #{imagetype} on #{hardware}" if taskName == 'create'

      object = clazz.new(env, task)
      FileUtils.mkdir_p(cwd)
      Dir.chdir(cwd) do
        result = object.runTask
        log.info "#{clusterId} on #{hostname} could not be deleted: #{result['message']}" if taskName == 'delete' && result['status'] != 0
        result
      end
    end

    def delegate_task(task)
      providerName = nil # rubocop:disable UselessAssignment
      automatorName = nil # rubocop:disable UselessAssignment
      clazz = nil # rubocop:disable UselessAssignment
      object = nil
      result = nil
      classes = nil
      task_id = task['taskId']

      log.debug "Processing task with id #{task_id} ..."

      taskName = task['taskName'].downcase
      # depending on task, these may be nil
      # automator take pecedence as presence indicates a 'software' task
      providerName = task['config']['provider']['providertype'] rescue nil
      automatorName = task['config']['service']['action']['type'] rescue nil

      case taskName
      when 'create', 'confirm', 'delete'
        clazz = Object.const_get(@pluginmanager.getHandlerActionObjectForProvider(providerName))
        cwd = File.join(@config.get(PROVISIONER_WORK_DIR), @tenant, 'providertypes', providerName)
        result = _run_plugin(clazz, @plugin_env, cwd, task)
      when 'install', 'configure', 'initialize', 'start', 'stop', 'remove'
        clazz = Object.const_get(@pluginmanager.getHandlerActionObjectForAutomator(automatorName))
        cwd = File.join(@config.get(PROVISIONER_WORK_DIR), @tenant, 'automatortypes', automatorName)
        result = _run_plugin(clazz, @plugin_env, cwd, task)
      when 'bootstrap'
        combinedresult = {}
        classes = []
        if task['config'].key?('automators') and !task['config']['automators'].empty?
          # server must specify which bootstrap handlers need to run
          log.debug "Task #{task_id} running specified bootstrap handlers: #{task['config']['automators']}"
          task['config']['automators'].each do |automator|
            clazz = Object.const_get(@pluginmanager.getHandlerActionObjectForAutomator(automator))
            cwd = File.join(@config.get(PROVISIONER_WORK_DIR), @tenant, 'automatortypes', automator)
            result = _run_plugin(clazz, @plugin_env, cwd, task)
            combinedresult.merge!(result)
          end
        else
          log.warn 'No automators specified to bootstrap'
        end
        result = combinedresult
      else
        log.error "Unhandled task of type #{task['taskName']}"
        fail "Unhandled task of type #{task['taskName']}"
      end
      result
    end

    # Run a single task read from file
    def run_task_from_file
      begin
        result = nil
        task = nil
        log.info "Start Worker run for file #{@file}"
        task = JSON.parse(IO.read(@file))

        # While provisioning, don't allow the provisioner to terminate by disabling signal
        sigterm = Coopr::Worker::SignalHandler.new('TERM')
        sigterm.dont_interupt {
          result = delegate_task(task)
        }
      rescue => e
        log.error "Caught exception when running task from file #{@file}"

        result = {} if result.nil? == true
        result['status'] = '1'
        # Check if it's an ssh_exec exception for additional logging info
        if e.class.name == 'CommandExecutionError'
          log.error "#{e.class.name}: #{e.to_json}"
          result['stdout'] = e.stdout
          result['stderr'] = e.stderr
        else
          result['stdout'] = e.inspect
          result['stderr'] = "#{e.inspect}\n#{e.backtrace.join("\n")}"
        end
        log.error "Worker run failed, result: #{result}"
      end
    end

    # Poll Coopr Server for a task, retries until it gets some response
    def _poll_server
      server_uri = @config.get(PROVISIONER_SERVER_URI)
      poll_error_interval = @config.get(PROVISIONER_WORKER_POLL_ERROR_INTERVAL).to_i || 10
      postdata = { 'provisionerId' => @provisioner_id, 'workerId' => @worker_id, 'tenantId' => @tenant }.to_json
      loop {
        begin
          response = Coopr::RestHelper.post "#{server_uri}/v2/tasks/take", postdata
          break response
        rescue => e
          log.error "Unable to connect to Coopr Server #{server_uri}/v2/tasks/take: #{e}"
          sleep poll_error_interval
        end
      }
    end

    # Poll Coopr Server for a task, retries until a task is successfully retrieved
    def _poll_server_and_retrieve_task
      poll_interval = @config.get(PROVISIONER_WORKER_POLL_INTERVAL).to_i || 1
      poll_error_interval = @config.get(PROVISIONER_WORKER_POLL_ERROR_INTERVAL).to_i || 10
      loop {
        begin
          response = _poll_server
          if response.code == 200 && response.to_str && response.to_str != ''
            task = JSON.parse(response.to_str)
            break task
          elsif response.code == 204
            sleep poll_interval
            next
          else
            log.error "Received error code #{response.code} from coopr server: #{response.to_str}"
          end
        rescue => e
          log.error "Caught exception processing response from coopr server: #{e.inspect}"
        end
        sleep poll_error_interval
      }
    end

    # Run in continuous server polling mode
    def work
      poll_interval = @config.get(PROVISIONER_WORKER_POLL_INTERVAL).to_i || 1
      poll_error_interval = @config.get(PROVISIONER_WORKER_POLL_ERROR_INTERVAL).to_i || 10
      server_uri = @config.get(PROVISIONER_SERVER_URI)

      $PROGRAM_NAME = "#{$PROGRAM_NAME} (tenant: #{@tenant}, provisioner: #{@provisioner_id}, worker: #{@name})"

      log.info "Starting worker with id #{@worker_id}, connecting to server #{@config.get(PROVISIONER_SERVER_URI)}"

      loop {
        result = nil

        # Poll Coopr Server until a task is retrieved
        task = _poll_server_and_retrieve_task

        # While running task, trap and queue TERM signal to prevent shutdown until task is complete
        sigterm = Coopr::Worker::SignalHandler.new('TERM')
        sigterm.dont_interupt {
          begin
            result = delegate_task(task)

            result = Hash.new if result.nil? == true
            result['workerId'] = @worker_id
            result['taskId'] = task['taskId']
            result['provisionerId'] = @provisioner_id
            result['tenantId'] = @tenant

            log.debug "Task <#{task['taskId']}> completed, updating results <#{result}>"
            begin
              response = Coopr::RestHelper.post "#{server_uri}/v2/tasks/finish", result.to_json
            rescue => e
              log.error "Caught exception posting back to coopr server #{server_uri}/v2/tasks/finish: #{e}"
            end

          rescue => e
            result = Hash.new if result.nil? == true
            result['status'] = '1'
            result['workerId'] = @worker_id
            result['taskId'] = task['taskId']
            result['provisionerId'] = @provisioner_id
            result['tenantId'] = @tenant
            if e.class.name == 'CommandExecutionError'
              log.error "#{e.class.name}: #{e.to_json}"
              result['stdout'] = e.stdout
              result['stderr'] = e.stderr
            else
              result['stdout'] = e.inspect
              result['stderr'] = "#{e.inspect}\n#{e.backtrace.join("\n")}"
            end
            log.error "Task <#{task['taskId']}> failed, updating results <#{result}>"
            begin
              response = Coopr::RestHelper.post "#{server_uri}/v2/tasks/finish", result.to_json
            rescue => e
              log.error "Caught exception posting back to server #{server_uri}/v2/tasks/finish: #{e}"
            end
          end
        }

        break if @once
        sleep 5
      }
    end
  end
end
