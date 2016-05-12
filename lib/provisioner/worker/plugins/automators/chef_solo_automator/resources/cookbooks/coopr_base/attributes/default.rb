#
# Cookbook Name:: coopr_base
# Attribute:: default
#
# Copyright © 2013-2016 Cask Data, Inc.
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

if node.key?('base')
  Chef::Log.warn('Old "base" attributes found! Converting to "coopr_base"... use node[:coopr_base] going forward!')
  node.default['coopr_base'] = node['base'].merge(node['coopr_base'])
end

default['coopr_base']['use_epel'] = true

default['apt']['compile_time_update'] = true
# Default group used in Chef's users::sysadmins recipe
default['authorization']['sudo']['groups'] = ['sysadmin']
default['authorization']['sudo']['passwordless'] = true
default['authorization']['sudo']['include_sudoers_d'] = true
