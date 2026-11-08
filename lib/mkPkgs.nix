# Package set with unfree allowed. Consumers supply their own overlays
# (e.g. which packages come from unstable) — nix-common doesn't manage them.
{ nixpkgs }:
{
  system,
  overlays ? [ ],
}:
import nixpkgs {
  inherit system overlays;
  config.allowUnfree = true;
}
