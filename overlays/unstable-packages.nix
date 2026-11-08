{ nixpkgs-unstable }:
final: prev:
let
  unstable = import nixpkgs-unstable {
    inherit (final) config;
    system = final.stdenv.hostPlatform.system;
  };
in
{
  claude-code = unstable.claude-code;
  cloudflare-cli = unstable.cloudflare-cli;
  cloudflared = unstable.cloudflared;
  codex = unstable.codex;
  colima = unstable.colima;
  ctx7 = unstable.ctx7;
  vscode = unstable.vscode;
}
