# hadoop wrapper cookbook

[![Apache License 2.0](http://img.shields.io/badge/license-apache%202.0-green.svg)](http://opensource.org/licenses/Apache-2.0)
[![Build Status](http://img.shields.io/travis/caskdata/hadoop_wrapper_cookbook.svg)](http://travis-ci.org/caskdata/hadoop_wrapper_cookbook)

# Description

This cookbook is a wrapper cookbook for the [Hadoop cookbook](https://github.com/caskdata/hadoop_cookbook).  It is a part of [Coopr](https://github.com/caskdata/coopr), which is a general purpose tool that can spin up several types of clusters including Hadoop.  This cookbook provides several initialization recipes for Hadoop components.  It does not actually start any of the hadoop services.  This can be done by wrapping the service resources in the underlying [Hadoop cookbook](https://github.com/caskdata/hadoop_cookbook), for example:
```ruby
    ruby_block "start namenode" do
      block do
        resources("hadoop-hdfs-namenode").run_action(:start)
      end 
    end
```

Additional information can be found in the [Hadoop cookbook wiki](https://github.com/caskdata/hadoop_cookbook/wiki/Wrapping-this-cookbook).


# Requirements

* Chef 11.4.0+
* CentOS 6.4+
* Ubuntu 12.04+


# Cookbook Dependencies

* apt
* yum
* java
* hadoop
* krb5_utils (from https://github.com/caskdata/krb5_utils_cookbook)

# Attributes

There are no attributes specific to this cookbook, however we set many default attributes for the underlying cookbooks in order to have a reasonably configured Hadoop cluster.  Be sure to look at the attributes files and override as desired.


# Usage

Include the relevant recipes in your run-list.


# License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this software except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
