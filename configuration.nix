{ config, lib, pkgs, ... }:

let
  userName = gloopie;
in
{
  imports = 
  [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set a password with passwd
  users.users.${userName} = 
  {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Uncomment for auto login
  #services.getty.autologinUser = userName;
    
  environment.systemPackages =
  [
    # System packages
    pkgs.btop
    pkgs.nano
    pkgs.tmux
    pkgs.wget

    # For downloading from Steam
    pkgs.depotdownloader

    # DepotDownloader dependancy
    pkgs.dotnet-runtime_8

    # Headless client dependancies
    pkgs.freetype
    pkgs.mono
  ];

  services.openssh.enable = true;

  system.stateVersion = "23.11";
}
