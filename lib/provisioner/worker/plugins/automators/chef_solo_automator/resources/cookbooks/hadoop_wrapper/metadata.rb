name             'hadoop_wrapper'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'Apache 2.0'
description      'Hadoop wrapper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.5.0'

%w(apt krb5_utils yum).each do |cb|
  depends cb
end

depends 'java', '~> 1.40'
depends 'hadoop', '>= 2.0.0'
depends 'mysql', '< 5.0.0'
depends 'database', '< 2.1.0'
depends 'krb5', '>= 1.0.0'
