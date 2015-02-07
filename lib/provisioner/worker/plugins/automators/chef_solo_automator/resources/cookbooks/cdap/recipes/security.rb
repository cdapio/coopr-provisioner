#
# Cookbook Name:: cdap
# Recipe:: security
#
# Copyright © 2013-2014 Cask Data, Inc.
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

include_recipe 'java::default'
include_recipe 'cdap::repo'

package 'cdap-security' do
  action :install
  version node['cdap']['version']
end

service 'cdap-auth-server' do
  status_command 'service cdap-auth-server status'
  action :nothing
end