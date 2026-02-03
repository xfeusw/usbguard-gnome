{pkgs}: let
  py = pkgs.python3.withPackages (ps:
    with ps; [
      pygobject3
      pycairo
      pyparsing
      dbus-python
      babel
    ]);

  giTypelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0" [
    pkgs.glib
    pkgs.gobject-introspection
    pkgs.gtk3
    pkgs.libnotify
    pkgs.libappindicator-gtk3
    pkgs.pango
    pkgs.gdk-pixbuf
    pkgs.atk
    pkgs.harfbuzz
  ];

  xdgDataDirs = pkgs.lib.makeSearchPath "share" [
    pkgs.gsettings-desktop-schemas
    pkgs.shared-mime-info
    pkgs.hicolor-icon-theme
  ];
in
  pkgs.mkShell {
    name = "usbguard-gnome-dev";

    packages = [
      py
      pkgs.glib
      pkgs.glib.dev
      pkgs.gobject-introspection
      pkgs.gtk3
      pkgs.libnotify
      pkgs.libappindicator-gtk3
      pkgs.dbus
      pkgs.polkit
      pkgs.usbguard
      pkgs.dconf-editor
      pkgs.gettext
    ];

    shellHook = ''
      set -euo pipefail

      export PYTHONNOUSERSITE=1

      export PYTHONPATH="''${PYTHONPATH-}"
      export PYTHONPATH="$PWD/src''${PYTHONPATH:+:}''$PYTHONPATH"

      export GI_TYPELIB_PATH="${giTypelibPath}''${GI_TYPELIB_PATH:+:}$GI_TYPELIB_PATH"
      export XDG_DATA_DIRS="${xdgDataDirs}''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"

      mkdir -p .dev-schemas
      cp -f src/org.gnome.usbguard.gschema.xml .dev-schemas/
      ${pkgs.glib.dev}/bin/glib-compile-schemas .dev-schemas
      export GSETTINGS_SCHEMA_DIR="$PWD/.dev-schemas"

      echo "Dev shell ready."
      echo "Run: python src/usbguard_gnome_applet.py"
    '';
  }
