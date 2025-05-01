# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  system.autoUpgrade.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  users.users.gen = {
    isNormalUser = true;
    home = "/home/gen";
    shell = pkgs.zsh;
    description = "Gen";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOHJnpnSTNU/qew1h6AUDsmJESPbDG3jFJPFlEW/3KwS gen@gen740.local"
    ];
  };

  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation (final: {
      name = "brcm-firmware";
      src = ./firmware/brcm;
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp ${final.src}/* "$out/lib/firmware/brcm"
      '';
    }))
  ];

  services = {
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
        AllowUsers = null;
        UseDns = true;
        X11Forwarding = true;
        PermitRootLogin = "prohibit-password";
      };
    };
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    xrdp = {
      enable = true;
      defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
      openFirewall = true;
    };

    gnome.gnome-remote-desktop.enable = true;

    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "security" = "user";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "TM" = {
          "path" = "/mnt/Shares/TM";
          "valid users" = "gen";
          "public" = "no";
          "writeable" = "yes";
          "force user" = "gen";
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "ea support" = "yes";
          "create mask" = "0664";
          "directory mask" = "0775";
          "vfs objects" = "fruit catia streams_xattr";
        };
        "Public" = {
          "path" = "/mnt/Shares/Public";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "gen";
          "force group" = "wheel";
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      exports = ''
        /export         0.0.0.0/0(rw,fsid=0,no_subtree_check,no_root_squash) localhost(rw,fsid=0,no_subtree_check)
        /export/TM      0.0.0.0/0(rw,nohide,insecure,no_subtree_check,no_root_squash) localhost(rw,nohide,insecure,no_subtree_check)
        /export/Public  0.0.0.0/0(rw,nohide,insecure,no_subtree_check,no_root_squash) localhost(rw,nohide,insecure,no_subtree_check)
      '';
    };
  };

  fileSystems = {
    "/export/TM" = {
      device = "/dev/disk/by-uuid/cfee3d2b-b4a0-48bf-8f65-ded902686ade";
      fsType = "ext4";
    };
    "/mnt/Shares/TM" = {
      device = "/dev/disk/by-uuid/cfee3d2b-b4a0-48bf-8f65-ded902686ade";
      fsType = "ext4";
    };
    "/export/Public" = {
      device = "/dev/disk/by-uuid/4223dd76-21af-4d1a-8b94-a3a1f0b55064";
      fsType = "ext4";
    };
    "/mnt/Shares/Public" = {
      device = "/dev/disk/by-uuid/4223dd76-21af-4d1a-8b94-a3a1f0b55064";
      fsType = "ext4";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      2049
      111
      4000
      4001
      4002
      20048
    ];
    allowedUDPPorts = [
      2049
      111
      4000
      4001
      4002
      20048
    ];
    allowPing = true;
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  programs.zsh.enable = true;
  programs.git.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
