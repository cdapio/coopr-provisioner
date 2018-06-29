name 'google-gauth'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures gauth'
long_description 'Installs/Configures gauth'
version '0.1.1'
issues_url 'https://github.com/GoogleCloudPlatform/chef-google-auth/issues' \
  if respond_to?(:issues_url)
source_url 'https://github.com/GoogleCloudPlatform/chef-google-auth' \
  if respond_to?(:source_url)

# These two gems are required to authenticate requests towards GCP.
gem 'googleauth'
gem 'google-api-client', '0.10.1'

supports 'centos'
supports 'debian'
supports 'fedora'
supports 'freebsd'
supports 'opensuse'
supports 'redhat'
supports 'suse'
supports 'ubuntu'
supports 'windows'
