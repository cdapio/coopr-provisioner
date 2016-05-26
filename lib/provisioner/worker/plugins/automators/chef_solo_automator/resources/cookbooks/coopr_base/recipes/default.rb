#
# Cookbook Name:: coopr_base
# Recipe:: default
#
# Copyright © 2013-2016 Cask Data, Inc.
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

# This forces an apt-get update on Ubuntu/Debian
case node['platform_family']
when 'debian'
  include_recipe 'apt::default'
when 'rhel'
  include_recipe 'yum-epel::default' if node['coopr_base']['use_epel'].to_s == 'true'
  # The SCL repository has moved... temporary workaround
  yum_package 'centos-release-scl' do
    action :install
    only_if 'yum list installed | grep centos-release-SCL'
  end
end

# We always run our dns, firewall, hosts, and packages cookbooks
%w(packages hosts dns firewall).each do |cb|
  include_recipe "coopr_#{cb}::default" unless node['coopr_base'].key?("no_#{cb}") && node['coopr_base']["no_#{cb}"].to_s == 'true'
end

# Ensure user ulimits are enabled
include_recipe 'ulimit::default'

# Add users in the sysadmins group and give them sudo access
# WARNING - Any user management done here must include any users defined in the Coopr Providers, or not interfere with
#   their sudo permissions
unless node['coopr_base'].key?('no_users') && node['coopr_base']['no_users'].to_s == 'true'
  %w(chef-solo-search users::sysadmins).each do |cb|
    include_recipe cb
  end
  defined_users = search('users', 'groups:sysadmin AND NOT action:remove')
  if defined_users.empty?
    Chef::Log.warn('No users defined in group sysadmins, skipping sudo')
  elsif node['coopr_base'].key?('no_sudo') && node['coopr_base']['no_sudo'].to_s == 'true'
    Chef::Log.info('Skipping sudo due to no_sudo attribute')
  else
    include_recipe 'sudo'
  end
end
