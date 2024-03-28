<h1 align="center">
	<logo>
        NixOS Resonite Headless
        <br>
		<img src="./Logo/nix-resoflake.svg" width="256" height="256">
	</logo>
</h1>

This is an experimental NixOS configuration to quickly setup headless clients for Resonite. This is very work in progress and assumes (for now) that you're already familiar with NixOS.

*Feedback and suggestions are welcome!*

# Current and Planned Functions

## Current Functions
- Downloads all neccesary packages to download, update, and run the Headless

## Planned Functions
- Headless client install
- Headless client updating
- Symlink workarounds
- Resonite Mod Loader install
- Mod fetching
- Optional Cumulo setup
- Multi client management

# Known Issues
- You need to manually add a symlink of the system installed `libfreetype.so.6` to the Headless directory with the same name
