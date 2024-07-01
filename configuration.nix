{ config, lib, pkgs, ... }:

let
  # CHANGE THESE
  nixUsername = "gloopie";
  nixAutoLogin = false;
  betaPassword = "BETAPASSWORD"; # Send /headlessCode to the Resonite Bot for the code
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
  envVars = "";   
  launchArgs = "";
  useRML = false;

  # Everything beyond this point does not need to be configured
  # but for more advanced users feel free to change whatever

  SetupHeadless = if (useRML == true) then pkgs.writeShellScriptBin "SetupHeadless" 
  ''
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
    cd ~/Resonite/Headless/
    rm ./libfreetype6.so
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ./libfreetype.so.6
    mkdir ./Config/
    echo '${resoConfig}' >| ./Config/Config.json
    mkdir ./Libraries/
    mkdir ./rml_config/
    mkdir ./rml_libs/
    mkdir ./rml_mods/
    cd ./Libraries/
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll
    cd ../rml_libs/
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony.dll
  ''
  else pkgs.writeShellScriptBin "SetupHeadless" 
  ''  
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
    cd ~/Resonite/Headless/
    rm ./libfreetype6.so
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ./libfreetype.so.6
    mkdir ./Config/
    echo '${resoConfig}' >| ./Config/Config.json
  '';

  CleanSetupHeadless = if (useRML == true) then pkgs.writeShellScriptBin "CleanSetupHeadless" 
  ''
    rm -r ~/Resonite
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
    cd ~/Resonite/Headless/
    rm ./libfreetype6.so
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ./libfreetype.so.6
    mkdir ./Config/
    echo '${resoConfig}' >| ./Config/Config.json
    mkdir ./Libraries/
    mkdir ./rml_config/
    mkdir ./rml_libs/
    mkdir ./rml_mods/
    cd ./Libraries/
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll
    cd ../rml_libs/
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony.dll
  ''
  else pkgs.writeShellScriptBin "CleanSetupHeadless" 
  ''
    rm -r ~/Resonite
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
    cd ~/Resonite/Headless/
    rm ./libfreetype6.so
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ./libfreetype.so.6
    mkdir ./Config/
    echo '${resoConfig}' >| ./Config/Config.json
  '';

  UpdateHeadless = pkgs.writeShellScriptBin "UpdateHeadless" 
  '' 
    DepotDownloader -app 2519830 -beta headless -betapassword ${betaPassword} -username ${steamUsername} -password ${steamPassword} -dir ~/Resonite/ -validate
  '';

  UpdateConfig = pkgs.writeShellScriptBin "UpdateConfig" 
  '' 
    echo '${resoConfig}' >| ~/Resonite/Headless/Config/Config.json
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

  RunHeadless = if (useRML == true) then pkgs.writeShellScriptBin "RunHeadless"
  '' 
    cd ~/Resonite/Headless/
    ${envVars} mono ./Resonite.exe -LoadAssembly Libraries/ResoniteModLoader.dll ${launchArgs}
  ''
  else pkgs.writeShellScriptBin "RunHeadless"   
  '' 
    cd ~/Resonite/Headless/
    ${envVars} mono ./Resonite.exe ${launchArgs}
  '';
  
  ClearCache = pkgs.writeShellScriptBin "ClearCache"
  ''
    rm -r ~/Resonite/Headless/Cache/
  '';

  ClearDatabase = pkgs.writeShellScriptBin "ClearDatabase"
  ''
    rm -r ~/Resonite/Headless/Data/
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
    UpdateRML
    RunHeadless
    ClearCache
    ClearDatabase
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
