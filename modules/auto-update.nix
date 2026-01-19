{ config, pkgs, lib, ... }:
let
  cfg = config.autoUpdate;
in {
  options.autoUpdate = {
    enable = lib.mkEnableOption "Enable automatic flake updates";
    
    interval = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "How often to update flakes (daily, weekly, monthly)";
      example = "daily";
    };
    
    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos";
      description = "Path to the flake directory";
    };
    
    autoRebuild = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Automatically rebuild the system after updating (requires sudo/root)";
    };
    
    notifyUser = lib.mkOption {
      type = lib.types.str;
      default = "hunter";
      description = "Username to notify when updates complete";
    };
  };

  config = lib.mkIf cfg.enable {
    # Service to update flakes
    systemd.services.flake-update = {
      description = "Update NixOS flake inputs";
      path = with pkgs; [ nix git ];
      
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        WorkingDirectory = cfg.flakePath;
      };
      
      script = ''
        set -e
        echo "=== Flake Update Started at $(date) ===" | tee -a /var/log/flake-updates.log
        
        # Update flake inputs
        nix flake update ${cfg.flakePath} 2>&1 | tee -a /var/log/flake-updates.log
        
        echo "Flake inputs updated successfully" | tee -a /var/log/flake-updates.log
        
        ${lib.optionalString cfg.autoRebuild ''
          echo "Auto-rebuild enabled, rebuilding system..." | tee -a /var/log/flake-updates.log
          nixos-rebuild switch --flake ${cfg.flakePath} 2>&1 | tee -a /var/log/flake-updates.log
          echo "System rebuild completed" | tee -a /var/log/flake-updates.log
        ''}
        
        echo "=== Flake Update Completed at $(date) ===" | tee -a /var/log/flake-updates.log
        
        # Notify user (optional, requires systemd-notify support)
        ${lib.optionalString (cfg.notifyUser != "") ''
          # Send notification to user's desktop session if available
          if [ -n "$(who | grep ${cfg.notifyUser})" ]; then
            su - ${cfg.notifyUser} -c "DISPLAY=:0 ${pkgs.libnotify}/bin/notify-send 'Flake Update' 'NixOS flake inputs have been updated' --icon=system-software-update" || true
          fi
        ''}
      '';
    };

    # Timer to trigger the update service
    systemd.timers.flake-update = {
      description = "Timer for automatic flake updates";
      wantedBy = [ "timers.target" ];
      
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
        RandomizedDelaySec = "1h";  # Random delay up to 1 hour to avoid all systems updating at once
      };
    };

    # Create log directory
    systemd.tmpfiles.rules = [
      "f /var/log/flake-updates.log 0644 root root - -"
    ];
    
    # Add helpful aliases for managing auto-updates
    environment.shellAliases = {
      flake-update-now = "sudo systemctl start flake-update.service";
      flake-update-status = "sudo systemctl status flake-update.service";
      flake-update-log = "sudo tail -f /var/log/flake-updates.log";
      flake-update-history = "sudo journalctl -u flake-update.service";
    };
  };
}
