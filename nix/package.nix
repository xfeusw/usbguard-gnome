{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  wrapGAppsHook3,
  gobject-introspection,
  glib,
  gtk3,
  libappindicator-gtk3,
  usbguard,
  polkit,
}: let
  py = python3;
in
  py.pkgs.buildPythonApplication rec {
    pname = "usbguard-gnome";
    version = "unstable-26d300b";
    format = "other";

    src = fetchFromGitHub {
      owner = "6E006B";
      repo = "usbguard-gnome";
      rev = "26d300b";
      sha256 = "sha256-dAJqkWwsuYgQRejzHRF1JnvO8ecogZa0MNdxgijD2qg==";
    };

    propagatedBuildInputs = with py.pkgs; [
      pygobject3
      pycairo
      pyparsing
    ];

    nativeBuildInputs = [
      wrapGAppsHook3
      gobject-introspection
      glib
    ];

    buildInputs = [
      gtk3
      libappindicator-gtk3
      usbguard
      polkit
    ];

    buildPhase = ''
      runHook preBuild
      ${py.interpreter} -m compileall -q .
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/usbguard-gnome
      cp -r i18n mo src *.sh README.md *.desktop $out/share/usbguard-gnome/

      mkdir -p $out/share/applications
      cp -v *.desktop $out/share/applications/

      mkdir -p $out/share/glib-2.0/schemas
      cp -v src/org.gnome.usbguard.gschema.xml $out/share/glib-2.0/schemas/

      mkdir -p $out/bin
      cat > $out/bin/usbguard-gnome-window <<EOF
      #!${stdenv.shell}
      exec ${py.interpreter} $out/share/usbguard-gnome/src/usbguard_gnome_window.py "\$@"
      EOF

      cat > $out/bin/usbguard-gnome-applet <<EOF
      #!${stdenv.shell}
      exec ${py.interpreter} $out/share/usbguard-gnome/src/usbguard_gnome_applet.py "\$@"
      EOF

      chmod +x $out/bin/usbguard-gnome-window $out/bin/usbguard-gnome-applet

      runHook postInstall
    '';

    meta = with lib; {
      description = "GNOME UI / applet for USBGuard";
      homepage = "https://github.com/6E006B/usbguard-gnome";
      license = licenses.gpl2Only;
      platforms = platforms.linux;
      mainProgram = "usbguard-gnome-applet";
    };
  }
