Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.define "wordpress" do |wordpress|
    wordpress.vm.hostname = "wordpress"
    wordpress.vm.network "private_network", ip: "10.23.45.60"
    
    wordpress.vm.provision "shell", path: ".provision/setup.sh"
  end
end