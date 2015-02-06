#
# Cookbook Name:: impala
# Recipe:: default
#
# Copyright © 2013-2015 Cask Data, Inc.
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

# We only work on CDH 5+
unless node.key?('hadoop') && node['hadoop'].key?('distribution') && node['hadoop']['distribution'] == 'cdh' &&
       node['hadoop'].key?('distribution_version') && node['hadoop']['distribution_version'].to_i >= 5
  Chef::Application.fatal!('This cookbook only supports Cloudera CDH 5+!')
end

include_recipe 'hadoop::default'
include_recipe 'hadoop::hive'

# Create our user and group
group node['impala']['group'] do
  action :create
end

user node['impala']['user'] do
  action :create
  gid node['impala']['group']
end

package 'impala' do
  action :install
end

include_recipe 'impala::config'
