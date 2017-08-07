#
# Cookbook Name:: coopr_mysql
# Recipe:: default
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
if node.key?('coopr_mysql')
  if node['coopr_mysql'].key?('mysql_service')
    node['coopr_mysql']['mysql_service'].each do |db_name, props|
      mysql_service db_name do
        # json attributes are called as keys to the mysql_service resource
        props.each do |k, v|
          next if k == 'actions' # disallow actions since we control these explicitly in the cookbook
          if respond_to?(k)
            send(k, v)
          else
            Chef::Log.warn("Ignoring invalid JSON attribute \"#{k}\" set for database #{db_name}")
          end
          action :nothing
        end
      end

      # Run :create on this resource, unless some other action is specified
      # We want to avoid running :create more than once, since it resets base permissions every time
      # Coopr services can set this attribute in start or stop actions
      db_action =
        if node['coopr_mysql'].key?('action')
          node['coopr_mysql']['action']
        else
          'create'
        end

      ruby_block "mysql-#{db_action}" do
        block do
          resources("mysql_service[#{db_name}]").run_action(db_action.to_sym)
        end
      end
    end
  end
end
