case platform
when "smartos"
  if system("modinfo | grep sngl 2>&1 > /dev/null")
    default['paths']['lib_path'] = "/system/lib:/system/usr/lib:/usr/local/lib"
    default['paths']['bin_path'] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin"
    default['paths']['bin_dir']  = "/usr/local/bin"
    default['paths']['etc_dir']  = "/usr/local/etc"
    default['paths']['prefix_dir'] = "/usr/local"
    default['paths']['sbin_dir']  = "/usr/local/sbin"
  else
    default['paths']['lib_path'] = "/lib:/usr/lib:/opt/local/lib:/opt/gcc/lib"
    default['paths']['bin_path'] = "/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin"
    default['paths']['bin_dir']  = "/opt/local/bin"
    default['paths']['etc_dir']  = "/opt/local/etc"
    default['paths']['prefix_dir'] = "/opt/local"
    default['paths']['sbin_dir']  = "/opt/local/sbin"
  end
when "ubuntu", "debian"
  default['paths']['lib_path'] = "/usr/local/lib:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu"
  default['paths']['bin_path'] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  default['paths']['bin_dir']  = "/usr/local/bin"
  default['paths']['prefix_dir'] = "/usr/local"
  default['paths']['sbin_dir']  = "/usr/local/sbin"
else
  default['paths']['lib_path'] = "/usr/local/lib"
  default['paths']['bin_path'] = "/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
  default['paths']['bin_dir']  = "/usr/local/bin"
  default['paths']['etc_dir']  = "/etc"
  default['paths']['prefix_dir'] = "/usr/local"
  default['paths']['sbin_dir']  = "/usr/local/sbin"
end
