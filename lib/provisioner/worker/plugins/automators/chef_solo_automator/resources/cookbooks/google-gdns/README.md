# Google Cloud DNS Chef Cookbook

This cookbook provides the built-in types and services for Chef to manage
Google Cloud DNS resources, as native Chef types.

## Requirements

### Platforms

#### Supported Operating Systems

This cookbook was tested on the following operating systems:

* RedHat 6, 7
* CentOS 6, 7
* Debian 7, 8
* Ubuntu 12.04, 14.04, 16.04, 16.10
* SLES 11-sp4, 12-sp2
* openSUSE 13
* Windows Server 2008 R2, 2012 R2, 2012 R2 Core, 2016 R2, 2016 R2 Core

## Example

```ruby
gauth_credential 'mycred' do
  action :serviceaccount
  path ENV['CRED_PATH'] # e.g. '/path/to/my_account.json'
  scopes [
    'https://www.googleapis.com/auth/ndev.clouddns.readwrite'
  ]
end

gdns_managed_zone 'testzone-3-com' do
  action :create
  dns_name 'test.somewild-example.com.'
  description 'Test Example Zone'
  credential 'mycred'
  project 'google.com:graphite-playground'
end

gdns_resource_record_set 'www.testzone-4.com.' do
  action :create
  managed_zone 'testzone-3-com'
  type 'A'
  ttl 600
  target [
    '10.1.2.3',
    '40.5.6.7',
    '80.9.10.11'
  ]
  project 'google.com:graphite-playground'
  credential 'mycred'
end
```

## Credentials

All Google Cloud Platform cookbooks use an unified authentication mechanism,
provided by the `google-gauth` cookbook. Don't worry, it is automatically
installed when you install this module.

### Example

```ruby
gauth_credential 'mycred' do
  action :serviceaccount
  path ENV['CRED_PATH'] # e.g. '/path/to/my_account.json'
  scopes [
    'https://www.googleapis.com/auth/ndev.clouddns.readwrite'
  ]
end

```

For complete details of the authentication cookbook, visit the
[google-gauth][] cookbook documentation.

## Resources

