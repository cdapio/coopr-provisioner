case node['platform_family']
when 'debian'
  include_recipe 'chef-apt-docker'
when 'rhel', 'amazon'
  include_recipe 'chef-yum-docker'
end

# Install docker with overlayfs
docker_service 'default' do
  storage_driver node['coopr_docker']['docker_storage_driver']
  version node['coopr_docker']['docker_version'] if node['coopr_docker']['docker_version']
  install_method 'package' if node['coopr_docker']['docker_version']
  action %i(create start)
end

