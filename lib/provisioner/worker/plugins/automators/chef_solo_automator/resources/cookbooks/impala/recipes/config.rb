#
# Cookbook Name:: impala
# Recipe:: config
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

impala_conf_dir = "/etc/impala/#{node['impala']['conf_dir']}"

directory impala_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

directory '/etc/default' do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

# Setup /etc/default/impala
if node['impala'].key?('config')
  impala_log_dir =
    if node['impala']['config'].key?('impala_log_dir')
      node['impala']['config']['impala_log_dir']
    else
      '/var/log/impala'
    end

  directory impala_log_dir do
    owner node['impala']['user']
    group node['impala']['group']
    mode '0755'
    action :create
    recursive true
    only_if { node['impala']['config'].key?('impala_log_dir') }
  end

  unless impala_log_dir == '/var/log/impala'
    # Delete default directory, if we aren't set to it
    directory '/var/log/impala' do
      action :delete
      not_if 'test -L /var/log/impala'
    end
    # symlink
    link '/var/log/impala' do
      to impala_log_dir
    end
  end

  template '/etc/default/impala' do
    source 'generic-env.sh.erb'
    mode '0755'
    owner node['impala']['user']
    group node['impala']['group']
    action :create
    variables :options => node['impala']['config']
  end
end # End /etc/default/impala

# COOK-91 Setup hive-site.xml
template "#{impala_conf_dir}/hive-site.xml" do
  source 'generic-site.xml.erb'
  mode '0644'
  owner node['impala']['user']
  group node['impala']['group']
  action :create
  variables :options => node['hive']['hive_site']
  only_if { node.key?('hive') && node['hive'].key?('hive_site') && !node['hive']['hive_site'].empty? }
end # End hive-site.xml

# Update alternatives to point to our configuration
execute 'update impala-conf alternatives' do
  command "update-alternatives --install /etc/impala/conf impala-conf /etc/impala/#{node['impala']['conf_dir']} 50"
  not_if "update-alternatives --display impala-conf | grep best | awk '{print $5}' | grep /etc/impala/#{node['impala']['conf_dir']}"
end
