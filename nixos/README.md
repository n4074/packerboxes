PACKER_ROOT_PASSWD=<secret_password> packer build -debug -var ssh_ca_pub_key=/Users/carl/.ssh/ca.pub -on-error=ask nixos.json
