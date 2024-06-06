# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
        :box_name => "alma",
  },
}
Vagrant.configure("2") do |config|
      config.vm.define "boxname" do |box|
          box.vm.box = "alma"
       end
#         box.vm.disk :disk, size: "1GB", name: "extra_storage"
#	  (0..4).each do |i|
# 	     box.vm.disk :disk, size: "250MB", name: "disk-#{i}"
#    	end
#	end

	  config.vm.provision "shell", path: "script.sh"
  end
