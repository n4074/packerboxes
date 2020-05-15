{ config, pkgs, options, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "20.03";  

  boot = {
    loader.systemd-boot.enable = true; # UEFI - switch to GRUB  if using BIOS
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ ]; # bugfix - https://github.com/NixOS/nixpkgs/issues/5829
  };

  services.sshd.enable = true;

  users.users.root = {
    #initialPassword = "triumvir egan stabile entice success";
    openssh = {
      passwordAuthentication = false;
      authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmOUt0rWo+d893BeoLp+ykyz225wRf8NUg23Mdfb5Y7" ];
    };
  };
}