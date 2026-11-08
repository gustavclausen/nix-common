{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.golang;
in
with lib;
{
  options.custom.golang = {
    enable = mkEnableOption "Golang development environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      go
      gopls
      goreleaser
      protobuf
      air
    ];

    programs.zsh.initContent = ''
      export GOPATH="$HOME/go"
      export GOBIN="$GOPATH/bin"
      export PATH="$GOPATH:$HOME/go/bin:$PATH"
    '';
  };
}
