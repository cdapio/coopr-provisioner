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

require 'optparse'

module Coopr
  class Worker
    class CLI
      def self.read(arguments = ARGV)

        # Parse command line options.
        options = {}
        OptionParser.new do |opts|
          opts.banner = 'Usage: '
          opts.on('-u', '--uri URI', 'Coopr web server uri') do |u|
            options[:uri] = u
          end
          opts.on('-f', '--file FILE', 'Full path to task json') do |f|
            options[:file] = f
          end
          opts.on('-t', '--tenant TENANT', 'Tenant ID') do |t|
            options[:tenant] = t
          end
          opts.on('-p', '--provisioner PROVISIONER', 'Provisioner ID') do |p|
            options[:provisioner] = p
          end
          opts.on('-n', '--name NAME', 'Worker name') do |n|
            options[:name] = n
          end
          options[:register] = false
          opts.on('-r', '--register', 'Register installed plugins with the server.  Requires --uri') do
            options[:register] = true
          end
          opts.on('-L', '--log-level LEVEL', 'Log level') do |f|
            options[:log_level] = f
          end
          opts.on('-l', '--log-dir DIRECTORY', 'Path to log directory') do |d|
            options[:log_directory] = d
          end
          opts.on('-w', '--work-dir DIRECTORY', 'Path to work directory') do |d|
            options[:work_dir] = d
          end
          options[:once] = false
          opts.on('-o', '--once', 'Only poll and run a single task') do
            options[:once] = true
          end
          opts.on('--cert-path CERTPATH', 'Trust certificate path') do |c|
            options[:cert_path] = c
          end
          opts.on('--cert-pass CERTPASS', 'Trust certificate password') do |p|
            options[:cert_pass] = p
          end
        end.parse!(arguments)
        options
      end
    end
  end
end
