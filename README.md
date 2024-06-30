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

### Planned Functions
- Resonite Mod Loader install
- Mod fetching
- Docker setup

# Installation & Usage

### Install NixOS
1.  If you don't know how already, follow the official [NixOS Installation Guide](<https://nixos.wiki/wiki/NixOS_Installation_Guide>). A couple of notes about installation:

    - This works best on a fresh install

    - This is intended to be used without a desktop. You can use whichever ISO/installation setup you want but this config is intended for and only tested with non desktop NixOS installations.

    - This assumes you will be using systemd as your boot loader, you will need to change the config to grub yourself if you want to use grub.  

### Download the config and rebuild
1. Replace `/etc/nixos/configuration.nix` with the one in this repo, this can be done manually or by directly downloading it, example (requires wget to be installed):
   - `cd /etc/nixos/`

   - `sudo rm configuration.nix`

   - `sudo wget https://raw.githubusercontent.com/Raidriar796/NixOS-Resonite-Headless/main/configuration.nix`

2. Make initial changes to the config. The config is setup to do most of the leg work but at the very least you need to change the variables at the top of the config, such as renaming the non root user and adding login credentials. Edit the config with:

   - `sudo nano /etc/nixos/configuration.nix`

   Change the following variables:

   - `nixUsername`

   - `betaPassword`

   - `steamUsername`

   - `steamPassword`

   - `resoConfig`

3. Test the config by running:
   - `sudo nixos-rebuild test`

4. Rebuild and restart the system with the following:
   - `sudo nixos-rebuild boot`

   - `sudo reboot -h now`

### Download and run the headless client

1. Use the provided setup command:
   - `SetupHeadless`

2. Run the headless with the provided command
   - `RunHeadless`

### Extra commands

- `CleanSetupHeadless` - completely reinstalls the headless client

- `UpdateHeadless` - updates the headless client

- `UpdateConfig` - updates the headless config after a NixOS rebuild without updating/reinstalling the headless client

If everything is working up to this point, congrats, you have a functional NixOS Resonite Headless. This guide will change over time and I'll try to make it as simple as possible.
