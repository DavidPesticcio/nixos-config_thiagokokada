{ super, config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/theme.nix
  ];

  theme = {
    fonts = {
      gui = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      icons = {
        package = pkgs.font-awesome_6;
        name = [
          "Font Awesome 6 Brands"
          "Font Awesome 6 Free Solid"
        ];
      };
    };
    colors = with builtins; fromJSON (readFile ./colors.json);
    wallpaper.path = lib.mkDefault pkgs.wallpapers.hatsune-miku_walking-4k;
  };

  # Enable fonts in home.packages to be available to applications
  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs; [
      config.theme.fonts.gui.package
      config.theme.fonts.icons.package
      dejavu_fonts
      gnome.gnome-themes-extra
      hack-font
      hicolor-icon-theme
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # needed for QT_QPA_PLATFORMTHEME=kde
      libsForQt5.plasma-integration
      libsForQt5.systemsettings
    ];

    pointerCursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };

    sessionVariables.QT_QPA_PLATFORMTHEME = "kde";
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };
    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = "Nordzy-dark";
    };
    theme = {
      name = "Nordic-bluish-accent";
      package = pkgs.nordic;
    };
  };

  xdg = {
    configFile.kdeglobals.text = lib.generators.toINI { } {
      General = {
        ColorScheme = "nordicbluish";
        Name = "nordic-bluish";
        shadeSortColumn = true;
      };
      Icons = {
        Theme = config.gtk.iconTheme.name;
      };
      KDE = {
        LookAndFeelPackage = "Nordic-bluish";
        contrast = 4;
      };
    };

    dataFile = {
      color-schemes = {
        source = "${pkgs.nordic}/share/color-schemes";
        recursive = true;
      };
      plasma = {
        source = "${pkgs.nordic}/share/plasma";
        recursive = true;
      };
    };
  };

  # https://github.com/GNOME/gsettings-desktop-schemas/blob/8527b47348ce0573694e0e254785e7c0f2150e16/schemas/org.gnome.desktop.interface.gschema.xml.in#L276-L296
  dconf.settings = lib.optionalAttrs (super ? fonts.fontconfig) {
    # hide ibus systray icon, kinda buggy in waybar
    "desktop/ibus/panel".show-icon-on-systray = false;
    "org/gnome/desktop/interface" = with super.fonts.fontconfig; {
      "font-antialiasing" =
        if antialias then
          if (subpixel.rgba == "none")
          then "grayscale"
          else "rgba"
        else "none";
      "font-hinting" = builtins.replaceStrings [ "hint" ] [ "" ] hinting.style;
      "font-rgba-order" = subpixel.rgba;
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = with config; {
      # When running, most GNOME/GTK+ applications prefer those settings
      # instead of *.ini files
      "Net/IconThemeName" = gtk.iconTheme.name;
      "Net/ThemeName" = gtk.theme.name;
      "Gtk/CursorThemeName" = xsession.pointerCursor.name;
    } // lib.optionalAttrs (super ? fonts.fontconfig) {
      # Applications like Java/Wine doesn't use Fontconfig settings,
      # but uses it from here
      "Xft/Antialias" = super.fonts.fontconfig.antialias;
      "Xft/Hinting" = super.fonts.fontconfig.hinting.enable;
      "Xft/HintStyle" = super.fonts.fontconfig.hinting.style;
      "Xft/RGBA" = super.fonts.fontconfig.subpixel.rgba;
      "Xft/lcdfilter" = super.fonts.fontconfig.subpixel.lcdfilter;
    };
  };
}
