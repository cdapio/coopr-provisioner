require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

action :commit do
  shell_out!(
      'pure-pw',
      'mkdb',
      '/opt/local/etc/pure-ftpd/pureftpd.pdb',
      '-f/opt/local/etc/pure-ftpd/pureftpd.passwd',
      user: node['pure_ftpd']['system_user'],
      group: node['pure_ftpd']['system_group']
  )

  new_resource.updated_by_last_action(true)
end
