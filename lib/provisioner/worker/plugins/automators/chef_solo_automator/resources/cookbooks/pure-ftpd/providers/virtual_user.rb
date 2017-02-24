require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def load_current_resource
  @current_resource = load_user(new_resource.username)
end

action :create_or_update do
  if @current_resource
    Chef::Log.warn('skipping already existing user')
    new_resource.updated_by_last_action(false)
  else
    create_virtual_user
    new_resource.updated_by_last_action(true)
    new_resource.notifies :commit, user_database_resource, :delayed
  end
end

action :delete do
  if @current_resource
    cmd = ['pure-pw']
    cmd << 'userdel'
    cmd << '-f/opt/local/etc/pure-ftpd/pureftpd.passwd'
    cmd << new_resource.username

    shell_out!(*cmd)

    new_resource.updated_by_last_action(true)
    new_resource.notifies :commit, user_database_resource, :delayed
  end
end

def create_virtual_user
  Chef::Log.warn('creating user')
  create_user_home_directory

  shell_out!(
    *create_user_command,
    input: "#{new_resource.password}\n" * 2,
    user: system_user,
    group: system_group)
end

def create_user_home_directory
  directory new_resource.home_directory do
    owner system_user
    group system_group
    mode 0700
  end
end

def load_user(username)
  return unless user_data_for(username).exitstatus == 0

  user_values = user_data_for(username).stdout.split("\n")
    .delete_if(&:empty?)
    .map { |r| r.split(/\s*:\s*/) }
    .each_with_object({}) do |key_value_pair, hash|
      hash[key_value_pair.first] = key_value_pair.last
    end

  user = Chef::Resource::PureFtpdVirtualUser.new(new_resource.username)

  user.username(user_values['Login'])
  user.uid(user_values['UID'].split(' ').first.to_i)
  user.gid(user_values['GID'].split(' ').first.to_i)

  user
end

def create_user_command
  cmd = ['pure-pw']
  cmd << 'useradd'
  cmd << new_resource.username
  cmd << "-u #{find_uid(system_user)}"
  cmd << "-g #{find_gid(system_group)}"
  cmd << "-d#{new_resource.home_directory}"
  cmd << "-y #{new_resource.max_concurrency}"
  cmd << '-f/opt/local/etc/pure-ftpd/pureftpd.passwd'
end

def find_uid(username)
  shell_out!('id', '-u', username).stdout.strip
end

def find_gid(groupname)
  shell_out!('gid', '-g', groupname).stdout.strip
end

def system_user
  node['pure_ftpd']['system_user']
end

def system_group
  node['pure_ftpd']['system_group']
end

def user_data_for(username)
  @user_data ||= shell_out(
    'pure-pw',
    'show',
    username,
    '-f/opt/local/etc/pure-ftpd/pureftpd.passwd',
    user: system_user, group: system_group)
end

# Used to notify that the virtual user database should be committed at the
# end of the chef run.
def user_database_resource
  @user_database_resource ||= begin
    run_context.resource_collection.find(pure_ftpd_user_database: 'pure-ftpd')
  rescue Chef::Exceptions::ResourceNotFound
    pure_ftpd_user_database 'pure-ftpd'
  end
end
