# -*- mode: ruby -*-
# vi: set ft=ruby :

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
