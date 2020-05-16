{ config, pkgs, options, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "20.03";  

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ ];
  };

  services.openssh = {
    enable = true;
    # Both the CA and host certificates need to be placed here during provisioning
    extraConfig = "TrustedUserCAKeys /etc/ssh/ca.pub\nHostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub";
  };

  users.users.root = {
    initialPassword = "toor"; # initially empty root password
  };
}