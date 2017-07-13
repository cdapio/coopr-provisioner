#
# Cookbook Name:: coopr_database
# Recipe:: _resource
#
# Copyright © 2017 Cask Data, Inc.
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

# Create resources for any declared database instances

# mysql
if node.key?('coopr_database')
  if node['coopr_database'].key?('mysql')
    node['coopr_database']['mysql'].each do |db_name, props|
      if props.key?('service')
        mysql_service db_name do
          # json attributes are called as keys to the mysql_service resource
          props['service'].each do |k, v|
            next if k == 'actions' # disallow actions since we control these explicitly in the cookbook
            if respond_to?(k)
              send(k, v)
            else
              Chef::Log.warn("Ignoring invalid JSON attribute \"#{k}\" set for database #{db_name}")
            end
            action :nothing
          end
        end
      end

      if props.key?('config')
        mysql_config db_name do
          # json attributes are called as keys to the mysql_service resource
          props['config'].each do |k, v|
            next if k == 'actions' # disallow actions since we control these explicitly in the cookbook
            next if k == 'instance' # instance is fixed to be db_name
            if respond_to?(k)
              send(k, v)
            else
              Chef::Log.warn("Ignoring invalid JSON attribute \"#{k}\" set for database #{db_name}")
            end
            instance db_name
            action :nothing
          end
        end
      end

    end
  end
end 
