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

# shared logging module

require 'logger'

module Coopr
  module Logging
    attr_accessor :level
    @level = ::Logger::INFO
    @shift_age = nil
    @shift_size = nil
    @process_name = '-'
    @out = nil
    def log
      Coopr::Logging.log
    end

    def self.configure(out)
      @out = out if out != 'STDOUT'
    end

    def self.level=(level)
      @level = case level
               when /debug/i
                 ::Logger::DEBUG
               when /info/i
                 ::Logger::INFO
               when /warn/i
                 ::Logger::WARN
               when /error/i
                 ::Logger::ERROR
               when /fatal/i
                 ::Logger::FATAL
               else
                 ::Logger::INFO
               end
    end

    def self.shift_age=(shift_age)
      @shift_age = shift_age
    end

    def self.shift_size=(shift_size)
      @shift_size = shift_size
    end

    def self.process_name=(process_name)
      @process_name = process_name
    end

    def self.log
      unless @logger
        @logger = if @out
                    ::Logger.new(@out, @shift_age.to_i, @shift_size.to_i)
                  else
                    ::Logger.new(STDOUT)
                  end
        @logger.level = @level
        @logger.formatter = proc do |severity, datetime, _progname, msg|
          "#{datetime} #{@process_name} #{severity}: #{msg}\n"
        end
      end
      @logger
    end
  end
end
