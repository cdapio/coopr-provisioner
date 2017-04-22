include_recipe 'smf'
include_recipe 'pure-ftpd::install'

ftpuser = node['pure_ftpd']['system_user']
ftpgroup = node['pure_ftpd']['system_group']
ftphome = node['pure_ftpd']['home']

group ftpgroup

directory '/var/data'

user ftpuser do
  home ftphome
  gid ftpgroup
  shell '/bin/false'
  supports manage_home: true
end

directory ftphome do
  owner ftpuser
  group ftpgroup
  mode 0733
end

directory '/opt/local/etc/pure-ftpd' do
  owner ftpuser
  group ftpgroup
  mode 0700
end

template '/opt/local/sbin/pure-ftpd-setup' do
  source 'pure-ftpd-setup.erb'
  mode 0755
end

# /var/run is a tmpfs, so the pure-ftpd directory does
# not persist after a reboot. Ensure that the required
# run directories exist before the main service starts.
smf 'pure-ftpd-setup' do
  fmri '/application/setup/ftpd-setup'
  start_command '/opt/local/sbin/pure-ftpd-setup'
  stop_command 'true'
  duration 'transient'
  manifest_type 'setup'
  dependencies [
    { 'name' => 'multi-user', 'fmris' => ['svc:/milestone/multi-user'],
      'grouping' => 'require_all', 'restart_on' => 'none', 'type' => 'service' }
  ]
  notifies :enable, 'service[ftpd-setup]'
end

service 'ftpd-setup' do
  supports enable: true, disable: true, reload: true
end

execute 'touch the pure-ftpd passwd file' do
  command 'umask 0117; touch /opt/local/etc/pure-ftpd/pureftpd.passwd'
  user ftpuser
  group ftpgroup
  not_if { File.exist?('/opt/local/etc/pure-ftpd/pureftpd.passwd') }
end

execute 'initialize pure-ftpd virtual user database' do
  command 'pure-pw mkdb /opt/local/etc/pure-ftpd/pureftpd.pdb -f /opt/local/etc/pure-ftpd/pureftpd.passwd'
  user ftpuser
  group ftpgroup
  not_if { File.exist?('/opt/local/etc/pure-ftpd/pureftpd.pdb') }
end

cmd = ['pure-ftpd']
cmd << '--pidfile /var/run/pure-ftpd/pure-ftpd.pid'
cmd << '--noanonymous' if node['pure_ftpd']['disable_anonymous_users']
cmd << '--login puredb:/opt/local/etc/pure-ftpd/pureftpd.pdb'
cmd << '--nochmod' if node['pure_ftpd']['disable_chmod']
cmd << '--bind 0.0.0.0,21'
cmd << '--chrooteveryone'
cmd << '--createhomedir'
cmd << '--dontresolve'
cmd << '--uploadscript'
cmd << '--brokenclientscompatibility'
cmd << '--daemonize'

smf 'pure-ftpd' do
  user ftpuser
  group ftpgroup
  start_command cmd.join(' ')

  working_directory ftphome
  environment 'PATH' => '/opt/local/bin:/opt/local/sbin'
  dependencies [
    { 'name' => 'pure-ftpd-setup', 'fmris' => ['svc:/application/setup/ftpd-setup'],
      'grouping' => 'require_all', 'restart_on' => 'none', 'type' => 'service' }
  ]
  notifies :restart, 'service[pure-ftpd]'
end

service 'pure-ftpd' do
  supports enable: true, reload: true, restart: true, disable: true
end
