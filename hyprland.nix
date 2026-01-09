{ config, pkgs, lib, ... }:
{
  options = {
    hyprland.enable = lib.mkEnableOption "Enable Omarchy-style Hyprland config";
  };

  config = lib.mkIf config.hyprland.enable {
    environment.systemPackages = with pkgs; [
      hyprland alacritty brave nautilus yazi lazygit lazydocker neovim feh libva-utils zsh btop powertop bluetui networkmanager waybar swww
    ];
    users.defaultUserShell = pkgs.zsh;
    environment.etc = {
      "xdg/hypr/hyprland.conf".text = ''
        source = /etc/xdg/hypr/autostart.conf
        source = /etc/xdg/hypr/bindings.conf
        source = /etc/xdg/hypr/looknfeel.conf
        source = /etc/xdg/hypr/windows.conf
        source = /etc/xdg/hypr/monitors.conf
        source = /etc/xdg/hypr/input.conf
      '';
      "xdg/hypr/looknfeel.conf".text = ''
        general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)
          resize_on_border = false
          allow_tearing = false
          layout = dwindle
        }
        decoration {
          rounding = 0
          shadow {
            enabled = true
            range = 2
            render_power = 3
            color = rgba(1a1a1aee)
          }
          blur {
            enabled = true
            size = 3
            passes = 1
            vibrancy = 0.17
          }
        }
        animations {
          enabled = yes, please :)
          bezier = easeOutQuint,0.23,1,0.32,1
          bezier = easeInOutCubic,0.65,0.05,0.36,1
          bezier = linear,0,0,1,1
          bezier = almostLinear,0.5,0.5,0.75,1.0
          bezier = quick,0.15,0,0.1,1
          animation = global, 1, 10, default
          animation = border, 1, 5.39, easeOutQuint
          animation = windows, 1, 4.79, easeOutQuint
          animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
          animation = windowsOut, 1, 1.49, linear, popin 87%
          animation = fadeIn, 1, 1.73, almostLinear
        }
        dwindle {
          preserve_split = true
          force_split = 2
        }
        master {
          new_status = master
        }
        misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
          focus_on_activate = true
        }
      '';
      "xdg/hypr/input.conf".text = ''
        input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =
          follow_mouse = 1
          repeat_rate = 40
          repeat_delay = 600
          sensitivity = 0
          touchpad {
            natural_scroll = true
            clickfinger_behavior = false
            scroll_factor = 0.4
          }
        }
        windowrule = scrolltouchpad 1.5, class:Alacritty
      '';
      "xdg/hypr/bindings.conf".text = ''
        $terminal = alacritty
        $browser = brave
        bind = SUPER, Return, exec, $terminal
        bind = SUPER, E, exec, nautilus --new-window
        bind = SUPER, B, exec, $browser
        bind = SUPER, N, exec, $terminal -e nvim ~/Documents/Notes
        bind = SUPER, Y, exec, $terminal -e yazi
        bind = SUPER, L, exec, $terminal -e lazygit
        bind = SUPER, C, exec, $terminal -e lazydocker
      '';
      "xdg/hypr/autostart.conf".text = ''
        exec-once = waybar &
        exec-once = swww-daemon &
        exec-once = bluetui &
      '';
      "xdg/hypr/windows.conf".text = ''
        windowrule = float, class:^(pavucontrol|blueman-manager|nm-connection-editor)$
        windowrule = size 1200 800, class:^(firefox|brave)$
      '';
      "xdg/hypr/monitors.conf".text = ''
        monitor=,preferred,auto,1
      '';
    };
  };
}
