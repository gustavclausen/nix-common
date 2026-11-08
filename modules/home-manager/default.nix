# Aggregate Home Manager module: imports every feature module.
# Wrapper-agnostic — the consumer attaches it (integrated or standalone).
{ minimal-tmux }:
{
  imports = [
    ./cloudflare
    ./docker
    ./dotnet
    ./golang
    ./k8s
    ./nodejs
    ./python
    ./shell.nix
    (import ./tmux { inherit minimal-tmux; })
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
  };

  xdg.enable = true;
  fonts.fontconfig.enable = true;
}
