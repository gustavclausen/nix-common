{
  description = "Common Nix config for my personal setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
      nixpkgs-unstable,
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

      overlay = import ./overlays/unstable-packages.nix { inherit nixpkgs-unstable; };
      mkPkgs = import ./lib/mkPkgs.nix { inherit nixpkgs overlay; };

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

      # Sample standalone Home Manager configuration: the evaluation seam
      # used by CI and by `checks`.
      mkSample =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
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
      overlays.default = overlay;
      lib.mkPkgs = mkPkgs;

      homeConfigurations = nixpkgs.lib.genAttrs (map (s: "sample-${s}") systems) (
        name: mkSample (nixpkgs.lib.removePrefix "sample-" name)
      );

      checks = forAllSystems (
        system:
        let
          cfg = (mkSample system).config;
          pkgs = mkPkgs system;
          assertions = [
            {
              ok = pkgs.claude-code.meta.unfree or false;
              msg = "helper should expose unstable overlay package claude-code with unfree allowed";
            }
            {
              ok = cfg.programs.tmux.enable;
              msg = "tmux should be enabled without consumer-supplied inputs";
            }
            {
              ok = cfg.programs.zsh.enable;
              msg = "shell module should enable zsh";
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
