{ config, lib, pkgs, ... }:

let
  # These values require changes for the config to work
  # Change nixUsername to whatever the existing user account name is
  # Send /headlessCode to the Resonite Bot for the beta password
  nixUsername = "nixos";
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

  # These values are optional but are available for extra configuration
  nixAutoLogin = false;
  installDir = "$HOME/";
  envVars = "ionice -n 0";   
  launchArgs = "";
  # The following values are mods which require resoniteModLoader to be true to work
  # Harmony does not support dotnet 9 yet, mods will not work until then.
  # The existing scripts are setup for dotnet 8
  resoniteModLoader = false;  # https://github.com/resonite-modding-group/resonitemodloader
  headlessTweaks = false;     # https://github.com/New-Project-Final-Final-WIP/HeadlessTweaks
  stresslessHeadless = false; # https://github.com/Raidriar796/StresslessHeadless

  # Everything beyond this point does not need to be configured
  # but for more advanced users feel free to change whatever

  # Values
  installRML = if (resoniteModLoader == true) then
  ''
    mkdir ${installDir}Resonite/Headless/Libraries/
    mkdir ${installDir}rml_config/
    ln -s ${installDir}rml_config/ ${installDir}Resonite/Headless/rml_config
    mkdir ${installDir}Resonite/Headless/rml_libs/
    mkdir ${installDir}Resonite/Headless/rml_mods/
    UpdateMods
  '' 
  else '''';

  rmlLaunchArg = if (resoniteModLoader == true) then "-LoadAssembly Libraries/ResoniteModLoader.dll" else "";

  installHeadlessTweaks = if (resoniteModLoader == true) then
  if (headlessTweaks == true) then 
  ''
    rm ${installDir}Resonite/Headless/rml_mods/HeadlessTweaks.dll
    wget https://github.com/New-Project-Final-Final-WIP/HeadlessTweaks/releases/latest/download/HeadlessTweaks.dll -P ${installDir}Resonite/Headless/rml_mods/
  ''
  else "rm ${installDir}Resonite/Headless/rml_mods/HeadlessTweaks.dll"
  else "";

  installStresslessHeadless  = if (resoniteModLoader == true) then
  if (stresslessHeadless == true) then
  ''
    rm ${installDir}Resonite/Headless/rml_mods/StresslessHeadless.dll
    wget https://github.com/Raidriar796/StresslessHeadless/releases/latest/download/StresslessHeadless.dll -P ${installDir}Resonite/Headless/rml_mods/ 
  ''
  else "rm ${installDir}Resonite/Headless/rml_mods/StresslessHeadless.dll"
  else "";

  # Shell scripts
  UpdateHeadless = pkgs.writeShellScriptBin "UpdateHeadless" 
  '' 
    steamcmd +force_install_dir ${installDir}Resonite +login ${steamUsername} ${steamPassword} +app_license_request 2519830 +app_update 2519830 -beta headless -betapassword ${betaPassword} validate +quit
  '';

  UpdateConfig = pkgs.writeShellScriptBin "UpdateConfig" 
  '' 
    echo '${resoConfig}' >| ${installDir}Resonite/Headless/Config/Config.json
  '';

  SetupHeadless = pkgs.writeShellScriptBin "SetupHeadless" 
  ''
    UpdateHeadless
    rm ${installDir}Resonite/Headless/libfreetype6.so
    ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ${installDir}Resonite/Headless/libfreetype6.so
    mkdir ${installDir}Resonite/Headless/Config/
    ${installRML}
    UpdateConfig
  '';

  CleanSetupHeadless = pkgs.writeShellScriptBin "CleanSetupHeadless" 
  ''
    rm -r ${installDir}Resonite/
    SetupHeadless
  '';

  UpdateMods = if (resoniteModLoader == true) then pkgs.writeShellScriptBin "UpdateMods"
  ''
    rm ${installDir}Resonite/Headless/Libraries/ResoniteModLoader.dll
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll -P ${installDir}Resonite/Headless/Libraries/
    rm ${installDir}Resonite/Headless/rml_libs/0Harmony-Net8.dll
    wget https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony-Net8.dll -P ${installDir}Resonite/Headless/rml_libs/
    ${installHeadlessTweaks}
    ${installStresslessHeadless}
  ''
  else pkgs.writeShellScriptBin "UpdateMods"
  '' 
    echo "Resonite Mod Loader is not enabled, set resoniteModLoader to true in configuration.nix, rebuild, then run SetupHeadless or CleanSetupHeadless to enable Resonite Mod Loader"
  '';

  RunHeadless = pkgs.writeShellScriptBin "RunHeadless"
  ''
    cd ${installDir}Resonite/Headless/
    ${envVars} dotnet ./Resonite.dll ${rmlLaunchArg} ${launchArgs}
  '';

  UpdateNixos = pkgs.writeShellScriptBin "UpdateNixos"
  ''
    sudo nix-channel --update
    sudo nixos-rebuild switch
    nix-collect-garbage
    sudo nix-store --optimize
  '';

  AsciiArt = 
  '' 
    $4          ▗▄▄▄       $5▗▄▄▄▄    ▄▄▄▖
    $4          ▜███▙       $5▜███▙  ▟███▛
    $4           ▜███▙       $5▜███▙▟███▛
    $4            ▜███▙       $5▜██████▛
    $4     ▟█████████████████▙ $5▜████▛     $6▟▙
    $4    ▟███████████████████▙ $5▜███▙    $6▟██▙
    $3           ▄▄▄▄▖           $5▜███▙  $6▟███▛
    $3          ▟███▛             $5▜██▛ $6▟███▛
    $3         ▟███▛               $5▜▛ $6▟███▛
    $3▟███████████▛                  $6▟██████████▙
    $3▜██████████▛                  $6▟███████████▛
    $3      ▟███▛ $2▟▙               $6▟███▛
    $3     ▟███▛ $2▟██▙             $6▟███▛
    $3    ▟███▛  $2▜███▙           $6▝▀▀▀▀
    $3    ▜██▛    $2▜███▙ $1▜██████████████████▛
    $3     ▜▛     $2▟████▙ $1▜████████████████▛
    $2           ▟██████▙       $1▜███▙
    $2          ▟███▛▜███▙       $1▜███▙
    $2         ▟███▛  ▜███▙       $1▜███▙
    $2         ▝▀▀▀    ▀▀▀▀▘       $1▀▀▀▘
  '';
in
{
  imports = 
  [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
  {
    options =
    [
      "noatime"
    ];
  };

  fileSystems."/tmp" =
  { 
    fsType = "tmpfs";
    options =
    [
      "defaults"
      "noatime"
      "mode=1777"
    ];
  };

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
    pkgs.steamcmd

    # Headless client dependancies
    pkgs.freetype
    pkgs.dotnetCorePackages.dotnet_9.runtime

    # Shell scripts
    CleanSetupHeadless
    RunHeadless
    SetupHeadless
    UpdateConfig
    UpdateHeadless
    UpdateMods
    UpdateNixos
  ];

  programs.bash.shellAliases = 
  {
    ClearCache = "rm -r ${installDir}Resonite/Headless/Cache/*";
    ClearData = "rm -r ${installDir}Resonite/Headless/Data/*";
    ClearLogs = "rm -r ${installDir}Resonite/Headless/Logs/*";
    ClearModConfigs = "rm -r ${installDir}rml_config/*";
    fastfetch = "echo '${AsciiArt}' >| /tmp/GloopieNixosLogo.txt && fastfetch -l /tmp/GloopieNixosLogo.txt --logo-color-1 red --logo-color-2 yellow --logo-color-3 green --logo-color-4 cyan --logo-color-5 blue --logo-color-6 magenta";
  };

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "24.11";
}
