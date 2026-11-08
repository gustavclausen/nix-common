{
  description = "Common Nix config for my personal setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      minimal-tmux,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;

      mkPkgs = import ./lib/mkPkgs.nix { inherit nixpkgs; };

      # Feature modules own their flake inputs; consumers pass nothing extra.
      hmModules = {
        shell = ./modules/home-manager/shell.nix;
        nodejs = ./modules/home-manager/nodejs;
        python = ./modules/home-manager/python;
        golang = ./modules/home-manager/golang;
        dotnet = ./modules/home-manager/dotnet;
        docker = ./modules/home-manager/docker;
        k8s = ./modules/home-manager/k8s;
        cloudflare = ./modules/home-manager/cloudflare;
        tmux = import ./modules/home-manager/tmux { inherit minimal-tmux; };
        default = import ./modules/home-manager { inherit minimal-tmux; };
      };

      # Sample standalone Home Manager configuration, used by CI and `checks`.
      mkSample =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs { inherit system; };
          modules = [
            hmModules.default
            (
              { pkgs, ... }:
              {
                home = {
                  username = "sample";
                  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/sample" else "/home/sample";
                  stateVersion = "25.11";
                  packages = [ pkgs.claude-code ];
                };
                custom = {
                  nodejs.enable = true;
                  python.enable = true;
                  golang.enable = true;
                  dotnet.enable = true;
                  docker.enable = true;
                  k8s.enable = true;
                  cloudflare.enable = true;
                  tmux.enable = true;
                };
              }
            )
          ];
        };
    in
    {
      homeModules = hmModules;
      lib.mkPkgs = mkPkgs;

      homeConfigurations = nixpkgs.lib.genAttrs (map (s: "sample-${s}") systems) (
        name: mkSample (nixpkgs.lib.removePrefix "sample-" name)
      );

      checks = forAllSystems (
        system:
        let
          cfg = (mkSample system).config;
          pkgs = mkPkgs { inherit system; };
          assertions = [
            {
              ok = pkgs.claude-code.meta.unfree or false;
              msg = "helper should allow unfree packages (claude-code)";
            }
            {
              ok = cfg.programs.tmux.enable;
              msg = "tmux should be enabled without consumer-supplied inputs";
            }
            {
              ok = cfg.programs.bash.enable;
              msg = "shell module should enable bash";
            }
            {
              ok = cfg.home.username == "sample";
              msg = "user name comes from the Home Manager config";
            }
          ];
          failed = builtins.filter (a: !a.ok) assertions;
        in
        {
          sample-eval =
            assert nixpkgs.lib.assertMsg (failed == [ ]) (
              builtins.concatStringsSep "; " (map (a: a.msg) failed)
            );
            pkgs.runCommand "sample-eval" { } ''
              echo ${builtins.unsafeDiscardStringContext cfg.home.activationPackage.drvPath} > $out
            '';
        }
      );
    };
}
