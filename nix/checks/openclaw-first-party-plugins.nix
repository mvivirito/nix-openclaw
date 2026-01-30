{ lib, pkgs }:

let
  stubModule = { lib, ... }: {
    options = {
      assertions = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [];
      };

      home.homeDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/tmp";
      };

      home.packages = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [];
      };

      home.file = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };

      home.activation = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };

      launchd.agents = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };

      systemd.user.services = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };

      programs.git.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  eval = lib.evalModules {
    modules = [
      stubModule
      ../modules/home-manager/openclaw.nix
      ({ lib, options, ... }: {
        config = {
          home.homeDirectory = "/tmp";
          programs.git.enable = false;
          programs.openclaw = {
            enable = true;
            launchd.enable = false;
            systemd.enable = false;
            instances.default = {};
            firstParty = lib.mapAttrs (_: _: { enable = true; }) options.programs.openclaw.firstParty;
          };
        };
      })
    ];
    specialArgs = { inherit pkgs; };
  };
  evalKey = builtins.deepSeq eval.config.assertions "ok";
in
pkgs.stdenvNoCC.mkDerivation {
  name = "openclaw-first-party-plugins-${evalKey}";
  dontUnpack = true;
  installPhase = "${../scripts/empty-install.sh}";
}
