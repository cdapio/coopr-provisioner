#
# Cookbook Name:: hadoop_wrapper
# Recipe:: spark_historyserver_init
#
# Copyright © 2013-2015 Cask Data, Inc.
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

include_recipe 'hadoop_wrapper::default'
include_recipe 'hadoop::default'
include_recipe 'hadoop::spark_historyserver'

ruby_block 'initaction-create-hdfs-spark-userdir' do
  block do
    resources('execute[hdfs-spark-userdir]').run_action(:run)
  end
end

ruby_block 'initaction-create-hdfs-spark-eventlog-dir' do
  block do
    resources('execute[hdfs-spark-eventlog-dir]').run_action(:run)
  end
end
