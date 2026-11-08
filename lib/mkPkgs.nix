# Package set with the unstable-packages overlay applied and unfree allowed.
{ nixpkgs, overlay }:
system:
import nixpkgs {
  inherit system;
  overlays = [ overlay ];
  config.allowUnfree = true;
}
