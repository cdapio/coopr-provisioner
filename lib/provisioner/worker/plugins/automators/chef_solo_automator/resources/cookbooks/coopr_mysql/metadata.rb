name             'coopr_mysql'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'All rights reserved'
description      'Manage MySQL database instances'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'mysql', '~> 8.0'
depends 'yum', '>= 3.0'
