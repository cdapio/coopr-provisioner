#
# Cookbook Name:: coopr_database
# Recipe:: config
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

include_recipe 'coopr_database::_resource'

if node.key?('coopr_database')
  if node['coopr_database'].key?('mysql')
    node['coopr_database']['mysql'].each do |db_name, _props|

      ruby_block "mysql-create" do
        block do
          resources("mysql_config[myDB]").run_action(:create)
        end # block
      end
    end
  end
end
