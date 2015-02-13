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

source 'https://rubygems.org'

gem 'rake'

group :dependencies do
  # These gems are used by the provisioner
  gem 'json'
  gem 'logger'
  gem 'net-scp'
  gem 'rest_client', '~> 1.7'
  gem 'sinatra', "~> 1.4"
  gem 'thin', "~> 1.6"
  gem "deep_merge", '~> 1.0', :require => 'deep_merge/rails_compat'
end

group :test do
  gem 'rake'
  gem 'rack-test', '~> 0.6'
  gem 'rspec', '~> 3.0'
  gem 'rubocop', '~> 0.24'
  gem 'simplecov', '~> 0.7.1', :require => false
end

# Install gems from each plugin
Dir.glob(File.join(File.dirname(__FILE__), 'lib', 'provisioner', 'worker', 'plugins', '*', '*', "Gemfile")) do |gemfile|
  puts "Including provisioner plugin Gemfile: #{gemfile}"
  eval_gemfile(gemfile)
end