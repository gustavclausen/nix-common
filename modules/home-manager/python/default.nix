{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.python;
in
with lib;
{
  options.custom.python = {
    enable = mkEnableOption "Python development environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      python3
    ];

    programs.uv.enable = true;
  };
}
