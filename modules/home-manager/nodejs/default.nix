{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.nodejs;
in
with lib;
{
  options.custom.nodejs = {
    enable = mkEnableOption "Node.JS development environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_24
      corepack_24
    ];

    programs.zsh.initContent = ''
      export PATH="$(npm get prefix)/bin:$PATH"
    '';
  };
}
