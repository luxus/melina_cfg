{ config, lib, pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        device = "nodev";
        efiSupport = true;
      };
    };
  };

  fonts = {
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "JetBrainsMono Nerd Font" "Cascadia Code" ];
        sansSerif = [ "Arimo Nerd Font" ];
        serif = [ "Arimo Nerd Font" ];
      };
      includeUserConf = false;
    };
    fonts = with pkgs; [
      cascadia-code
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "Arimo" "JetBrainsMono" ]; })
      source-han-sans
    ];
  };

  gtk.iconCache.enable = true;

  hardware = {
    acpilight.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    pulseaudio.enable = true;
  };

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  networking = {
    firewall.enable = false;
    hostName = "nixos";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager = {
      enable = true;
      dns = "none";
      ethernet.macAddress = "random";
      wifi = {
        backend = "iwd";
        macAddress = "random";
      };
    };
    useDHCP = false;
  };

  programs = {
    command-not-found.enable = false;
    dconf.enable = true;
    ssh.askPassword = "";
    steam.enable = true;
  };

  services = {
    blueman.enable = true;
    gnome3.at-spi2-core.enable = true;
    logind.lidSwitch = "ignore";
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      enableCtrlAltBackspace = true;
      inputClassSections = [''
        Identifier "pointer configuration"
        MatchIsPointer "true"
        Option "TransformationMatrix" "1 0 0 0 1 0 0 0 0.3"
      ''];
      libinput = {
        enable = true;
        accelProfile = "flat";
        accelSpeed = "0";
        tapping = false;
      };
      serverFlagsSection = ''
        Option "BlankTime" "0"
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "0"
      '';
      windowManager.awesome = {
        enable = true;
        noArgb = true;
      };
    };
  };

  system = {
    autoUpgrade = {
      enable = true;
      dates = "01:00";
    };
    stateVersion = "21.03";
  };

  systemd.services.nixos-upgrade.script = let
    dir = "${config.users.users.figsoda.home}/dotfiles";
    rebuild = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild";
  in lib.mkForce ''
    ${config.nix.package}/bin/nix flake update ${dir} --{recreate,commit}-lock-file
    ${rebuild} switch --flake ${dir} --impure
  '';

  time.timeZone = "America/New_York";

  users.users.figsoda = {
    extraGroups = [ "audio" "networkmanager" "video" "wheel" ];
    isNormalUser = true;
    shell = "${pkgs.fish}/bin/fish";
  };
}