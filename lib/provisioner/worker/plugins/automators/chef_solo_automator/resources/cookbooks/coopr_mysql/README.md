# coopr_mysql cookbook

## Usage

This cookbook wraps the mysql 8.x series (and up) cookbook, to provide an attribute-driven method for Coopr services to provision MySql databases.  More specifically, it transforms an attribute tree into a call to the [mysql_service resource](https://github.com/chef-cookbooks/mysql#mysql_service).

For example, the following JSON:

```
{
  "coopr_mysql": {
    "mysql_service": {
      "example": {
        "bind_address": "0.0.0.0",
        "port": "3307",
        "initial_root_password": "change me"
      }
    }
  }
}
```

when run with the ``default`` recipe, will be translated to the following resource call:

```
mysql_service 'example' do
  bind_address '0.0.0.0'
  port '3307'
  initial_root_passord 'change me'
end
```

and result in a named Mysql instance ``mysql-example``.

Additionally, the attribute:

```
{
  "coopr_mysql": {
    "action": "start"
  }
}
```
will cause it to also create the ``mysql-example`` service and run the ``:start`` action.

In a coopr context, this json can be stored in either a service or a clustertemplate.  The ``action`` attribute can be used for stop and start actions.


## Platform-specific repository setup

In the 8.x mysql cookbook series, it is the user's responsibility to configure the appropriate repositories if necessary.  Currently, the
``yum-mysql-community`` cookbook is implemented for the rhel, fedora, and amazon platform families.  On these platforms, the example JSON
above would be translated to the following resource call:

```
mysql_service 'example' do
  bind_address '0.0.0.0'
  port '3307'
  initial_root_passord 'change me'
  version node['coopr_mysql']['yum_mysql_community']['default_version']
end
```

Additionally, the appropriate recipe from the ``yum-mysql-community`` cookbook would be run.

A ``{ "coopr_mysql": { "mysql_service": { "example": { "version": "X.Y" }}}}`` attributed could also be specified in the JSON
and it will take precedence over the ``default_version`` cookbook attribute.  Note that this would be a platform-specific attribute
and would therefore require restricting the Coopr clustertemplate to the appropriate platform(s).
