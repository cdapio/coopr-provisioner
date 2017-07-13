# coopr_mysql cookbook

## Usage

This cookbook wraps the mysql 8.x series (and up) cookbook, to provide an attribute-driven method for Coopr services to provision MySql databases.  More specifically, it transforms an attribute tree into a call to the [mysql_service resource](https://github.com/chef-cookbooks/mysql#mysql_service).

For example, the following JSON:

```
{
  "coopr_database": {
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
  "coopr_database": {
    "action": "start"
  }
}
```
will cause it to also create the ``mysql-example`` service and start it.

In a coopr context, this json can be stored in either a service or a clustertemplate.  The ``action`` attribute can be used for stop and start actions.
