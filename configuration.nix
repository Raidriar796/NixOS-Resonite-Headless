{ config, lib, pkgs, ... }:

{
  imports = 
  [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set a password with passwd
  users.users.gloopie = 
  {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # uncomment for auto login
  #services.getty.autologinUser = gloopie;
    
  environment.systemPackages = with pkgs;
  [
    # System packages
    btop
    nano
    tmux
    wget

    # For downloading from Steam
    depotdownloader

    # DepotDownloader dependancy
    dotnet-runtime_8

    # Headless client dependancies
    freetype
    mono
  ];

  services.openssh.enable = true;

  system.stateVersion = "23.11";
}
