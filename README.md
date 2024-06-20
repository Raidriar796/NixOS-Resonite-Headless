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
- Downloads all neccesary packages to download, update, and run the Headless

### Planned Functions
- Headless client install
- Headless client updating
- Symlink workarounds
- Resonite Mod Loader install
- Mod fetching
- Docker setup

# Installation

### Install NixOS
1.  If you don't know how already, follow the official [NixOS Installation Guide](<https://nixos.wiki/wiki/NixOS_Installation_Guide>).

### Download the config and rebuild
1. Replace `/etc/nixos/configuration.nix` with the one in this repo, this can be done manually or by directly downloading it, example (requires wget to be installed):
   - `cd /etc/nixos/`
   - `rm configuration.nix`
   - `wget https://raw.githubusercontent.com/Raidriar796/NixOS-Resonite-Headless/main/configuration.nix`

2. Make initial changes to the config. The config is setup to work without any extra changes however you may want to make your own changes for your specific case, such as renaming the non root user or installing extra packages. You can edit the config by running: 
   - `sudo nano /etc/nixos/configuration.nix`

3. Test the config by running:
   - `sudo nixos-rebuild test`

4. Rebuild and restart the system with the following:
   - `sudo nixos-rebuild boot`
   - `sudo reboot -h now`

### Download and run the headless client

1. Run DepotDownloader to download the headless client:
   - `DepotDownloader -app 2519830 -beta headless -betapassword BETAPASSWORD -username YOURUSERNAME -password YOURPASSWORD -dir ~/Resonite/`

2. Add a symbolic link to the system installed FreeType:
   - `rm ~/Resonite/Headless/libfreetype6.so`
   - `ln -s /var/run/current-system/sw/lib/libfreetype.so.6 ~/Resonite/Headless/libfreetype6.so`

3. Test run the headless client:
   - `cd ~/Resonite/Headless`
   - `mono Resonite.exe`

4. If alls working well, you can shutdown the headless with:
   - `shutdown`

### Configure the headless

1. Copy the config:
   - `cd ~/Resonite/Headless/Config`
   - `cp DefaultConfig.json Config.json`

2. Edit the config (login credentials, world url, etc):
   - `nano ./Config.json`

3. Run the headless again to confirm changes:
   - `cd ../`
   - `mono Resonite.exe`

If everything is working up to this point, congrats, you have a functional NixOS Resonite Headless. This guide will change over time and I'll try to make it as simple as possible.
