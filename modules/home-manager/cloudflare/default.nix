{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.cloudflare;
in
with lib;
{
  options.custom.cloudflare = {
    enable = mkEnableOption "Cloudflare CLI tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wrangler
      cloudflared
      cloudflare-cli
    ];
  };
}
