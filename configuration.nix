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
            nano
            wget
            mono
            steamPackages.steamcmd
            freetype
        ];

    nixpkgs.config.allowUnfree = true;

    system.stateVersion = "23.11";
}
