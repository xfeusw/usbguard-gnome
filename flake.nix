{
  description = "USBGuard GNOME for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        nixosModules.default = import ./nix/module.nix;

        nixosModules.usbguard-gnome = import ./nix/module.nix;
      };

      perSystem = {
        pkgs,
        lib,
        system,
        ...
      }: let
        isLinux = pkgs.stdenv.hostPlatform.isLinux;
        pkg = pkgs.callPackage ./nix/package.nix {};
        shell = import ./nix/shell.nix {inherit pkgs;};
      in {
        formatter = pkgs.nixfmt-rfc-style;

        devShells.default = shell;

        packages = {
          usbguard-gnome =
            if isLinux
            then pkg
            else
              pkgs.writeTextDir "share/doc/usbguard-gnome/README"
              "usbguard-gnome is Linux-only (depends on GTK/Polkit/usbguard).";
          default = lib.mkIf isLinux pkg;
        };

        apps = lib.mkIf isLinux {
          usbguard-gnome-applet = {
            type = "app";
            program = "${pkg}/bin/usbguard-gnome-applet";
          };
          usbguard-gnome-window = {
            type = "app";
            program = "${pkg}/bin/usbguard-gnome-window";
          };
          default = {
            type = "app";
            program = "${pkg}/bin/usbguard-gnome-applet";
          };
        };
      };
    };
}
