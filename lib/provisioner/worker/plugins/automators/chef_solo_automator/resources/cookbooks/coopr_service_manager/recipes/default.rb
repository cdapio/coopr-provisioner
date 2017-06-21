#
# Cookbook Name:: coopr_service_manager
# Recipe:: default
#
# Copyright © 2013-2017 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# We run through all of the services listed, and start/stop them, if a service resource exists

if node['coopr']['node'].key?('services')
  node['coopr']['node']['services'].each do |k, v|
    ruby_block "service-#{v}-#{k}-if-exists" do
      block do
        begin
          r = resources("service[#{k}]")
          Chef::Log.info("Service: #{r}, action: #{v}")
          r.run_action(v.to_sym)
        rescue Chef::Exceptions::ResourceNotFound => e
          raise e if node['coopr_service_manager']['strict'].to_s == 'true'
          Chef::Log.warn("Service: #{k} not found")
        end # begin
      end # block
    end # ruby_block
  end # each
end # if
