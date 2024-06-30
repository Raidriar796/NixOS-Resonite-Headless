{ config, lib, pkgs, ... }:

let
  nixUserName = "gloopie";
  betaPassword = "Send /headlessCode to the Resonite Bot for the code";
  steamUsername = "YOURUSERNAME";
  steamPassword = "YOURPASSWORD";
  resoConfig = ''{
    "universeId": null,
    "tickRate": 60.0,
    "maxConcurrentAssetTransfers": 4,
    "usernameOverride": null,
    "loginCredential": null,
    "loginPassword": null,
    "startWorlds": [
      {
        "isEnabled": true,
        "sessionName": null,
        "customSessionId": null,
        "description": null,
        "maxUsers": 16,
        "accessLevel": "Anyone",
        "useCustomJoinVerifier": false,
        "hideFromPublicListing": null,
        "tags": null,
        "mobileFriendly": false,
        "loadWorldURL": null,
        "loadWorldPresetName": "Grid",
        "overrideCorrespondingWorldId": null,
        "forcePort": null,
        "keepOriginalRoles": false,
        "defaultUserRoles": null,
        "roleCloudVariable": null,
        "allowUserCloudVariable": null,
        "denyUserCloudVariable": null,
        "requiredUserJoinCloudVariable": null,
        "requiredUserJoinCloudVariableDenyMessage": null,
        "awayKickMinutes": -1.0,
        "parentSessionIds": null,
        "autoInviteUsernames": null,
        "autoInviteMessage": null,
        "saveAsOwner": null,
        "autoRecover": true,
        "idleRestartInterval": -1.0,
        "forcedRestartInterval": -1.0,
        "saveOnExit": false,
        "autosaveInterval": -1.0,
        "autoSleep": true
      }
    ],
    "dataFolder": null,
    "cacheFolder": null,
    "logsFolder": null,
    "allowedUrlHosts": null,
    "autoSpawnItems": null
  }'';
  
  SetupHeadless = pkgs.writeShellScriptBin "SetupHeadless" 
  ''
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
    rm ~/Resonite/Headless/libfreetype6.so
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ~/Resonite/Headless/libfreetype.so.6
    mkdir ~/Resonite/Headless/Config/
    echo '${resoConfig}' >| ~/Resonite/Headless/Config/Config.json
  '';

  CleanSetupHeadless = pkgs.writeShellScriptBin "CleanSetupHeadless" 
  ''
    rm -r ~/Resonite
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
    rm ~/Resonite/Headless/libfreetype6.so
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ~/Resonite/Headless/libfreetype.so.6
    mkdir ~/Resonite/Headless/Config/
    echo '${resoConfig}' >| ~/Resonite/Headless/Config/Config.json
  '';

  UpdateHeadless = pkgs.writeShellScriptBin "UpdateHeadless" 
  '' 
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
  '';

  UpdateConfig = pkgs.writeShellScriptBin "UpdateConfig" 
  '' 
    echo '${resoConfig}' >| ~/Resonite/Headless/Config/Config.json
  '';

  RunHeadless = pkgs.writeShellScriptBin "RunHeadless" 
  '' 
    cd ~/Resonite/Headless/
    mono ./Resonite.exe
  '';
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

    # Shell scripts
    SetupHeadless
    CleanSetupHeadless
    UpdateHeadless
    UpdateConfig
    RunHeadless
  ];

  services.openssh.enable = true;

  system.stateVersion = "23.11";
}
