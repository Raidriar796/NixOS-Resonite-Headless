<h1 align="center">
	<logo>
        NixOS Resonite Headless
        <br>
		<img src="./Logo/nix-resoflake.svg" width="256" height="256">
	</logo>
</h1>

This is an experimental NixOS configuration to quickly setup headless clients for Resonite. This is very work in progress and assumes (for now) that you're already familiar with NixOS to some degree.

*Feedback and suggestions are welcome!*

# Current and Planned Functions

### Current Functions
- Downloads all neccesary software and dependancies
- Headless client installation, reinsallation, and update commands
- [Resonite Mod Loader](<https://github.com/resonite-modding-group/resonitemodloader>) installation
- Mod installation, currently supported mods:
  - [Headless Tweaks](<https://github.com/New-Project-Final-Final-WIP/HeadlessTweaks>)
  - [Outflow](<https://github.com/BlueCyro/Outflow>)
  - [Stressless Headless](<https://github.com/Raidriar796/StresslessHeadless>)
- ARM support (WIP)  

### Planned Functions
- Docker setup
- Flake for non NixOS systems

# Installation & Usage

### Install NixOS
1. If you don't know how already, follow the official [NixOS Installation Guide](<https://nixos.wiki/wiki/NixOS_Installation_Guide>). A couple of notes about installation:

   - This works best on a fresh install

   - This is intended to be used without a desktop. You can use whichever ISO/installation setup you want but this config is intended for and only tested with non desktop NixOS installations.

   - This assumes you will be using systemd as your boot loader, you will need to change the config to grub yourself if you want to use grub.

   - If you're installing manually or with the minimal ISO, you can install the system off of the Resonite Headless config instead of switching configs after install

2. Ensure `/etc/nixos/hardware-configuration.nix` is configured how you want:

   - I highly recommend using `noatime` to help with R/W performance as Resonite likes to cache a lot of small files, which can *really* slow down R/W If you would like files to still have access time but still want some benefit, you can use `nodiratime` instead. example of how to do so:
   ```
   fileSystems."/" =
     { 
       device = "/dev/disk/by-uuid/[YourRootDiskUUID]";
       fsType = "ext4";
       options = [ "noatime" ];
     };
   ```

   - I recommend setting /tmp to be a tmpfs if it's not already, like so:
   ```
     fileSystems."/tmp" =
     { 
       fsType = "tmpfs";
       options = [ "defaults" "noatime" "mode=1777" ];
     };
   ```

### Download the config and rebuild
1. Replace `/etc/nixos/configuration.nix` with the one in this repo, this can be done manually or by directly downloading it, example:

   - `sudo rm /etc/nixos/configuration.nix`

   - For x86/x64: `sudo curl -L -o "/etc/nixos/configuration.nix" "https://raw.githubusercontent.com/Raidriar796/NixOS-Resonite-Headless/main/configuration-x86_64-linux.nix"`

   - For ARM: `sudo curl -L -o "/etc/nixos/configuration.nix" "https://raw.githubusercontent.com/Raidriar796/NixOS-Resonite-Headless/main/configuration-aarch64-linux.nix"`

2. Make initial changes to the config. The config is setup to do most of the leg work but at the very least you need to change the values at the top of the config, such as renaming the non root user and adding login credentials. Edit the config with:

   - `sudo nano /etc/nixos/configuration.nix`

   Required:

   - `nixUsername`

   - `betaPassword`

   - `steamUsername`

   - `steamPassword`

   - `resoConfig`

   Required for ARM:
   
   - `systemThreads`

   Optional:

   - `nixAutoLogin`

   - `envVars`

   - `launchArgs`

   - `resoniteModLoader`

   - `headlessTweaks`

   - `outflow`

   - `stresslessHeadless`

3. Test the config by running:
   - `sudo nixos-rebuild test`

4. If there are no issues, rebuild the system with the following:
   - `sudo nixos-rebuild switch`

### Download and run the headless client

1. Use the provided setup command:
   - `SetupHeadless`
     - Note: this does not fully setup the headless for ARM yet, you will need to manually recompile FreeImage and Crunch. I'd recommend following [this guide](<https://github.com/BlueCyro/Resonite-Headless-on-ARM-instructions>)

2. Run the headless with the provided command
   - `RunHeadless`

### Extra commands

- `CleanSetupHeadless` - Completely reinstalls the headless client

- `ClearCache` - Clears the Cache folder

- `ClearData` - Clears the Data folder

- `ClearLogs` - Clears the Logs folder

- `ClearModConfigs` - Clears the rml_config folder

- `UpdateConfig` - Updates the headless config after a NixOS rebuild without updating/reinstalling the headless client

- `UpdateHeadless` - Updates the headless client

- `UpdateMods` - Updates Resonite Mod Loader and mods enabled through the system config

- `UpdateNixos` - Updates and cleans the system

### Preinstalled programs

- `btop` - Resource monitor

- `fastfetch` - Quick system info view

- `tmux` - Terminal session manager

- `wget` - File downloader

If everything is working up to this point, congrats, you have a functional NixOS Resonite Headless. This guide will change over time and I'll try to make it as simple as possible.
