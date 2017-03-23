name             'hadoop_wrapper'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'Apache 2.0'
description      'Hadoop wrapper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.2.0'

depends 'java', '~> 1.40'
depends 'hadoop', '>= 2.0.0'
depends 'mysql', '< 5.0.0'
depends 'database', '< 2.1.0'
depends 'krb5', '>= 2.2.0'

source_url 'https://github.com/caskdata/hadoop_wrapper_cookbook' if respond_to?(:source_url)
issues_url 'https://issues.cask.co/browse/COOK/component/10601' if respond_to?(:issues_url)
