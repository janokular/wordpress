Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.hostname = "wordpress"
  config.vm.network "private_network", ip: "10.23.45.60"
  config.vm.provision "shell", path: "install.sh"
end