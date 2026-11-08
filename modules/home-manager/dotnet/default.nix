{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.dotnet;
in
with lib;
{
  options.custom.dotnet = {
    enable = mkEnableOption ".NET development environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dotnet-sdk_10
    ];

    programs.zsh.initContent = ''
      export DOTNET_ROOT="${pkgs.dotnet-sdk_10}"
    '';
  };
}
