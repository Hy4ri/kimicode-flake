# Kimi Code Flake

[![Kimi Code](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fkimicode-flake%2Fmain%2Fversion.json&query=%24.version&label=kimi-code&color=6366f1&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0IiByeD0iNCIgZmlsbD0iIzYzNjZmMSIvPjx0ZXh0IHg9IjEyIiB5PSIxNyIgZm9udC1zaXplPSIxNCIgZmlsbD0id2hpdGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZvbnQtZmFtaWx5PSJzYW5zLXNlcmlmIiBmb250LXdlaWdodD0iYm9sZCI+SzwvdGV4dD48L3N2Zz4=)](https://code.kimi.com)
[![Update Status](https://img.shields.io/github/actions/workflow/status/Hy4ri/kimicode-flake/update.yml?branch=main&label=auto-update)](https://github.com/Hy4ri/kimicode-flake/actions/workflows/update.yml)

Nix flake for [Kimi Code](https://code.kimi.com) — AI-powered coding assistant CLI by Moonshot AI.

## Installation

### Try it out

```bash
nix run github:Hy4ri/kimicode-flake
```

### NixOS / Home Manager

1. Add the flake input:

```nix
{
  inputs.kimi-code.url = "github:Hy4ri/kimicode-flake";
}
```

2. Add the overlay:

```nix
nixpkgs.overlays = [ inputs.kimi-code.overlays.default ];
```

3. Install the package:

```nix
# NixOS
environment.systemPackages = with pkgs; [
  kimi-code
];

# Home Manager
home.packages = with pkgs; [
  kimi-code
];
```

## Project Structure

| File | Purpose |
|---|---|
| `flake.nix` | Flake entry point — exposes package and overlay |
| `package.nix` | Derivation — fetches the prebuilt binary and patches it for NixOS |
| `update-version.sh` | CLI tool to update to a new version: `./update-version.sh [version]` |
| `version.json` | Version metadata (used by README badge) |
| `flake.lock` | Pinned nixpkgs revision |

## Manual Updates

If a new release is out and the auto-update CI hasn't caught it yet:

```bash
# Update to latest
./update-version.sh

# Update to a specific version
./update-version.sh 0.15.0
```

The script will:
1. Fetch the manifest from `code.kimi.com`
2. Extract `sha256` checksums for both architectures
3. Convert to SRI hashes and update `package.nix`
4. Update `version.json`

## Local Development

```bash
# Evaluate the flake
nix flake check

# Build
nix build .#kimi-code

# Run directly (no install)
nix run .
```
