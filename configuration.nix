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
    "tickRate": 30.0,
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
        "loadWorldURL": null,
        "loadWorldPresetName": "Grid",
        "forcePort": null,
        "keepOriginalRoles": false,
        "defaultUserRoles": null,
        "awayKickMinutes": -1.0,
        "idleRestartInterval": -1.0,
        "forcedRestartInterval": -1.0
      }
    ]
  }'';

  # These values are optional but are available for extra
  nixAutoLogin = false;
  envVars = "";   
  launchArgs = "";
  cacheFolder = "/home/${nixUsername}/Cache/";
  dataFolder = "/home/${nixUsername}/Data/";
  logFolder = "/home/${nixUsername}/Logs/";
  # The following values are mods which require resoniteModLoader to be true to work
  resoniteModLoader = false;  # https://github.com/resonite-modding-group/resonitemodloader
  headlessTweaks = false;     # https://github.com/New-Project-Final-Final-WIP/HeadlessTweaks
  outflow = false;            # https://github.com/BlueCyro/Outflow
  stresslessHeadless = false; # https://github.com/Raidriar796/StresslessHeadless

  # Everything beyond this point does not need to be configured
  # but for more advanced users feel free to change whatever

  # Values
  installRML = if (resoniteModLoader == true) then
  ''
    mkdir ./Libraries/
    mkdir ~/rml_config/
    ln -s ~/rml_config/ ./rml_config
    mkdir ./rml_libs/
    mkdir ./rml_mods/
    UpdateMods
  '' 
  else '''';

  rmlLaunchArg = if (resoniteModLoader == true) then "-LoadAssembly Libraries/ResoniteModLoader.dll" else "";

  installHeadlessTweaks = if (resoniteModLoader == true) then
  if (headlessTweaks == true) then "wget https://github.com/New-Project-Final-Final-WIP/HeadlessTweaks/releases/latest/download/HeadlessTweaks.dll" else "rm HeadlessTweaks.dll"
  else "";

  installOutflow = if (resoniteModLoader == true) then
  if (outflow == true) then "wget https://github.com/BlueCyro/Outflow/releases/latest/download/Outflow.dll" else "rm Outflow.dll"
  else "";

  installStresslessHeadless  = if (resoniteModLoader == true) then
  if (stresslessHeadless == true) then "wget https://github.com/Raidriar796/StresslessHeadless/releases/latest/download/StresslessHeadless.dll" else "rm StresslessHeadless.dll"
  else "";

  # Shell scripts
  UpdateHeadless = pkgs.writeShellScriptBin "UpdateHeadless" 
  '' 
    steamcmd +force_install_dir ~/Resonite +login ${steamUsername} ${steamPassword} +app_license_request 2519830 +app_update 2519830 -beta headless -betapassword ${betaPassword} validate +quit
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
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ./libfreetype6.so
    mkdir ./Config/
    mkdir ${cacheFolder}  
    ln -s ${cacheFolder} ./Cache
    mkdir ${dataFolder}
    ln -s ${dataFolder} ./Data
    mkdir ${logFolder}
    ln -s ${logFolder} ./Logs
    ${installRML}
    UpdateConfig
  '';

  CleanSetupHeadless = pkgs.writeShellScriptBin "CleanSetupHeadless" 
  ''
    rm -r ~/Resonite
    SetupHeadless
  '';

  FullCleanSetupHeadless = pkgs.writeShellScriptBin "FullCleanSetupHeadless" 
  ''
    rm -r ${cacheFolder}
    rm -r ${dataFolder}
    rm -r ${logFolder}
    CleanSetupHeadless
  '';

  UpdateMods = if (resoniteModLoader == true) then pkgs.writeShellScriptBin "UpdateMods"
  ''
    cd ~/Resonite/Headless/Libraries/
    rm ResoniteModLoader.dll
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll
    cd ../rml_libs/
    rm 0Harmony.dll
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony-Net8.dll
    cd ../rml_mods/
    ${installHeadlessTweaks}
    ${installOutflow}
    ${installStresslessHeadless}   
  ''
  else pkgs.writeShellScriptBin "UpdateMods"
  '' 
    echo "Resonite Mod Loader is not enabled, set resoniteModLoader to true in configuration.nix, rebuild, then run SetupHeadless or CleanSetupHeadless to enable Resonite Mod Loader"
  '';
  
  ClearCache = pkgs.writeShellScriptBin "ClearCache"
  ''
    rm -r ${cacheFolder}
    mkdir ${cacheFolder}
    rm ~/Resonite/Headless/Cache
    ln -s ${cacheFolder} ~/Resonite/Headless/Cache
  '';

  ClearData = pkgs.writeShellScriptBin "ClearData"
  ''
    rm -r ${dataFolder}
    mkdir ${dataFolder}
    rm ~/Resonite/Headless/Data
    ln -s ${cacheFolder} ~/Resonite/Headless/Data
  '';

  ClearLogs = pkgs.writeShellScriptBin "ClearLogs"
  ''
    rm -r ${logFolder}
    mkdir ${logFolder}
    rm ~/Resonite/Headless/Logs
    ln -s ${cacheFolder} ~/Resonite/Headless/Logs
  '';

  RunHeadless = pkgs.writeShellScriptBin "RunHeadless"
  '' 
    cd ~/Resonite/Headless/
    ${envVars} dotnet ./Resonite.dll ${rmlLaunchArg} ${launchArgs}
  '';

  UpdateNixos = pkgs.writeShellScriptBin "UpdateNixos"
  ''
    sudo nix-channel --update
    sudo nixos-rebuild switch
    nix-collect-garbage
    sudo nix-store --optimize
  '';
in
{
  imports = 
  [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.${nixUsername} = 
  {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  services.getty.autologinUser = if (nixAutoLogin == true) then nixUsername else null;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages =
  [
    # System packages
    pkgs.btop
    pkgs.fastfetch
    pkgs.nano
    pkgs.tmux 
    pkgs.wget

    # For downloading from Steam
    pkgs.steamPackages.steamcmd

    # Headless client dependancies
    pkgs.freetype
    pkgs.dotnet-runtime_8

    # Shell scripts
    CleanSetupHeadless
    ClearCache
    ClearData
    ClearLogs
    FullCleanSetupHeadless
    RunHeadless
    SetupHeadless
    UpdateConfig
    UpdateHeadless
    UpdateMods
    UpdateNixos
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
