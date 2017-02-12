# vagrant-box-repository

Spiking a custom internal Vagrant Box respository to allow versioning without
Atlas.

## Create a vagrant box

Package an [existing box](https://github.com/brydoncheyney/jla-static),

    [box]$ vagrant up
    [box]$ vagrant package --out 1.0.1-lxc.box

## Create the repository

Generate the checksum for the box,

    [box]$ sha256sum 1.0.1-lxc.box
    CHECKSUM BOX

Create a local repository structure,

    [vagrant-box-repository]$ mkdir -p atlas/vagrant/boxes

Move the box into the repository,

    [vagrant-box-repository]$ cp ../box/1.0.1-lxc.box atlas/vagrant/boxes/

Create and configure the metadata for the box respository

    [vagrant-box-repository]$ vi atlas/vagrant/boxes/metadata.json
    {
      "name": "jla/centos6-lxc",
      "description": "jla CentOS 6",
      "versions": [{
        "version": "1.0.1",
        "providers": [{
          "name": "lxc",
          "url": "./atlas/vagrant/boxes/1.0.1-lxc.box",
          "checksum_type": "sha256",
          "checksum": "CHECKSUM"
        }]
      }]
    }

## Configure new vagrantfile 

    [test]$ vi Vagrantfile
    Vagrant.configure("2") do |config|
      config.vm.box = "jla/centos6-lxc"
      config.vm.box_url = './atlas/vagrant/boxes/metadata.json'
      config.vm.box_check_update = true
    
      config.vm.define 'jla-lxc' do |instance|
         if Vagrant.has_plugin?('vagrant-hosts')
           instance.vm.provision :hosts
         end
       end
    
    end

## Start the container

    [test]$ vagrant up
    Bringing machine 'jla-lxc' up with 'lxc' provider...
    ==> jla-lxc: Box 'jla/centos6-lxc' could not be found. Attempting to find and install...
        jla-lxc: Box Provider: lxc
        jla-lxc: Box Version: >= 0
    ==> jla-lxc: Loading metadata for box './atlas/vagrant/boxes/metadata.json'
        jla-lxc: URL: file:///home/brydon/projects/vagrant-box-repository/atlas/vagrant/boxes/metadata.json
    ==> jla-lxc: Adding box 'jla/centos6-lxc' (v1.0.1) for provider: lxc
        jla-lxc: Downloading: ./atlas/vagrant/boxes/1.0.1-lxc.box
        jla-lxc: Calculating and comparing box checksum...
    ==> jla-lxc: Successfully added box 'jla/centos6-lxc' (v1.0.1) for 'lxc'!
    ==> jla-lxc: Importing base box 'jla/centos6-lxc'...
    ==> jla-lxc: Checking if box 'jla/centos6-lxc' is up to date...
    ...
    ==> jla-lxc: Machine booted and ready!

See the box listed by vagrant,

    [test]$ vagrant box list
    jla/centos6-lxc         (lxc, 1.0.1)

## Update vagrant box and add to repository

Make some change to the original box, for example touch a new file. Then,
package the box,

    [box]$ vagrant package --out BOX

Generate the checksum for the box,

    [box]$ sha256sum BOX
    CHECKSUM BOX

Move the box into the repository,

    [vagrant-box-repository]$ cp ../box/1.0.1-lxc.box atlas/vagrant/boxes

Add the latest box to the box repository metadata,

    [vagrant-box-repository]$ vi atlas/vagrant/boxes/metadata.json
    {
      "name": "jla/centos6-lxc",
      "description": "jla CentOS 6",
      "versions": [{
        "version": "1.0.1",
        "providers": [{
          "name": "lxc",
          "url": "./atlas/vagrant/boxes/1.0.1-lxc.box",
          "checksum_type": "sha256",
          "checksum": "CHECKSUM"
        }]},
        {
        "version": "1.0.2",
        "providers": [{
          "name": "lxc",
          "url": "./atlas/vagrant/boxes/1.0.2-lxc.box",
          "checksum_type": "sha256",
          "checksum": "CHECKSUM"
        }]}
      ]
    }

## Test the new box version is identified

    [test]$ vagrant destroy -f
    ==> jla-lxc: Forcing shutdown of container...
    ==> jla-lxc: Destroying VM and associated drives...
    ==> jla-lxc: Running cleanup tasks for 'hosts' provisioner...

    [test]$ vagrant up
    ==> jla-lxc: Importing base box 'jla/centos6-lxc'...
    ==> jla-lxc: Checking if box 'jla/centos6-lxc' is up to date...
    ==> jla-lxc: A newer version of the box 'jla/centos6-lxc' is available! You currently
    ==> jla-lxc: have version '1.0.1'. The latest is version '1.0.2'. Run
    ==> jla-lxc: `vagrant box update` to update.

## Update the installed vagrant box

    [test]$ vagrant box update --box jla/centos6-lxc
    Checking for updates to 'jla/centos6-lxc'
    Latest installed version: 1.0.1
    Version constraints: > 1.0.1
    Provider: lxc
    Updating 'jla/centos6-lxc' with provider 'lxc' from version
    '1.0.1' to '1.0.2'...
    Loading metadata for box 'file:///home/brydon/projects/vagrant-box-repository/atlas/vagrant/boxes/metadata.json'
    Adding box 'jla/centos6-lxc' (v1.0.2) for provider: lxc
    Downloading: ./atlas/vagrant/boxes/1.0.2-lxc.box
    Calculating and comparing box checksum...
    Successfully added box 'jla/centos6-lxc' (v1.0.2) for 'lxc'!

The new box version should now be installed,

    [test]$ vagrant box list
    jla/centos6-lxc         (lxc, 1.0.1)
    jla/centos6-lxc         (lxc, 1.0.2)

## Start the container with the updated vagrant box

Note that updating the vagrant box does not destroy/recreate the machine, so
you'll have to do that to see changes,

    [test]$ vagrant destroy -f
    ==> jla-lxc: Forcing shutdown of container...
    ==> jla-lxc: Destroying VM and associated drives...
    ==> jla-lxc: Running cleanup tasks for 'hosts' provisioner...

    [test]$ vagrant up
    Bringing machine 'jla-lxc' up with 'lxc' provider...
    ==> jla-lxc: Importing base box 'jla/centos6-lxc'...
    ==> jla-lxc: Checking if box 'jla/centos6-lxc' is up to date...
    ==> jla-lxc: Setting up mount entries for shared folders...
    ==> jla-lxc: Starting container...
    ==> jla-lxc: Waiting for machine to boot. This may take a few minutes...
    ==> jla-lxc: Machine booted and ready!
    ==> jla-lxc: Running provisioner: hosts...

## Remove older vagrant box

    [test]$ vagrant box prune --dry-run
    The following boxes will be kept...
    jla/centos6-lxc         (lxc, 1.0.2)

    Checking for older boxes...
    Would remove jla/centos6-lxc lxc 1.0.1
    [test]$ 
