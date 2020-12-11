name             'coopr_dns'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'All rights reserved'
description      'Installs/Configures DNS'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.2.0'

depends 'dynect'
depends 'google-gdns'

# constrain transitive dependency brought in by google-gauth
# as 0.12.0 is incompatible with the ruby versions in chef 12
gem 'signet', '0.11.0'
