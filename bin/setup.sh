#!/usr/bin/env bash
#
# Copyright © 2012-2016 Cask Data, Inc.
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

# Configurable variables
TIMEOUT=3
export COOPR_API_USER=${COOPR_API_USER:-admin}
export COOPR_API_KEY=${COOPR_API_KEY:-1234567890abcdef}
export COOPR_TENANT=${COOPR_TENANT:-superadmin}
export COOPR_SERVER_URI=${COOPR_SERVER_URI:-http://localhost:55054}
export COOPR_HOME=${COOPR_HOME:-/opt/coopr}
export COOPR_RUBY=${COOPR_RUBY:-${COOPR_HOME}/provisioner/embedded/bin/ruby}

export COOPR_PROVISIONER_PLUGIN_DIR=${COOPR_PROVISIONER_PLUGIN_DIR:-${COOPR_HOME}/provisioner/lib/worker/plugins}


wait_for_plugin_registration () {
  RETRIES=0
  until [[ $(curl --silent --request GET \
    --output /dev/null --write-out "%{http_code}" \
    --header "Coopr-UserID:${COOPR_API_USER}" \
    --header "Coopr-TenantID:${COOPR_TENANT}" \
    --header "Coopr-ApiKey:${COOPR_API_KEY}" \
    --insecure \
    ${COOPR_SERVER_URI}/v2/plugins/automatortypes/chef-solo 2> /dev/null) -eq 200 || ${RETRIES} -gt 60 ]]; do
    sleep 2
    let "RETRIES++"
  done

  if [ ${RETRIES} -gt 60 ]; then
    echo "ERROR: Provisioner did not successfully register plugins"
    return 1
  fi
}

load_bundled_data ( ) {
  __skriptz=$(ls -1 ${COOPR_PROVISIONER_PLUGIN_DIR}/*/*/load-bundled-data.sh 2>&1)
  if [ "${__skriptz}" != "" ]; then
    for __i in ${__skriptz}; do
      ${__i} || return 1
    done
  else
    echo "ERROR: Cannot find any load-bundled-data.sh scripts to execute"
    return 1
  fi
  return 0
}

# Register provisioner
${COOPR_HOME}/provisioner/bin/provisioner.sh register || exit 1
wait_for_plugin_registration || exit 1

# Load plugin-bundled data
load_bundled_data || exit 1

# Request sync
curl --silent --request POST \
  --header "Content-Type:application/json" \
  --header "Coopr-UserID:${COOPR_API_USER}" \
  --header "Coopr-ApiKey:${COOPR_API_KEY}" \
  --header "Coopr-TenantID:${COOPR_TENANT}" \
  --connect-timeout ${TIMEOUT} \
  --insecure \
  ${COOPR_SERVER_URI}/v2/plugins/sync
__ret=${?}
[[ ${__ret} -ne 0 ]] && exit 1
exit 0
