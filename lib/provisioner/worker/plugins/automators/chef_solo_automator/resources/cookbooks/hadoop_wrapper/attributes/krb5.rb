#
# Cookbook Name:: hadoop_wrapper
# Attribute:: krb5
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

# Enable security everywhere with these two properties
# default['hadoop']['core_site']['hadoop.security.authorization'] = 'true'
# default['hadoop']['core_site']['hadoop.security.authentication'] = 'kerberos'

if node['hadoop'].key?('core_site') && node['hadoop']['core_site'].key?('hadoop.security.authorization') &&
   node['hadoop']['core_site'].key?('hadoop.security.authentication') &&
   node['hadoop']['core_site']['hadoop.security.authorization'].to_s == 'true' &&
   node['hadoop']['core_site']['hadoop.security.authentication'] == 'kerberos'

  include_attribute 'krb5'

  # Hadoop

  # container-executor.cfg
  default['hadoop']['container_executor']['allowed.system.users'] = 'hive,yarn'
  default['hadoop']['container_executor']['banned.users'] = 'hdfs,mapred,bin'
  default['hadoop']['container_executor']['min.user.id'] = 500
  default['hadoop']['container_executor']['yarn.nodemanager.linux-container-executor.group'] = 'yarn'
  default['hadoop']['container_executor']['yarn.nodemanager.local-dirs'] =
    if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.nodemanager.local-dirs')
      node['hadoop']['yarn_site']['yarn.nodemanager.local-dirs']
    elsif node['hadoop'].key?('core_site') && node['hadoop']['core_site'].key?('hadoop.tmp.dir')
      "#{node['hadoop']['core_site']['hadoop.tmp.dir']}/nm-local-dir"
    else
      'file:///tmp/hadoop-yarn/nm-local-dir'
    end
  default['hadoop']['container_executor']['yarn.nodemanager.log-dirs'] = '/var/log/hadoop-yarn/userlogs'
  default['hadoop']['container_executor']['yarn.nodemanager.container-executor.class'] = 'org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor'

  # core-site.xml
  default['hadoop']['core_site']['hadoop.proxyuser.hive.groups'] = 'hadoop,hive'
  default['hadoop']['core_site']['hadoop.proxyuser.hive.hosts'] = '*'

  # hadoop-env.sh
  default['hadoop']['hadoop_env']['hadoop_secure_dn_user'] = 'hdfs'
  if node['hadoop']['distribution'] == 'hdp' && node['hadoop']['distribution_version'].to_f >= 2.2
    default['hadoop']['hadoop_env']['hadoop_secure_dn_pid_dir'] = '/var/run/hadoop/hdfs'
    default['hadoop']['hadoop_env']['hadoop_secure_dn_log_dir'] = '/var/log/hadoop/hdfs'
  else
    default['hadoop']['hadoop_env']['hadoop_secure_dn_pid_dir'] = '/var/run/hadoop-hdfs'
    default['hadoop']['hadoop_env']['hadoop_secure_dn_log_dir'] = '/var/log/hadoop-hdfs'
  end

  # hdfs-site.xml
  default['hadoop']['hdfs_site']['dfs.block.access.token.enable'] = 'true'
  default['hadoop']['hdfs_site']['dfs.datanode.kerberos.principal'] = "hdfs/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['hdfs_site']['dfs.namenode.kerberos.principal'] = "hdfs/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['hdfs_site']['dfs.secondary.namenode.kerberos.principal'] = "hdfs/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['hdfs_site']['dfs.web.authentication.kerberos.principal'] = "HTTP/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['hdfs_site']['dfs.namenode.kerberos.internal.spnego.principal'] = "HTTP/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['hdfs_site']['dfs.secondary.namenode.kerberos.internal.spnego.principal'] = "HTTP/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['hdfs_site']['dfs.datanode.keytab.file'] = "#{node['krb5']['keytabs_dir']}/hdfs.service.keytab"
  default['hadoop']['hdfs_site']['dfs.namenode.keytab.file'] = "#{node['krb5']['keytabs_dir']}/hdfs.service.keytab"
  default['hadoop']['hdfs_site']['dfs.secondary.namenode.keytab.file'] = "#{node['krb5']['keytabs_dir']}/hdfs.service.keytab"
  default['hadoop']['hdfs_site']['dfs.datanode.address'] = '0.0.0.0:1004'
  default['hadoop']['hdfs_site']['dfs.datanode.http.address'] = '0.0.0.0:1006'

  # mapred-site.xml
  default['hadoop']['mapred_site']['mapreduce.jobhistory.keytab'] = "#{node['krb5']['keytabs_dir']}/mapred.service.keytab"
  default['hadoop']['mapred_site']['mapreduce.jobhistory.principal'] = "mapred/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"

  # yarn-site.xml
  default['hadoop']['yarn_site']['yarn.resourcemanager.keytab'] = "#{node['krb5']['keytabs_dir']}/yarn.service.keytab"
  default['hadoop']['yarn_site']['yarn.nodemanager.keytab'] = "#{node['krb5']['keytabs_dir']}/yarn.service.keytab"
  default['hadoop']['yarn_site']['yarn.resourcemanager.principal'] = "yarn/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['yarn_site']['yarn.nodemanager.principal'] = "yarn/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['yarn_site']['yarn.nodemanager.linux-container-executor.group'] = 'yarn'
  default['hadoop']['yarn_site']['yarn.nodemanager.container-executor.class'] = 'org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor'

  # HBase

  # hbase-site.xml
  default['hbase']['hbase_site']['hbase.security.authorization'] = 'true'
  default['hbase']['hbase_site']['hbase.security.authentication'] = 'kerberos'
  default['hbase']['hbase_site']['hbase.master.keytab.file'] = "#{node['krb5']['keytabs_dir']}/hbase.service.keytab"
  default['hbase']['hbase_site']['hbase.regionserver.keytab.file'] = "#{node['krb5']['keytabs_dir']}/hbase.service.keytab"
  default['hbase']['hbase_site']['hbase.master.kerberos.principal'] = "hbase/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hbase']['hbase_site']['hbase.regionserver.kerberos.principal'] = "hbase/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hbase']['hbase_site']['hbase.coprocessor.region.classes'] = 'org.apache.hadoop.hbase.security.token.TokenProvider,org.apache.hadoop.hbase.security.access.SecureBulkLoadEndpoint,org.apache.hadoop.hbase.security.access.AccessController'
  default['hbase']['hbase_site']['hbase.coprocessor.master.classes'] = 'org.apache.hadoop.hbase.security.access.AccessController'
  default['hbase']['hbase_site']['hbase.bulkload.staging.dir'] = '/tmp/hbase-staging'

  # Hive

  # hive-site.xml
  default['hive']['hive_site']['hive.metastore.sasl.enabled'] = 'true'
  default['hive']['hive_site']['hive.metastore.kerberos.keytab.file'] = "#{node['krb5']['keytabs_dir']}/hive.service.keytab"
  default['hive']['hive_site']['hive.metastore.kerberos.principal'] = "hive/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hive']['hive_site']['hive.server2.authentication'] = 'KERBEROS'
  default['hive']['hive_site']['hive.server2.authentication.kerberos.keytab'] = "#{node['krb5']['keytabs_dir']}/hive.service.keytab"
  default['hive']['hive_site']['hive.server2.authentication.kerberos.principal'] = "hive/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"

  # Spark

  # spark-defaults.conf
  default['spark']['spark_defaults']['spark.history.kerberos.enabled'] = 'true'
  # We cannot use _HOST here... https://issues.apache.org/jira/browse/SPARK-17121
  default['spark']['spark_defaults']['spark.history.kerberos.principal'] = "spark/#{node['fqdn']}@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['spark']['spark_defaults']['spark.history.kerberos.keytab'] = "#{node['krb5']['keytabs_dir']}/spark.service.keytab"

  # ZooKeeper

  # client_jaas.conf master_jaas.conf hbase-env.sh zookeeper-env.sh
  %w(hbase zookeeper).each do |svc|
    default[svc]['master_jaas']['client']['usekeytab'] = 'true'
    # We cannot use _HOST here... https://issues.apache.org/jira/browse/ZOOKEEPER-1422
    default[svc]['master_jaas']['client']['principal'] = "#{svc}/#{node['fqdn']}@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
    default[svc]['master_jaas']['client']['keytab'] = "#{node['krb5']['keytabs_dir']}/#{svc}.service.keytab"
    default[svc]['client_jaas']['client']['usekeytab'] = 'false'
  end
  jsalc = '-Djava.security.auth.login.config'
  # The following may be set, so we have to append, rather than just override
  if node['hbase'].key?('hbase_env')
    # Start with client
    override['hbase']['hbase_env']['hbase_opts'] = if node['hbase']['hbase_env'].key?('hbase_opts')
                                                     "#{node['hbase']['hbase_env']['hbase_opts']} #{jsalc}=/etc/hbase/conf/client_jaas.conf"
                                                   else
                                                     "#{jsalc}=/etc/hbase/conf/client_jaas.conf"
                                                   end
    # Services
    %w(hbase_master_opts hbase_regionserver_opts).each do |var|
      override['hbase']['hbase_env'][var] = if node['hbase']['hbase_env'].key?(var)
                                              "#{node['hbase']['hbase_env'][var]} #{jsalc}=/etc/hbase/conf/master_jaas.conf"
                                            else
                                              "#{jsalc}=/etc/hbase/conf/master_jaas.conf"
                                            end
    end
  else
    default['hbase']['hbase_env']['hbase_opts'] = "#{jsalc}=/etc/hbase/conf/client_jaas.conf"
    default['hbase']['hbase_env']['hbase_master_opts'] = "#{jsalc}=/etc/hbase/conf/master_jaas.conf"
    default['hbase']['hbase_env']['hbase_regionserver_opts'] = "#{jsalc}=/etc/hbase/conf/master_jaas.conf"
  end
  if node['zookeeper'].key?('zookeeper_env')
    override['zookeeper']['zookeeper_env']['client_jvmflags'] = if node['zookeeper']['zookeeper_env'].key?('client_jvmflags')
                                                                  "#{node['zookeeper']['zookeeper_env']['client_jvmflags']} #{jsalc}=/etc/zookeeper/conf/client_jaas.conf"
                                                                else
                                                                  "#{jsalc}=/etc/zookeeper/conf/client_jaas.conf"
                                                                end
    override['zookeeper']['zookeeper_env']['server_jvmflags'] = if node['zookeeper']['zookeeper_env'].key?('server_jvmflags')
                                                                  "#{node['zookeeper']['zookeeper_env']['server_jvmflags']} #{jsalc}=/etc/zookeeper/conf/master_jaas.conf"
                                                                else
                                                                  "#{jsalc}=/etc/zookeeper/conf/master_jaas.conf"
                                                                end
  else
    default['zookeeper']['zookeeper_env']['client_jvmflags'] = "#{jsalc}=/etc/zookeeper/conf/client_jaas.conf"
    default['zookeeper']['zookeeper_env']['server_jvmflags'] = "#{jsalc}=/etc/zookeeper/conf/master_jaas.conf"
  end
  # Copy master client config to master server config
  default['zookeeper']['master_jaas']['server'] = node['zookeeper']['master_jaas']['client']

  # zoo.cfg
  default['zookeeper']['zoocfg']['authProvider.1'] = 'org.apache.zookeeper.server.auth.SASLAuthenticationProvider'
  default['zookeeper']['zoocfg']['jaasLoginRenew'] = '3600000' unless node['zookeeper']['zoocfg']['jaasLoginRenew']
  default['zookeeper']['zoocfg']['kerberos.removeHostFromPrincipal'] = 'true'
  default['zookeeper']['zoocfg']['kerberos.removeRealmFromPrincipal'] = 'true'
end
