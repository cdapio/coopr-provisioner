# encoding: UTF-8
#
# Copyright © 2012-2015 Cask Data, Inc.
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

require_relative 'spec_helper'
require 'json'

describe Coopr::Plugin::Provider do
  response = IO.read("#{File.dirname(__FILE__)}/task.json")

  # Set these up once
  before :all do
    env = Hash.new
    %w(create confirm delete).each do |taskname|
      instance_variable_set("@task_#{taskname}", JSON.parse(response.gsub('BOOTSTRAP', taskname)))
      instance_variable_set("@provider_#{taskname}", Coopr::Plugin::Provider.new(env, instance_variable_get("@task_#{taskname}")))
    end
  end

  %w(create confirm delete).each do |taskname|
    @task = instance_variable_get("@task_#{taskname}")
    context "when taskName is #{taskname}" do
      describe '#new' do
        it 'creates an instance of Provider' do
          expect(instance_variable_get("@provider_#{taskname}")).to be_an_instance_of Coopr::Plugin::Provider
        end
        it 'creates task instance variable' do
          expect(instance_variable_get("@provider_#{taskname}").task).to eql instance_variable_get("@task_#{taskname}")
        end
        it 'creates empty result hash' do
          expect(instance_variable_get("@provider_#{taskname}").result).to be_empty
        end
      end
    end
  end
end
