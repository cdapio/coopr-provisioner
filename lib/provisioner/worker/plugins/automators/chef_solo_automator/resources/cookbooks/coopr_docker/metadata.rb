name             'coopr_docker'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'Apache 2.0'
description      'Simple Docker installer'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.1'

depends 'chef-apt-docker', '~> 2.0'
depends 'chef-yum-docker', '~> 3.0'
depends 'docker', '~> 2.0'
