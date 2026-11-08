{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.docker;
in
with lib;
{
  options.custom.docker = {
    enable = mkEnableOption "Local Docker tools";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      lib.mkMerge [
        [
          docker
          lazydocker
        ]
        (lib.mkIf pkgs.stdenv.isDarwin [ colima ])
      ];
  };
}
