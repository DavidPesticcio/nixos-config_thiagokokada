{ config, lib, ... }:

{
  options.home-manager.desktop.wezterm.enable = lib.mkEnableOption "WezTerm config" // {
    default = config.home-manager.desktop.enable;
  };

  config = lib.mkIf config.home-manager.desktop.wezterm.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = with config.home-manager.desktop.theme.fonts.symbols; /* lua */''
        local act = wezterm.action
        local config = wezterm.config_builder()

        config.audible_bell = "Disabled"
        config.color_scheme = "Builtin Pastel Dark"
        config.enable_kitty_keyboard = true
        config.font = wezterm.font("${name}")
        config.font_size = 12.0
        config.hide_tab_bar_if_only_one_tab = true
        config.scrollback_lines = 10000
        config.window_background_opacity = 0.9
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
  };
}
