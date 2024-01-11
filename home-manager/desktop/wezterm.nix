{ config, lib, pkgs, ... }:

let
  cfg = config.home-manager.desktop.wezterm;
in
{
  options.home-manager.desktop.wezterm = {
    enable = lib.mkEnableOption "WezTerm config" // {
      default = config.home-manager.desktop.enable;
    };
    fullscreenOnStartup = lib.mkEnableOption "automatically fullscreen on startup" // {
      default = true;
    };
    fontSize = lib.mkOption {
      type = lib.types.float;
      description = "Font size.";
      default = 12.0;
    };
    opacity = lib.mkOption {
      type = lib.types.float;
      description = "Background opacity.";
      default = 0.9;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      wezterm = {
        enable = true;
        extraConfig =
          let
            inherit (config.home-manager.desktop.theme) fonts colors;
          in
          with colors; /* lua */''
            local act = wezterm.action
            local config = wezterm.config_builder()

            ${lib.optionalString cfg.fullscreenOnStartup /* lua */ ''
              local mux = wezterm.mux
              -- Automatically maximize window on startup
              wezterm.on("gui-startup", function()
                local tab, pane, window = mux.spawn_window{}
                window:gui_window():maximize()
              end)
            ''}

            config.audible_bell = "Disabled"
            config.color_scheme = "Builtin Pastel Dark"
            config.enable_kitty_keyboard = true
            config.font = wezterm.font("${fonts.symbols.name}")
            config.font_size = ${toString cfg.fontSize}
            config.hide_tab_bar_if_only_one_tab = true
            config.scrollback_lines = 10000
            config.window_background_opacity = ${toString cfg.opacity}
            config.colors = {
              foreground = "${base05}",
              background = "${base00}",
              cursor_bg = "${base05}",
              cursor_border = "${base05}",
              cursor_fg = "${base00}",
              selection_bg = "${base02}",
              selection_fg = "${base05}",
            };
            config.keys = {
              -- Clears the scrollback and viewport, and then sends CTRL-L to ask the
              -- shell to redraw its prompt
              {
                key = 'K',
                mods = 'CTRL|SHIFT',
                action = act.Multiple {
                  act.ClearScrollback 'ScrollbackAndViewport',
                  act.SendKey { key = 'L', mods = 'CTRL' },
                },
              },
            }
            config.mouse_bindings = {
              -- Change the default click behavior so that it only selects
              -- text and doesn't open hyperlinks
              {
                event = { Up = { streak = 1, button = 'Left' } },
                mods = 'NONE',
                action = act.CompleteSelection 'ClipboardAndPrimarySelection',
              },
              -- Bind 'Up' event of CTRL-Click to open hyperlinks
              {
                event = { Up = { streak = 1, button = 'Left' } },
                mods = 'CTRL',
                action = act.OpenLinkAtMouseCursor,
              },
              -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
              {
                event = { Down = { streak = 1, button = 'Left' } },
                mods = 'CTRL',
                action = act.Nop,
              },
              -- Scrolling up while holding CTRL increases the font size
              {
                event = { Down = { streak = 1, button = { WheelUp = 1 } } },
                mods = 'CTRL',
                action = act.IncreaseFontSize,
              },

              -- Scrolling down while holding CTRL decreases the font size
              {
                event = { Down = { streak = 1, button = { WheelDown = 1 } } },
                mods = 'CTRL',
                action = act.DecreaseFontSize,
              },
            }

            return config
          '';
      };

      zsh.initExtra = lib.mkIf config.programs.zsh.enable /* bash */ ''
        # Do not enable those alias in non-wezterm terminal
        if [[ -n "$WEZTERM_EXECUTABLE_DIR" ]]; then
          alias imgcat="$WEZTERM_EXECUTABLE_DIR/bin/wezterm imgcat"
        fi
      '';
    };
  };
}
