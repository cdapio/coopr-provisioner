default['base']['use_epel'] = true
default['apt']['compile_time_update'] = true
# Default group used in Chef's users::sysadmins recipe
default['authorization']['sudo']['groups'] = ['sysadmin']
default['authorization']['sudo']['passwordless'] = true
default['authorization']['sudo']['include_sudoers_d'] = true
