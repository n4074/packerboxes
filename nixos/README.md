PACKER_ROOT_PASSWD=<secret_password> packer build -debug -var ssh_ca_pub_key=<path_to_ssh_ca> -on-error=ask nixos.json
