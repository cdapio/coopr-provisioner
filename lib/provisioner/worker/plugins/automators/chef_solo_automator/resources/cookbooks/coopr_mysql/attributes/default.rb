#
# Cookbook Name:: coopr_mysql
# Attribute:: default
#
# Copyright © 2018 Cask Data, Inc.
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

# When running on rhel family, optionally configure mysql community repos.
default['coopr_mysql']['yum_mysql_community']['enabled'] = true

# This default version is applied when {'coopr_mysql': {'mysql_service': {'<name>': {'version': 'x.y'}}}}
# is not set. This ensures the repos we configure match the version used by the mysql cookbook.
default['coopr_mysql']['yum_mysql_community']['default_version'] = '5.5'

