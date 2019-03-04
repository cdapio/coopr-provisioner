#
# Cookbook Name:: coopr_dns
# Recipe:: google
#
# Copyright (C) 2013-2018 Cask Data, Inc.
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

# Required DNS credential attributes:
#   - project: GCP project containing the Cloud DNS domain
#   - managed_zone: the resource name of the managed zone
#   - dns_name: the DNS name of the managed zone
#   - json_key: the service account JSON key with DNS read/write permissions

# must be located in either:
#   - node['google']['gdns']
#   - databag specified by:
#     - node['coopr_dns']['google']['gdns']['databag_name']
#     - node['coopr_dns']['google']['gdns']['databag_item']

# Setup some variables
fqdn = node['coopr']['hostname'] ? node['coopr']['hostname'] : node['fqdn']
subdomain = fqdn.split('.', 2).last
access_v4 = node['coopr']['ipaddresses']['access_v4'] ? node['coopr']['ipaddresses']['access_v4'] : node['ipaddress']

# Do not register "private" domains
case subdomain
when 'local', 'novalocal', 'internal'
  subdomain = node['coopr_dns']['default_domain'] ? node['coopr_dns']['default_domain'] : 'local'
else
  # Do not register provider-based domains
  subdomain = 'provider' if subdomain =~ /amazonaws.com$/
end

# Only register whitelisted subdomains if they are set
subdomain_whitelist = node['coopr_dns']['subdomain_whitelist']

if subdomain_whitelist.nil? || subdomain_whitelist.include?(subdomain)
  # determine where to pull all credentials from
  if node.key?('google') && node['google'].key?('gdns') && \
     %w[project managed_zone dns_name json_key].map { |x| node['google']['gdns'].key?(x) && !node['google']['gdns'][x].nil? }.all?
    gdns = node['google']['gdns']
  else
    begin
      bag = node['coopr_dns']['google']['gdns']['databag_name']
      item = node['coopr_dns']['google']['gdns']['databag_item']
      gdns = data_bag_item(bag, item)
      raise StandardError unless %w[project managed_zone dns_name json_key].map { |x| gdns.key?(x) && !gdns[x].nil? }.all?
    rescue StandardError
      Chef::Application.fatal!('You must specify all google gdns credentials in either a data bag or in node["google"]["gdns"]')
    end
  end

  begin
    # write key to file, since google_gauth resources expect file path
    file "#{Chef::Config[:file_cache_path]}/gdnskey.json" do
      owner 'root'
      group 'root'
      mode '0400'
      content gdns['json_key'].to_json
    end
  rescue StandardError
    Chef::Application.fatal!('Unable to extract Google Cloud DNS key from attributes or databag. Ensure json_key is in proper format')
  end

  # Sets credential
  gauth_credential 'coopr-dns-service-account-creds' do
    action :serviceaccount
    path "#{Chef::Config[:file_cache_path]}/gdnskey.json"
    scopes [
      'https://www.googleapis.com/auth/ndev.clouddns.readwrite'
    ]
  end

  # Sets managed zone, must match the existing managed zone in GCP, which must match the Coopr dnsSuffix
  gdns_managed_zone gdns['managed_zone'] do
    action :nothing
    dns_name gdns['dns_name']
    credential 'coopr-dns-service-account-creds'
    project gdns['project']
  end

  # Create record set
  # Retry with random delay. GDNS API is atomic, and there is a possibility of collisions with other provisioners
  # https://cloud.google.com/dns/docs/troubleshooting#preconditionfailed
  gdns_resource_record_set "#{fqdn}." do
    action :create
    managed_zone gdns['managed_zone']
    type 'A'
    ttl node['coopr_dns']['default_ttl']
    target [
      access_v4
    ]
    project gdns['project']
    credential 'coopr-dns-service-account-creds'
    not_if { subdomain == 'local' || subdomain == 'provider' }
    retries 5
    retry_delay 5 + rand(15)
  end
end
