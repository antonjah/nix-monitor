{
  description = "Nix Monitor - A DankMaterialShell plugin for monitoring Nix store and home-manager generations";

  outputs =
    { self, ... }:
    {
      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        with lib;
        let
          cfg = config.programs.nix-monitor;

          configFile = pkgs.writeText "nix-monitor-config.json" (
            builtins.toJSON {
              rebuildCommand = cfg.rebuildCommand;
              gcCommand = cfg.gcCommand;
              updateInterval = cfg.updateInterval;
            }
          );
        in
        {
          options.programs.nix-monitor = {
            enable = mkEnableOption "Nix Monitor plugin for DankMaterialShell";

            rebuildCommand = mkOption {
              type = types.listOf types.str;
              default = [
                "/usr/bin/bash"
                "-l"
                "-c"
                "cd ~/.config/home-manager && home-manager switch -b backup --impure --flake .#home 2>&1"
              ];
              description = "Command to run for system rebuild";
              example = literalExpression ''
                [ "/usr/bin/bash" "-l" "-c" "nixos-rebuild switch --flake .#hostname" ]
              '';
            };

            gcCommand = mkOption {
              type = types.listOf types.str;
              default = [
                "/usr/bin/bash"
                "-l"
                "-c"
                "nix-collect-garbage -d 2>&1"
              ];
              description = "Command to run for garbage collection";
              example = literalExpression ''
                [ "/usr/bin/bash" "-l" "-c" "nix-collect-garbage --delete-older-than 30d" ]
              '';
            };

            updateInterval = mkOption {
              type = types.int;
              default = 300;
              description = "Update interval in seconds for refreshing statistics";
              example = 600;
            };
          };

          config = mkIf cfg.enable {
            home.file.".config/DankMaterialShell/plugins/NixMonitor" = {
              source = self;
              recursive = true;
            };

            home.file.".config/DankMaterialShell/plugins/NixMonitor/config.json" = {
              source = configFile;
            };
          };
        };

      dmsPlugin = self;
    };
}
