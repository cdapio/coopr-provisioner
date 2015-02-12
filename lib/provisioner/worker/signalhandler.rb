#!/usr/bin/env ruby
# encoding: UTF-8
#
# Copyright © 2012-2014 Cask Data, Inc.
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

require 'net/scp'

require_relative '../logging'

module Coopr
  class Worker
    class SignalHandler
      include Coopr::Logging
      def initialize(signal)
        @interuptable = false
        @enqueued     = []
        Signal.trap(signal) do
          if @interuptable
            log.info 'Gracefully shut down worker...'
            exit 0
          else
            @enqueued.push(signal)
          end
        end
      end

      # If this is called with a block then the block will be run with
      # the signal temporarily ignored. Without the block, we'll just set
      # the flag and the caller can call `allow_interuptions` themselves.
      def dont_interupt
        @interuptable = false
        @enqueued     = []
        # rubocop:disable GuardClause
        if block_given?
          yield
          allow_interuptions
        end
        # rubocop:enable GuardClause
      end

      def allow_interuptions
        @interuptable = true
        # Send the temporarily ignored signals to ourself
        # see http://www.ruby-doc.org/core/classes/Process.html#M001286
        @enqueued.each { |signal| Process.kill(signal, Process.pid) }
      end
    end
  end
end
