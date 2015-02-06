# impala cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/impala.svg)](https://supermarket.chef.io/cookbooks/impala)
[![Build Status](http://img.shields.io/travis/caskdata/impala_cookbook.svg)](http://travis-ci.org/caskdata/impala_cookbook)

# Requirements

* Oracle Java JDK 6+ (provided by `java` cookbook)
* HDFS client and Hive libraries (provided by `hadoop` cookbook)

# Usage

# Attributes

* `['impala']['conf_dir']` - The directory used inside `/etc/impala` and used via the alternatives system. Default `conf.chef`

# Recipes

* `catalog` - Installs `impala-catalog` package and service
* `config` - Configures all services
* `default` - Installs `impala` package and runs `config` recipe
* `server` - Installs `impala-server` package and service
* `shell` - Installs `impala-shell` package
* `state_store` - Installs `impala-state-store` package and service

# Author

Author:: Cask Data, Inc. (<ops@cask.co>)

# Testing

This cookbook requires the `vagrant-omnibus` and `vagrant-berkshelf` Vagrant plugins to be installed.

# License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this software except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
