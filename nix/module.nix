{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.usbguardGnome;
  pkg = pkgs.callPackage ./package.nix;
in {
  options.services.usbguardGnome = {
    enable = lib.mkEnableOption "USBGuard GNOME UI/applet";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkg;
      description = "Package providing the usbguard-gnome UI/applet.";
    };

    allowPlugdevWithoutAuth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        If true, installs a polkit rule permitting active users in the "plugdev"
        group to control USBGuard without authentication prompts.
      '';
    };

    autostartApplet = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If true, installs a GNOME autostart entry for the applet.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.usbguard.enable = true;

    environment.systemPackages = [cfg.package];

    security.polkit.enable = true;
    security.polkit.extraConfig = lib.mkIf cfg.allowPlugdevWithoutAuth ''
      polkit.addRule(function(action, subject) {
        var allowed = [
          "org.usbguard.Policy1.appendRule",
          "org.usbguard.Policy1.removeRule",
          "org.usbguard.Devices1.applyDevicePolicy",
          "org.usbguard1.setParameter"
        ];
        if (allowed.indexOf(action.id) >= 0 &&
            subject.active && subject.local &&
            subject.isInGroup("plugdev")) {
          return polkit.Result.YES;
        }
      });
    '';

    environment.etc."xdg/autostart/usbguard-gnome-applet.desktop" = lib.mkIf cfg.autostartApplet {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=USBGuard Applet
        Exec=${cfg.package}/bin/usbguard-gnome-applet
        X-GNOME-Autostart-enabled=true
        NoDisplay=false
      '';
    };
  };
}
