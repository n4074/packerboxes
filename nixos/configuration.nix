{ config, pkgs, options, ... }:

let 
  unstable = builtins.fetchGit {
    url = https://github.com/nixos/nixpkgs;
    #sha256 = "0p98dwy3rbvdp6np596sfqnwlra11pif3rbdh02pwdyjmdvkmbvd";
    ref = "master";
  };
in  
{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.vmware.guest.enable = true;

  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
      unstable = import unstable {
        config = config.nixpkgs.config;
      };
    };

  };

  system.stateVersion = "20.03";  

  nix.nixPath =
    # prepend default nixpath values.
    options.nix.nixPath.default ++ 
    # append our nixpkgs-overlays.
    [ "nixpkgs-overlays=/etc/nixos/overlays/" ]
  ;


  boot = {
    loader.systemd-boot.enable = true; # UEFI - switch to GRUB  if using BIOS
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ ]; # bugfix - https://github.com/NixOS/nixpkgs/issues/5829
  };

  services.sshd.enable = true;

  users.users.root = {
    initialPassword = "triumvir egan stabile entice success"; # initially empty root password
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmOUt0rWo+d893BeoLp+ykyz225wRf8NUg23Mdfb5Y7" ];
  };
}