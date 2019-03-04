name             'coopr_dns'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'All rights reserved'
description      'Installs/Configures DNS'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.1'

depends 'dnsimple', '>= 2.0'
depends 'dynect'
depends 'google-gdns'
