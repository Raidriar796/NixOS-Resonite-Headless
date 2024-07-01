{ config, lib, pkgs, ... }:

let
  # These values require changes for the config to work
  # Change nixUsername to whatever the existing user account name is
  # Send /headlessCode to the Resonite Bot for the beta password
  nixUsername = "gloopie";
  betaPassword = "BETAPASSWORD";
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

  # These values are optional but are available for extra
  nixAutoLogin = false;
  envVars = "";   
  launchArgs = "";
  useRML = false;

  # Everything beyond this point does not need to be configured
  # but for more advanced users feel free to change whatever

  # Values
  RMLLaunchArg = if (useRML == true) then "-LoadAssembly Libraries/ResoniteModLoader.dll" else "";

  # Shell scripts for the user
  UpdateHeadless = pkgs.writeShellScriptBin "UpdateHeadless" 
  '' 
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
  '';

  UpdateConfig = pkgs.writeShellScriptBin "UpdateConfig" 
  '' 
    echo '${resoConfig}' >| ~/Resonite/Headless/Config/Config.json
  '';

  SetupHeadless = pkgs.writeShellScriptBin "SetupHeadless" 
  ''
    UpdateHeadless
    cd ~/Resonite/Headless/
    rm ./libfreetype6.so
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ./libfreetype.so.6
    mkdir ./Config/
    UpdateConfig
    Automation.InstallRML
  '';

  CleanSetupHeadless = pkgs.writeShellScriptBin "CleanSetupHeadless" 
  ''
    rm -r ~/Resonite
    SetupHeadless
  '';

  UpdateRML = if (useRML == true) then pkgs.writeShellScriptBin "UpdateRML"
  ''
    cd ~/Resonite/Headless/Libraries/
    rm ResoniteModLoader.dll
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll
    cd ../rml_libs/
    rm 0Harmony.dll
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony.dll
  ''
  else pkgs.writeShellScriptBin "UpdateRML"
  '' 
    echo "Resonite Mod Loader is not enabled, set useRML to true in configuration.nix, rebuild, then run SetupHeadless or CleanSetupHeadless to enable Resonite Mod loader"
  '';
  
  ClearCache = pkgs.writeShellScriptBin "ClearCache"
  ''
    rm -r ~/Resonite/Headless/Cache/
  '';

  ClearDatabase = pkgs.writeShellScriptBin "ClearDatabase"
  ''
    rm -r ~/Resonite/Headless/Data/
  '';

  RunHeadless = pkgs.writeShellScriptBin "RunHeadless"
  '' 
    cd ~/Resonite/Headless/
    ${envVars} mono ./Resonite.exe ${RMLLaunchArg} ${launchArgs}
  '';

  # Shell scripts for automation
  Automation.InstallRML = if (useRML == true) then pkgs.writeShellScriptBin "Automation.InstallRML"
  ''
    mkdir ./Libraries/
    mkdir ./rml_config/
    mkdir ./rml_libs/
    mkdir ./rml_mods/
    UpdateRML
  '' 
  else pkgs.writeShellScriptBin "InstallRML" '''';
in
{
  imports = 
  [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set a password with passwd
  users.users.${nixUsername} = 
  {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  services.getty.autologinUser = if (nixAutoLogin == true) then nixUsername else null;
      
  environment.systemPackages =
  [
    # System packages
    pkgs.btop
    pkgs.fastfetch
    pkgs.nano
    pkgs.wget

    # For downloading from Steam
    pkgs.depotdownloader

    # DepotDownloader dependancy
    pkgs.dotnet-runtime_8

    # Headless client dependancies
    pkgs.freetype
    pkgs.mono

    # Shell scripts for the user
    CleanSetupHeadless
    ClearCache
    ClearDatabase
    RunHeadless
    SetupHeadless
    UpdateConfig
    UpdateHeadless
    UpdateRML
    
    # Shell scripts to help automation
    Automation.InstallRML
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
