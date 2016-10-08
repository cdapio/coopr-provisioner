#
# Cookbook Name:: coopr_packages
# Recipe:: default
#
# Copyright © 2015-2016 Cask Data, Inc.
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

# Install common packages
%w(remove install upgrade).each do |act|
  node['coopr_packages']['common'][act].each do |cb|
    package cb do
      action act.to_sym
    end
  end
end

# Install platform-specific packages
pf = node['platform_family']
%w(remove install upgrade).each do |act|
  node['coopr_packages'][pf][act].each do |cb|
    package cb do
      action act.to_sym
    end
  end
end

# Upgrade packages
case pf
when 'debian'
  execute 'update-apt-packages' do
    command 'apt-get update && apt-get upgrade -y && apt-get install -y unattended-upgrades'
    environment 'DEBIAN_FRONTEND' => 'noninteractive'
    not_if { node['coopr_packages']['skip_updates'].to_s == 'true' }
  end
when 'rhel'
  execute 'update-yum-packages' do
    command 'yum makecache && yum upgrade -y'
    not_if { node['coopr_packages']['skip_updates'].to_s == 'true' }
  end
end
