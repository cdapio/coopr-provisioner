name             'impala'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'All rights reserved'
description      'Installs/Configures Impala'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

%w(hadoop java).each do |cb|
  depends cb
end

%w(amazon centos debian redhat scientific ubuntu).each do |os|
  supports os
end
