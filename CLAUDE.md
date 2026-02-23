# Claude Code Context

Personal fork of [openclaw/nix-openclaw](https://github.com/openclaw/nix-openclaw) maintained at [mvivirito/nix-openclaw](https://github.com/mvivirito/nix-openclaw).

## Why This Fork Exists

The upstream `nix-openclaw` repo has an hourly CI auto-updater ("Yolo Update Pins") that keeps the OpenClaw source pin current. When the upstream updater falls behind or breaks, this fork lets us:

1. Pin to any OpenClaw release independently
2. Apply build fixes not yet landed upstream (e.g. rolldown hoisting)
3. Run the auto-update CI on our own schedule

## Repository Structure

```
nix-openclaw/
├── flake.nix                          # Flake outputs: packages, overlays, HM modules
├── nix/
│   ├── sources/
│   │   └── openclaw-source.nix        # Pinned OpenClaw commit (rev, hash, pnpmDepsHash)
│   ├── packages/
│   │   └── openclaw-gateway.nix       # Gateway derivation
│   ├── lib/
│   │   └── openclaw-gateway-common.nix # Shared build config (deps, env, pnpm setup)
│   ├── scripts/
│   │   ├── gateway-postpatch.sh       # Source patches for Nix compatibility
│   │   ├── gateway-prebuild.sh        # pnpm store setup
│   │   ├── gateway-build.sh           # Main build (install, rebuild, bundle, compile)
│   │   └── gateway-install.sh         # Output packaging
│   └── modules/                       # Home Manager module for openclaw
├── scripts/
│   └── update-pins.sh                 # Automated pin updater (used by CI)
└── .github/workflows/
    └── yolo-update.yml                # Hourly auto-update CI
```

## Key File: openclaw-source.nix

This is the pin that determines which OpenClaw version gets built:

```nix
{
  owner = "openclaw";
  repo = "openclaw";
  rev = "<commit-sha>";           # Pinned commit
  hash = "sha256-...";            # Source tarball hash
  pnpmDepsHash = "sha256-...";   # pnpm dependency hash
}
```

## Updating the Pin Manually

```bash
# 1. Get the commit SHA for a release tag
gh api repos/openclaw/openclaw/git/ref/tags/v2026.X.Y --jq '.object.sha'

# 2. Compute the source hash
nix store prefetch-file --unpack --json \
  "https://github.com/openclaw/openclaw/archive/<full-sha>.tar.gz"

# 3. Update rev + hash in nix/sources/openclaw-source.nix, set pnpmDepsHash = ""

# 4. Build to discover pnpmDepsHash (will fail with correct hash)
nix build .#openclaw-gateway

# 5. Update pnpmDepsHash with the hash from the error output

# 6. Verify build succeeds
nix build .#openclaw-gateway
```

## Fork-Specific Changes

### Rolldown hoisting fix (gateway-build.sh)

OpenClaw v2026.2.22+ uses `rolldown` for A2UI bundling. The upstream `bundle-a2ui.sh` script falls back to `pnpm dlx rolldown` when rolldown isn't on PATH, which fails in the nix sandbox (no network access). Our fix creates a wrapper script in `node_modules/.bin/rolldown` that points to the rolldown CLI found in the pnpm store as a transitive dependency of `tsdown`.

## Consumer: nix-config

This fork is consumed by `github:mvivirito/nix-config` (private) via:

```nix
# nix-config/flake.nix
nix-openclaw.url = "github:mvivirito/nix-openclaw";
```

The OpenClaw Home Manager config lives at `nix-config/home-manager/linux/openclaw.nix` and is deployed on the `nixie-vm` NixOS host (Proxmox VM with KDE Plasma).

## Auto-Update CI

The `yolo-update.yml` GitHub Action runs hourly using `GITHUB_TOKEN` (no extra secrets needed). It:
1. Picks the latest upstream OpenClaw commit with passing CI
2. Rebuilds the gateway to refresh `pnpmDepsHash`
3. Regenerates config options from upstream schema
4. Commits and pushes to `main`

Enable it at: https://github.com/mvivirito/nix-openclaw/actions

To trigger manually:
```bash
gh workflow run "Yolo Update Pins" -R mvivirito/nix-openclaw
```
