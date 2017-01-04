#
# Cookbook Name:: coopr_packages
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

default['coopr_packages']['common']['install'] = []
default['coopr_packages']['common']['upgrade'] = []
default['coopr_packages']['common']['remove'] = []
default['coopr_packages']['debian']['install'] = []
default['coopr_packages']['debian']['upgrade'] = []
default['coopr_packages']['debian']['remove'] = []
default['coopr_packages']['rhel']['install'] = []
default['coopr_packages']['rhel']['upgrade'] = []
default['coopr_packages']['rhel']['remove'] = ['yum-cron']

# options passed to the package resources, as well as the initial package upgrade
default['coopr_packages']['debian']['options'] = '-y -o Dpkg::Options::="--force-confnew"'
default['coopr_packages']['rhel']['options'] = '-y'

default['coopr_packages']['skip_updates'] = false
