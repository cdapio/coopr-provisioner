#
# Cookbook Name:: hadoop_wrapper
# Recipe:: kerberos_init
#
# Copyright © 2013-2016 Cask Data, Inc.
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

# Enable kerberos security
if hadoop_kerberos?
  include_recipe 'krb5'
  Chef::Log.info("Secure Hadoop Enabled: Kerberos Realm '#{node['krb5']['krb5_conf']['realms']['default_realm']}'")

  # Create users for services not in hadoop::default
  %w(hbase hive spark zookeeper).each do |u|
    user u do
      action :create
    end
  end

  include_recipe 'krb5::rkerberos_gem'

  # The HTTP principal is needed in multiple keytabs, so we define it separately
  krb5_principal "HTTP/#{node['fqdn']}" do
    randkey true
    action :create
  end

  # Create service keytabs for all services, since we may be a client
  keytabs = {
    'hdfs'      => { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' },
    'hbase'     => { 'owner' => 'hbase', 'group' => 'hadoop', 'mode' => '0640' },
    'hive'      => { 'owner' => 'hive', 'group' => 'hadoop', 'mode' => '0640' },
    'jhs'       => { 'owner' => 'mapred', 'group' => 'hadoop', 'mode' => '0640' },
    'mapred'    => { 'owner' => 'mapred', 'group' => 'hadoop', 'mode' => '0640' },
    'spark'     => { 'owner' => 'spark', 'group' => 'hadoop', 'mode' => '0640' },
    'yarn'      => { 'owner' => 'yarn', 'group' => 'hadoop', 'mode' => '0640' },
    'zookeeper' => { 'owner' => 'zookeeper', 'group' => 'hadoop', 'mode' => '0640' }
  }
  keytabs.each do |name, opts|
    krb5_principal "#{name}/#{node['fqdn']}" do
      randkey true
      action :create
    end
    krb5_keytab "#{node['krb5']['keytabs_dir']}/#{name}.service.keytab" do
      principals ["#{name}/#{node['fqdn']}", "HTTP/#{node['fqdn']}"]
      owner opts['owner']
      group opts['group']
      mode  opts['mode']
    end
  end

  # Hack up /etc/default/hadoop-hdfs-datanode
  execute 'modify-etc-default-files' do
    command 'sed -i -e "/HADOOP_SECURE_DN/ s/^#//g" /etc/default/hadoop-hdfs-datanode'
    only_if 'test -e /etc/default/hadoop-hdfs-datanode'
  end
  # We need to kinit as hdfs to create directories
  execute 'kinit-as-hdfs-user' do
    command "kinit -kt #{node['krb5']['keytabs_dir']}/hdfs.service.keytab hdfs/#{node['fqdn']}@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
    user 'hdfs'
    group 'hdfs'
    only_if "test -e #{node['krb5']['keytabs_dir']}/hdfs.service.keytab"
  end
end

if node['hbase'].key?('hbase_site') && node['hbase']['hbase_site'].key?('hbase.security.authorization') &&
   node['hbase']['hbase_site'].key?('hbase.security.authentication') &&
   node['hbase']['hbase_site']['hbase.security.authorization'].to_s == 'true' &&
   node['hbase']['hbase_site']['hbase.security.authentication'] == 'kerberos'
  Chef::Application.fatal!('You must enable kerberos in Hadoop or disable kerberos for HBase!') unless hadoop_kerberos?
end

if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.metastore.sasl.enabled') &&
   node['hive']['hive_site']['hive.metastore.sasl.enabled'].to_s == 'true'
  Chef::Application.fatal!('You must enable kerberos in Hadoop or disable kerberos for Hive!') unless hadoop_kerberos?
end
