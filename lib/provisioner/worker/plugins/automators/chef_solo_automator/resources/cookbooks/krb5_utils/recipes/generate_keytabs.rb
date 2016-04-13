#
# Cookbook Name:: krb5_utils
# Recipe:: generate_keytabs
#
# Copyright © 2016 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'krb5_utils::kinit_as_admin'

keytab_dir = node['krb5_utils']['keytabs_dir']

directory keytab_dir do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Generate execute blocks
%w(krb5_service_keytabs krb5_user_keytabs).each do |kt|
  node['krb5_utils'][kt].each do |name, opts|
    case kt
    when 'krb5_service_keytabs'
      http_principal = if node['krb5_utils']['add_http_principal']
                         "HTTP/#{node['fqdn']}@#{node['krb5']['krb5_conf']['libdefaults']['default_realm'].upcase}"
                       else
                         ''
                       end
      principal = "#{name}/#{node['fqdn']}@#{node['krb5']['krb5_conf']['libdefaults']['default_realm'].upcase}"
      keytab_file = "#{name}.service.keytab"
      randkey = '-randkey'
    when 'krb5_user_keytabs'
      http_principal = ''
      principal = "#{name}@#{node['krb5']['krb5_conf']['libdefaults']['default_realm'].upcase}"
      keytab_file = "#{name}.keytab"
      randkey = '-norandkey'
    end

    execute "krb5-addprinc-#{principal}" do
      command "kadmin -w #{node['krb5_utils']['admin_password']} -q 'addprinc #{randkey} #{principal}'"
      action :run
      not_if "kadmin -w #{node['krb5_utils']['admin_password']} -q 'list_principals' | grep -v Auth | grep '^#{principal}'"
    end

    execute "krb5-check-#{principal}" do
      command "kadmin -w #{node['krb5_utils']['admin_password']} -q 'list_principals' | grep -v Auth | grep '^#{principal}'"
      action :run
      not_if "test -e #{keytab_dir}/#{keytab_file}"
    end

    execute "krb5-generate-keytab-#{keytab_file}" do
      command "kadmin -w #{node['krb5_utils']['admin_password']} -q 'xst -kt #{keytab_dir}/#{keytab_file} #{principal} #{http_principal}'"
      action :run
      not_if "test -e #{keytab_dir}/#{keytab_file}"
    end

    file "#{keytab_dir}/#{keytab_file}" do
      owner opts.owner
      group opts.group
      mode opts.mode
      action :create
      only_if "test -e #{keytab_dir}/#{keytab_file}"
    end
  end
end
