default['yum']['erlang_solutions']['baseurl'] = "http://packages.erlang-solutions.com/rpm/centos/#{node['platform_version'].to_i}/$basearch"
default['yum']['erlang_solutions']['description'] = "Centos #{node['platform_version'].to_i} - $basearch - Erlang Solutions"
default['yum']['erlang_solutions']['gpgkey'] = 'http://packages.erlang-solutions.com/debian/erlang_solutions.asc'
default['yum']['erlang_solutions']['gpgcheck'] = false
default['yum']['erlang_solutions']['enabled'] = true
default['yum']['erlang_solutions']['managed'] = true
