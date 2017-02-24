include_recipe 'paths::default'

case node['pure_ftpd']['install_from']
when 'package'
  package 'pure-ftpd'
when 'source'
  pure_ftpd_installer 'install' do
    action :run
  end
end
