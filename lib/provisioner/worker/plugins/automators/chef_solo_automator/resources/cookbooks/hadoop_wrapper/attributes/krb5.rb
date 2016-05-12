# Enable security everywhere with these two properties
# default['hadoop']['core_site']['hadoop.security.authorization'] = 'true'
# default['hadoop']['core_site']['hadoop.security.authentication'] = 'kerberos'

if node['hadoop'].key?('core_site') && node['hadoop']['core_site'].key?('hadoop.security.authorization') &&
   node['hadoop']['core_site'].key?('hadoop.security.authentication') &&
   node['hadoop']['core_site']['hadoop.security.authorization'].to_s == 'true' &&
   node['hadoop']['core_site']['hadoop.security.authentication'] == 'kerberos'

  include_attribute 'krb5'
  include_attribute 'krb5_utils'

  # Create service keytabs for all services, since we may be a client
  default['krb5_utils']['krb5_service_keytabs']['HTTP'] = { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_service_keytabs']['hdfs'] = { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_service_keytabs']['hbase'] = { 'owner' => 'hbase', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_service_keytabs']['hive'] = { 'owner' => 'hive', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_service_keytabs']['jhs'] = { 'owner' => 'mapred', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_service_keytabs']['mapred'] = { 'owner' => 'mapred', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_service_keytabs']['spark'] = { 'owner' => 'spark', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_service_keytabs']['yarn'] = { 'owner' => 'yarn', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_service_keytabs']['zookeeper'] = { 'owner' => 'zookeeper', 'group' => 'hadoop', 'mode' => '0640' }
  default['krb5_utils']['krb5_user_keytabs']['yarn'] = { 'owner' => 'yarn', 'group' => 'hadoop', 'mode' => '0640' }

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
  default['hadoop']['hdfs_site']['dfs.datanode.keytab.file'] = "#{node['krb5_utils']['keytabs_dir']}/hdfs.service.keytab"
  default['hadoop']['hdfs_site']['dfs.namenode.keytab.file'] = "#{node['krb5_utils']['keytabs_dir']}/hdfs.service.keytab"
  default['hadoop']['hdfs_site']['dfs.secondary.namenode.keytab.file'] = "#{node['krb5_utils']['keytabs_dir']}/hdfs.service.keytab"
  default['hadoop']['hdfs_site']['dfs.datanode.address'] = '0.0.0.0:1004'
  default['hadoop']['hdfs_site']['dfs.datanode.http.address'] = '0.0.0.0:1006'

  # mapred-site.xml
  default['hadoop']['mapred_site']['mapreduce.jobhistory.keytab'] = "#{node['krb5_utils']['keytabs_dir']}/jhs.service.keytab"
  default['hadoop']['mapred_site']['mapreduce.jobhistory.principal'] = "jhs/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"

  # yarn-site.xml
  default['hadoop']['yarn_site']['yarn.resourcemanager.keytab'] = "#{node['krb5_utils']['keytabs_dir']}/yarn.service.keytab"
  default['hadoop']['yarn_site']['yarn.nodemanager.keytab'] = "#{node['krb5_utils']['keytabs_dir']}/yarn.service.keytab"
  default['hadoop']['yarn_site']['yarn.resourcemanager.principal'] = "yarn/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['yarn_site']['yarn.nodemanager.principal'] = "yarn/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hadoop']['yarn_site']['yarn.nodemanager.linux-container-executor.group'] = 'yarn'
  default['hadoop']['yarn_site']['yarn.nodemanager.container-executor.class'] = 'org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor'

  # HBase

  # hbase-site.xml
  default['hbase']['hbase_site']['hbase.security.authorization'] = 'true'
  default['hbase']['hbase_site']['hbase.security.authentication'] = 'kerberos'
  default['hbase']['hbase_site']['hbase.master.keytab.file'] = "#{node['krb5_utils']['keytabs_dir']}/hbase.service.keytab"
  default['hbase']['hbase_site']['hbase.regionserver.keytab.file'] = "#{node['krb5_utils']['keytabs_dir']}/hbase.service.keytab"
  default['hbase']['hbase_site']['hbase.master.kerberos.principal'] = "hbase/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hbase']['hbase_site']['hbase.regionserver.kerberos.principal'] = "hbase/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hbase']['hbase_site']['hbase.coprocessor.region.classes'] = 'org.apache.hadoop.hbase.security.token.TokenProvider,org.apache.hadoop.hbase.security.access.SecureBulkLoadEndpoint,org.apache.hadoop.hbase.security.access.AccessController'
  default['hbase']['hbase_site']['hbase.coprocessor.master.classes'] = 'org.apache.hadoop.hbase.security.access.AccessController'
  default['hbase']['hbase_site']['hbase.bulkload.staging.dir'] = '/tmp/hbase-staging'

  # Hive

  # hive-site.xml
  default['hive']['hive_site']['hive.metastore.sasl.enabled'] = 'true'
  default['hive']['hive_site']['hive.metastore.kerberos.keytab.file'] = "#{node['krb5_utils']['keytabs_dir']}/hive.service.keytab"
  default['hive']['hive_site']['hive.metastore.kerberos.principal'] = "hive/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['hive']['hive_site']['hive.server2.authentication'] = 'KERBEROS'
  default['hive']['hive_site']['hive.server2.authentication.kerberos.keytab'] = "#{node['krb5_utils']['keytabs_dir']}/hive.service.keytab"
  default['hive']['hive_site']['hive.server2.authentication.kerberos.principal'] = "hive/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"

  # Spark

  # spark-defaults.conf
  default['spark']['spark_defaults']['spark.history.kerberos.enabled'] = 'true'
  default['spark']['spark_defaults']['spark.history.kerberos.principal'] = "spark/_HOST@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
  default['spark']['spark_defaults']['spark.history.kerberos.keytab'] = "#{node['krb5_utils']['keytabs_dir']}/spark.service.keytab"

  # ZooKeeper

  # jaas.conf hbase-env.sh zookeeper-env.sh
  %w(hbase zookeeper).each do |client|
    default[client]['jaas']['client']['usekeytab'] = 'true'
    # We cannot use _HOST here... https://issues.apache.org/jira/browse/ZOOKEEPER-1422
    default[client]['jaas']['client']['principal'] = "#{client}/#{node['fqdn']}@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
    default[client]['jaas']['client']['keytab'] = "#{node['krb5_utils']['keytabs_dir']}/#{client}.service.keytab"
    default[client]["#{client}_env"]['jvmflags'] = "-Djava.security.auth.login.config=/etc/#{client}/conf/jaas.conf"
  end
  default['zookeeper']['jaas']['server'] = node['zookeeper']['jaas']['client']

  # zoo.cfg
  default['zookeeper']['zoocfg']['authProvider.1'] = 'org.apache.zookeeper.server.auth.SASLAuthenticationProvider'
  default['zookeeper']['zoocfg']['jaasLoginRenew'] = '3600000' unless node['zookeeper']['zoocfg']['jaasLoginRenew']
  default['zookeeper']['zoocfg']['kerberos.removeHostFromPrincipal'] = 'true'
  default['zookeeper']['zoocfg']['kerberos.removeRealmFromPrincipal'] = 'true'
end
