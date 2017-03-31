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

module Coopr
  # configuration constants
  PROVISIONER_SERVER_URI = 'provisioner.server.uri'.freeze
  PROVISIONER_BIND_IP = 'provisioner.bind.ip'.freeze
  PROVISIONER_BIND_PORT = 'provisioner.bind.port'.freeze
  PROVISIONER_REGISTER_IP = 'provisioner.register.ip'.freeze
  PROVISIONER_DAEMONIZE = 'provisioner.daemonize'.freeze
  PROVISIONER_DATA_DIR = 'provisioner.data.dir'.freeze
  PROVISIONER_WORK_DIR = 'provisioner.work.dir'.freeze
  PROVISIONER_CAPACITY = 'provisioner.capacity'.freeze
  PROVISIONER_HEARTBEAT_INTERVAL = 'provisioner.heartbeat.interval'.freeze
  PROVISIONER_LOG_DIR = 'provisioner.log.dir'.freeze
  PROVISIONER_LOG_ROTATION_SHIFT_AGE = 'provisioner.log.rotation.shift.age'.freeze
  PROVISIONER_LOG_ROTATION_SHIFT_SIZE = 'provisioner.log.rotation.shift.size'.freeze
  PROVISIONER_LOG_LEVEL = 'provisioner.log.level'.freeze
  PROVISIONER_WORKER_POLL_INTERVAL = 'provisioner.worker.poll.interval'.freeze
  PROVISIONER_WORKER_POLL_ERROR_INTERVAL = 'provisioner.worker.poll.error.interval'.freeze
  TRUST_CERT_PATH = 'trust.cert.path'.freeze
  TRUST_CERT_PASS = 'trust.cert.pass'.freeze

  # api version
  PROVISIONER_API_VERSION = 'v2'.freeze
end
