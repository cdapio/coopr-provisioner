# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # We *need* vagrant-omnibus for these box images
  config.omnibus.chef_version = '11.16.4'

  # Enable berkshelf plugin
  config.berkshelf.enabled = true

  # Run Multi-Machine environment to test both OSs
  # http://docs.vagrantup.com/v2/multi-machine/index.html

  %w(
    centos-6.5
    ubuntu-12.04
  ).each do |platform|
    config.vm.define platform do |c|
      c.vm.box       = "opscode-#{platform}"
      c.vm.box_url   = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_#{platform}_chef-provisionerless.box"
      c.vm.host_name = "impala-#{platform}.local"
    end
  end

  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ['modifyvm', :id, '--memory', '2048']
  end

  # Ubuntu needs this, but global provisioners run first
  config.vm.provision :shell, :inline => 'test -x /usr/bin/apt-get && sudo apt-get update ; exit 0'

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      },
      :hive => {
        :hive_site => {
          'hive.metastore.uris' => 'thrift://localhost:9093'
        }
      }
    }

    chef.run_list = [
      'recipe[hadoop::hadoop_hdfs_namenode]',
      'recipe[hadoop::hadoop_hdfs_datanode]',
      'recipe[hadoop::hive_metastore]',
      'recipe[impala::catalog]',
      'recipe[impala::server]',
      'recipe[impala::shell]',
      'recipe[impala::state_store]'
    ]
  end
end
