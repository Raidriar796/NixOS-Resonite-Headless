{ config, lib, pkgs, ... }:

{
    imports = 
        [
            ./hardware-configuration.nix
        ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    
    environment.systemPackages = with pkgs;
        [
            # System packages
            nano
            wget
            tmux

            # DepotDownloader dependancy
            dotnet-runtime_8

            # For downloading from Steam
            depotdownloader

            # Headless client dependancies
            mono
            freetype
        ];

    system.stateVersion = "23.11";
}
