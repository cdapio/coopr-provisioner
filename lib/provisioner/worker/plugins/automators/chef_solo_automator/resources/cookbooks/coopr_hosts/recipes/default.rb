#
# Cookbook Name:: coopr_hosts
# Recipe:: default
#
# Copyright © 2013-2014 Cask Data, Inc.
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
#

# The hostsfile cookbook has a default level of 60 for IPv4 addresses...
# see: https://github.com/customink-webops/hostsfile/blob/v2.4.2/libraries/entry.rb#L158
START = 60
node['coopr']['cluster']['nodes'].each do |n, v|
  short_host = v.hostname.split('.').first
  arr = node['coopr_hosts']['address_types'] || []
  arr.each do |addr|
    next unless v.key?('ipaddresses') && v['ipaddresses'].key?(addr)
    pri = START + (arr.length - arr.index(addr))
    hostsfile_entry v['ipaddresses'][addr] do
      hostname v.hostname
      aliases [short_host]
      unique true
      priority pri
      action :create
    end
  end
end
