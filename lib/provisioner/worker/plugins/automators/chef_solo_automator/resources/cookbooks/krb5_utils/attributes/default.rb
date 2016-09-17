default['krb5_utils']['admin_principal'] = 'admin/admin'
default['krb5_utils']['admin_password'] = 'password'
default['krb5_utils']['keytabs_dir'] = '/etc/security/keytabs'
default['krb5_utils']['krb5_service_keytabs'] = {}
default['krb5_utils']['krb5_user_keytabs'] = {}
default['krb5_utils']['add_http_principal'] = true
default['krb5_utils']['destroy_before_kinit'] = true
# Force a clock sync, so we don't fail to query/create principals/keytabs
default['ntp']['sync_clock'] = true
