pure-ftpd
=========

Installs and configures the `pure-ftpd` daemon. Defines a `pure_ftpd_virtual_user`
provider for configuring ftp users. `pure-ftpd` is run as a user `ftpd`,
so that we don't have to fight with chroot.

Virtual users are not system users. Files uploaded by virtual users are
uploaded to `/var/data/ftp/<username>`, and are owned by the `ftpd` user.

`pure-ftpd` runs with the `--uploadscript` directive. This configures a
named pipe at `/var/run/pure-ftpd/pure-ftpd.upload.pipe`. The file name
of each uploaded pipe is written to this named pipe, so that upload
hooks can easily be written.

## Requirements

Tested on:
* SmartOS


## Usage

```ruby
include_recipe 'pure-ftpd'

pure_ftpd_virtual_user 'my user' do
  username 'my-user'
  password 'my-password'
end
```
