# nix-common

Common Nix config for my personal setup.

Exports (flake outputs):

- `homeModules.default` — aggregate Home Manager module; `homeModules.<feature>` for each of `shell`, `nodejs`, `python`, `golang`, `dotnet`, `docker`, `k8s`, `cloudflare`, `tmux`.
- `lib.mkPkgs { system, overlays ? [ ] }` — a package set with unfree allowed and the consumer's overlays applied. Overlays (e.g. which packages come from unstable) are owned by the consumer.

Consumers only need `nixpkgs` and `home-manager` to follow this flake's; the modules own their other inputs. The modules attach to either integrated or standalone Home Manager, and never read a system-level config.

```nix
inputs.nix-common = {
  url = "github:gustavclausen/nix-common";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

CI evaluates a sample standalone configuration on x86_64-linux, aarch64-linux and aarch64-darwin.

## Licence

MIT