* [`gdns_managed_zone`](#gdns_managed_zone) -
    A zone is a subtree of the DNS namespace under one administrative
    responsibility. A ManagedZone is a resource that represents a DNS zone
    hosted by the Cloud DNS service.
* [`gdns_project`](#gdns_project) -
    A project resource. The project is a top level container for resources
    including Cloud DNS ManagedZones.
* [`gdns_resource_record_set`](#gdns_resource_record_set) -
    A unit of data that will be returned by the DNS servers.


### gdns_managed_zone
A zone is a subtree of the DNS namespace under one administrative
responsibility. A ManagedZone is a resource that represents a DNS zone
hosted by the Cloud DNS service.


#### Example

```ruby
gdns_managed_zone 'testzone-3-com' do
  action :create
  dns_name 'test.somewild-example.com.'
  description 'Test Example Zone'

  # You can also set output-only values as well. Chef will ignore the values
  # when creating the resource, but will assert that its value matches what you
  # specified.
  #
  # This important to ensure that, for example, the top-level registrar is using
  # the correct DNS server names. Although this can cause failures in a run from
  # a clean project, it is useful to ensure that there are no mismatches in the
  # different services.
  #
  # id 579_667_184_320_567_887
  # name_servers [
  #   'ns-cloud-b1.googledomains.com.',
  #   'ns-cloud-b2.googledomains.com.',
  #   'ns-cloud-b3.googledomains.com.',
  #   'ns-cloud-b4.googledomains.com.'
  # ]
  # creation_time '2016-12-02T04:59:24.333Z'

  project 'google.com:graphite-playground'
  credential 'mycred'
end

```

#### Reference

```ruby
gdns_managed_zone 'id-for-resource' do
  creation_time   time
  description     string
  dns_name        string
  id              integer
  name            string
  name_server_set [
    string,
    ...
  ]
  name_servers    [
    string,
    ...
  ]
  project         string
  credential      reference to gauth_credential
end
```

#### Actions

* `create` -
  Converges the `gdns_managed_zone` resource into the final
  state described within the block. If the resource does not exist, Chef will
  attempt to create it.
* `delete` -
  Ensures the `gdns_managed_zone` resource is not present.
  If the resource already exists Chef will attempt to delete it.

#### Properties

* `description` -
  A mutable string of at most 1024 characters associated with this
  resource for the user's convenience. Has no effect on the managed
  zone's function.

* `dns_name` -
  The DNS name of this managed zone, for instance "example.com.".

* `id` -
  Output only. Unique identifier for the resource; defined by the server.

* `name` -
  Required. User assigned name for this resource.
  Must be unique within the project.

* `name_servers` -
  Output only. Delegate your managed_zone to these virtual name servers;
  defined by the server

* `name_server_set` -
  Optionally specifies the NameServerSet for this ManagedZone. A
  NameServerSet is a set of DNS name servers that all host the same
  ManagedZones. Most users will leave this field unset.

* `creation_time` -
  Output only. The time that this resource was created on the server.
  This is in RFC3339 text format.

#### Label
Set the `mz_label` property when attempting to set primary key
of this object. The primary key will always be referred to by the initials of
the resource followed by "_label"

### gdns_project
A project resource. The project is a top level container for resources
including Cloud DNS ManagedZones.


#### Example

```ruby
# Ensures a project exists and has the correct values.
#
# All project settings are read-only, yet we are setting them anyway. Chef will
# use these values to check if they match, and fail the run otherwise.
#
# This important to ensure that your project quotas are set properly and avoid
# discrepancies from it to fail in production.
gdns_project 'google.com:graphite-playground' do
  quota_managed_zones 10_000
  quota_total_rrdata_size_per_change 100_000
  project 'google.com:graphite-playground'
  credential 'mycred'
end

```

#### Reference

```ruby
gdns_project 'id-for-resource' do
  number                             integer
  quota_managed_zones                integer
  quota_resource_records_per_rrset   integer
  quota_rrset_additions_per_change   integer
  quota_rrset_deletions_per_change   integer
  quota_rrsets_per_managed_zone      integer
  quota_total_rrdata_size_per_change integer
  project                            string
  credential                         reference to gauth_credential
end
```

#### Actions

* `create` -
  Converges the `gdns_project` resource into the final
  state described within the block. If the resource does not exist, Chef will
  attempt to create it.
* `delete` -
  Ensures the `gdns_project` resource is not present.
  If the resource already exists Chef will attempt to delete it.

#### Properties

* `number` -
  Output only. Unique numeric identifier for the resource; defined by the
  server.

* `quota_managed_zones` -
  Output only. Maximum allowed number of managed zones in the project.

* `quota_resource_records_per_rrset` -
  Output only. Maximum allowed number of ResourceRecords per
  ResourceRecordSet.

* `quota_rrset_additions_per_change` -
  Output only. Maximum allowed number of ResourceRecordSets to add per
  ChangesCreateRequest.

* `quota_rrset_deletions_per_change` -
  Output only. Maximum allowed number of ResourceRecordSets to delete per
  ChangesCreateRequest.

* `quota_rrsets_per_managed_zone` -
  Output only. Maximum allowed number of ResourceRecordSets per zone in the
  project.

* `quota_total_rrdata_size_per_change` -
  Output only. Maximum allowed size for total rrdata in one
  ChangesCreateRequest
  in bytes.

#### Label
Set the `p_label` property when attempting to set primary key
of this object. The primary key will always be referred to by the initials of
the resource followed by "_label"

### gdns_resource_record_set
A unit of data that will be returned by the DNS servers.

#### Example

```ruby
# The property managed_zone below needs to match a gdns_managed_zone recipe
# block executed before it
gdns_resource_record_set 'www.testzone-4.com.' do
  action :create
  managed_zone 'testzone-4-com'
  type 'A'
  ttl 600
  target [
    '10.1.2.3',
    '40.5.6.7',
    '80.9.10.11'
  ]
  project 'google.com:graphite-playground'
  credential 'mycred'
end

gdns_resource_record_set 'sites.testzone-4.com.' do
  action :create
  managed_zone 'testzone-4-com'
  type 'CNAME'
  target ['www.testzone-4.com.']
  project 'google.com:graphite-playground'
  credential 'mycred'
end

```

#### Reference

```ruby
gdns_resource_record_set 'id-for-resource' do
  managed_zone reference to gdns_managed_zone
  name         string
  target       [
    string,
    ...
  ]
  ttl          integer
  type         'A', 'AAAA', 'CAA', 'CNAME', 'MX', 'NAPTR', 'NS', 'PTR', 'SOA', 'SPF', 'SRV' or 'TXT'
  project      string
  credential   reference to gauth_credential
end
```

#### Actions

* `create` -
  Converges the `gdns_resource_record_set` resource into the final
  state described within the block. If the resource does not exist, Chef will
  attempt to create it.
* `delete` -
  Ensures the `gdns_resource_record_set` resource is not present.
  If the resource already exists Chef will attempt to delete it.

#### Properties

* `name` -
  Required. For example, www.example.com.

* `type` -
  Required. One of valid DNS resource types.

* `ttl` -
  Number of seconds that this ResourceRecordSet can be cached by
  resolvers.

* `target` -
  As defined in RFC 1035 (section 5) and RFC 1034 (section 3.6.1)

* `managed_zone` -
  Required. A reference to ManagedZone resource

#### Label
Set the `rrs_label` property when attempting to set primary key
of this object. The primary key will always be referred to by the initials of
the resource followed by "_label"

[google-gauth]: https://supermarket.chef.io/cookbooks/google-gauth
