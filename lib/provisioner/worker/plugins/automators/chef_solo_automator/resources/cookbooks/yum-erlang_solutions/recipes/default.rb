#
# Author:: Sean OMeara (<someara@chef.io>)
# Recipe:: yum-erlang_solutions::default
#
# Copyright 2013-2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'yum-epel'

yum_repository 'erlang_solutions' do
  description node['yum']['erlang_solutions']['description'] unless node['yum']['erlang_solutions']['description'].nil?
  baseurl node['yum']['erlang_solutions']['baseurl'] unless node['yum']['erlang_solutions']['baseurl'].nil?
  mirrorlist node['yum']['erlang_solutions']['mirrorlist'] unless node['yum']['erlang_solutions']['mirrorlist'].nil?
  gpgcheck node['yum']['erlang_solutions']['gpgcheck'] unless node['yum']['erlang_solutions']['gpgcheck'].nil?
  gpgkey node['yum']['erlang_solutions']['gpgkey'] unless node['yum']['erlang_solutions']['gpgkey'].nil?
  enabled node['yum']['erlang_solutions']['enabled'] unless node['yum']['erlang_solutions']['enabled'].nil?
  cost node['yum']['erlang_solutions']['cost'] unless node['yum']['erlang_solutions']['cost'].nil?
  exclude node['yum']['erlang_solutions']['exclude'] unless node['yum']['erlang_solutions']['exclude'].nil?
  enablegroups node['yum']['erlang_solutions']['enablegroups'] unless node['yum']['erlang_solutions']['enablegroups'].nil?
  failovermethod node['yum']['erlang_solutions']['failovermethod'] unless node['yum']['erlang_solutions']['failovermethod'].nil?
  http_caching node['yum']['erlang_solutions']['http_caching'] unless node['yum']['erlang_solutions']['http_caching'].nil?
  include_config node['yum']['erlang_solutions']['include_config'] unless node['yum']['erlang_solutions']['include_config'].nil?
  includepkgs node['yum']['erlang_solutions']['includepkgs'] unless node['yum']['erlang_solutions']['includepkgs'].nil?
  keepalive node['yum']['erlang_solutions']['keepalive'] unless node['yum']['erlang_solutions']['keepalive'].nil?
  max_retries node['yum']['erlang_solutions']['max_retries'] unless node['yum']['erlang_solutions']['max_retries'].nil?
  metadata_expire node['yum']['erlang_solutions']['metadata_expire'] unless node['yum']['erlang_solutions']['metadata_expire'].nil?
  mirror_expire node['yum']['erlang_solutions']['mirror_expire'] unless node['yum']['erlang_solutions']['mirror_expire'].nil?
  priority node['yum']['erlang_solutions']['priority'] unless node['yum']['erlang_solutions']['priority'].nil?
  proxy node['yum']['erlang_solutions']['proxy'] unless node['yum']['erlang_solutions']['proxy'].nil?
  proxy_username node['yum']['erlang_solutions']['proxy_username'] unless node['yum']['erlang_solutions']['proxy_username'].nil?
  proxy_password node['yum']['erlang_solutions']['proxy_password'] unless node['yum']['erlang_solutions']['proxy_password'].nil?
  repositoryid node['yum']['erlang_solutions']['repositoryid'] unless node['yum']['erlang_solutions']['repositoryid'].nil?
  sslcacert node['yum']['erlang_solutions']['sslcacert'] unless node['yum']['erlang_solutions']['sslcacert'].nil?
  sslclientcert node['yum']['erlang_solutions']['sslclientcert'] unless node['yum']['erlang_solutions']['sslclientcert'].nil?
  sslclientkey node['yum']['erlang_solutions']['sslclientkey'] unless node['yum']['erlang_solutions']['sslclientkey'].nil?
  sslverify node['yum']['erlang_solutions']['sslverify'] unless node['yum']['erlang_solutions']['sslverify'].nil?
  timeout node['yum']['erlang_solutions']['timeout'] unless node['yum']['erlang_solutions']['timeout'].nil?
  action :create
  only_if { node['yum']['erlang_solutions']['managed'] }
end
