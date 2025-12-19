# Nix Monitor

![](./assets/scrot.png)

A [DankMaterialShell](https://danklinux.com/) plugin for monitoring Nix store disk usage and home-manager generations with integrated system management capabilities.

## Features

### Bar Widget Display
- Generation count - Shows number of home-manager generations
- Store size - Displays current Nix store disk usage
- Visual warnings - Icon and text turn red when store exceeds threshold
- Auto-updates - Refreshes every 5 minutes (configurable)

### Detailed Popout Panel
Click the widget to open a detailed view with:
- Summary cards - Large stat cards for generations and store size
- Warning banner - Appears when store size exceeds threshold
- Real-time console - View command output as it runs
- Action buttons:
  - Refresh - Update statistics immediately
  - Rebuild - Run `home-manager switch` to rebuild your system
  - GC - Run `nix-collect-garbage -d` to free up space

### Configurable Settings
Access via DMS Settings → Plugins → Nix Monitor:
- Show/hide generation count
- Show/hide store size
- Update interval (60-3600 seconds)
- Warning threshold (10-200 GB)

## Installation

### As a Flake Input

Add to your `flake.nix`:

```nix
{
  inputs = {
    dms-nix-monitor = {
      url = "github:antonjah/nixmonitor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, dms-nix-monitor, ... }: {
    homeConfigurations."youruser" = home-manager.lib.homeManagerConfiguration {
      modules = [
        dms-nix-monitor.homeManagerModules.default
        {
          programs.nix-monitor = {
            enable = true;
            
            updateInterval = 300;
            
            rebuildCommand = [ 
              "/usr/bin/bash" "-l" "-c" 
              "cd ~/.config/home-manager && home-manager switch -b backup --impure --flake .#home 2>&1"
            ];
            
            gcCommand = [ 
              "/usr/bin/bash" "-l" "-c" 
              "nix-collect-garbage -d 2>&1" 
            ];
          };
        }
      ];
    };
  };
}
```

### Activation

1. Rebuild your home-manager configuration: `home-manager switch --flake .#home`
2. Restart DMS: `dms restart`
3. Open DMS Settings → Plugins
4. Click "Scan for Plugins"
5. Toggle "Nix Monitor" ON
6. Add to your DankBar layout

### Updating

After updating the plugin:
```bash
nix flake update nix-monitor
home-manager switch --flake .#home --impure
rm -rf ~/.cache/quickshell/qmlcache/
dms restart
```

**Note:** Due to QML disk caching with Nix symlinks, you must clear the QML cache after plugin updates for changes to take effect.

## Usage

### Bar Widget
- The widget shows in your DankBar with an icon, generation count, and store size
- Click to open the detailed popout panel
- Color changes to red when store exceeds threshold

### Popout Panel
- Refresh - Updates all statistics immediately
- Rebuild - Runs `home-manager switch -b backup --impure --flake .#home`
- GC - Runs `nix-collect-garbage -d`

### Console Output
- Appears automatically when running Rebuild or GC
- Shows real-time stdout/stderr
- Auto-scrolls to latest output
- Click "Clear" to hide

## Customization

### Via Flake Options (Recommended)

Configure commands in your home-manager flake:

```nix
programs.nix-monitor = {
  enable = true;
  
  updateInterval = 600;
  
  rebuildCommand = [ 
    "/usr/bin/bash" "-l" "-c" 
    "cd /path/to/config && nixos-rebuild switch --flake .#hostname 2>&1"
  ];
  
  gcCommand = [ 
    "/usr/bin/bash" "-l" "-c" 
    "nix-collect-garbage --delete-older-than 30d 2>&1" 
  ];
};
```

**Available Options:**
- `updateInterval` - Update interval in seconds for refreshing statistics (default: 300)
- `rebuildCommand` - Command to run for system rebuild (default: home-manager switch)
- `gcCommand` - Command to run for garbage collection (default: nix-collect-garbage -d)

### Via QML File (For Development)

If not using the flake module, edit `NixMonitor.qml` directly and modify the default command properties.

## Requirements

- DankMaterialShell >= 1.0.0
- Nix package manager
- home-manager
- Bash

## License

MIT

## Author

Anton Andersson ([@antonjah](https://github.com/antonjah))
