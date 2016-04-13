#
# Cookbook Name:: krb5_utils
# Recipe:: kinit_as_admin
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

include_recipe 'krb5::default'

execute 'kdestroy' do
  command 'kdestroy'
  action :run
  only_if { node['krb5_utils']['destroy_before_kinit'].to_s == 'true' }
end

execute 'kinit-as-admin-user' do
  command "echo #{node['krb5_utils']['admin_password']} | kinit #{node['krb5_utils']['admin_principal']}"
  action :run
end
