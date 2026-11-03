# Kimi Code Flake

[![Kimi Code](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fkimicode-flake%2Fmain%2Fversion.json&query=%24.version&label=kimi-code&color=6366f1&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0IiByeD0iNCIgZmlsbD0iIzYzNjZmMSIvPjx0ZXh0IHg9IjEyIiB5PSIxNyIgZm9udC1zaXplPSIxNCIgZmlsbD0id2hpdGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZvbnQtZmFtaWx5PSJzYW5zLXNlcmlmIiBmb250LXdlaWdodD0iYm9sZCI+SzwvdGV4dD48L3N2Zz4=)](https://code.kimi.com)
[![Update Status](https://img.shields.io/github/actions/workflow/status/Hy4ri/kimicode-flake/update.yml?branch=main&label=auto-update)](https://github.com/Hy4ri/kimicode-flake/actions/workflows/update.yml)

Run and install [Kimi Code](https://code.kimi.com) on NixOS, Home Manager, or any Linux system with Nix.

Kimi Code is an AI coding assistant for the terminal, made by Moonshot AI.

The flake is updated automatically every day.

## Packages

| Package | What it is | Command |
|---|---|---|
| `kimi-code` (default) | Kimi Code CLI | `kimi` |

Platforms: Linux `x86_64` and `aarch64`.

## Try it without installing

You need Nix with [flakes enabled](https://wiki.nixos.org/wiki/Flakes).

```bash
nix run github:Hy4ri/kimicode-flake
```

## Install

There are **two ways** to install. **Pick one.** They give the same result.

| Option | Use it when |
|---|---|
| **A. Overlay** | You want to write `pkgs.kimi-code`, like any other nixpkgs package. |
| **B. Direct package** | You do not want to use overlays. |

### Step 1: Add the flake input (needed for both options)

In your system `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kimi-code.url = "github:Hy4ri/kimicode-flake";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # lets your modules use `inputs`
      modules = [ ./configuration.nix ];
    };
  };
}
```

> Already have a flake? Add only the `kimi-code.url` line, and make sure `inputs` reaches your modules (`specialArgs` for NixOS, `extraSpecialArgs` for Home Manager).

### Step 2, Option A: Overlay

In `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [ inputs.kimi-code.overlays.default ];
  nixpkgs.config.allowUnfree = true; # required: the package is marked unfree

  environment.systemPackages = [ pkgs.kimi-code ];
}
```

For Home Manager, keep the two `nixpkgs` lines and use `home.packages = [ pkgs.kimi-code ];` instead.

### Step 2, Option B: Direct package

In `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.kimi-code
  ];
}
```

You do not need `allowUnfree` for this option. For Home Manager, put the same line in `home.packages`.

### Step 3: Rebuild

```bash
sudo nixos-rebuild switch --flake .#myhost
```

## Updates

A GitHub Action checks for new Kimi Code releases every day, tests the build, and commits the new version. To get it, update your lock file:

```bash
nix flake update kimi-code
```

### Manual update (maintainers)

```bash
./update-version.sh           # latest release
./update-version.sh 0.15.0    # a specific version
```

The script reads the release manifest from `code.kimi.com`, converts the checksums of both architectures to SRI hashes, and updates `package.nix` and `version.json`.

### Repository layout

| File | Purpose |
|---|---|
| `flake.nix` | Flake entry point: package and overlay |
| `package.nix` | Downloads the prebuilt binary and patches it for NixOS |
| `update-version.sh` | Updates the version and hashes |
| `version.json` | Current version (also used by the badge) |

## License

Kimi Code has its own license terms from Moonshot AI; Nix marks it as unfree. This flake only downloads and packages the official binary.

## Support

If this flake helps you, you can support my work on [GitHub Sponsors](https://github.com/sponsors/hy4ri) or [Ko-fi](https://ko-fi.com/m_5_7). A star on the repo also helps.
