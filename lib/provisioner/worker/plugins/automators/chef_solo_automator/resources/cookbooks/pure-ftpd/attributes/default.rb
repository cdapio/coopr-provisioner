default['pure_ftpd']['install_from'] = 'source'

default['pure_ftpd']['source_url'] = 'http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz'
default['pure_ftpd']['source_checksum'] = '90fb63b1a9d448076aa9f3e3c74b298965f98e03c824e9a4d241fffe8eb3a130'

default['pure_ftpd']['disable_anonymous_users'] = true
default['pure_ftpd']['disable_chmod'] = true

default['pure_ftpd']['system_user'] = 'ftpd'
default['pure_ftpd']['system_group'] = 'ftpd'

default['pure_ftpd']['home'] = '/var/data/ftp'
