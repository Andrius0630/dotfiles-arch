# FreeBSD Transition Assessment & Roadmap

This document evaluates the feasibility of transitioning from Arch Linux to FreeBSD for "Unix Studying" based on current configurations and hardware.

---

## 1. Executive Summary

Transitioning to FreeBSD is highly recommended for studying Unix internals. While your primary Arch Linux setup is sophisticated, the **HP ProBook 430** is the superior candidate for an initial installation due to its Intel-based hardware and the lack of NVIDIA-related friction.

### Key Strengths of FreeBSD for Study:
- **Base System vs. Ports:** Clear distinction between the core OS (kernel/userland) and third-party software.
- **ZFS Integration:** Native, first-class support for advanced file system management.
- **Jails:** Deep dive into OS-level virtualization (the precursor to containers).
- **Documentation:** The FreeBSD Handbook is the definitive guide for system administration.

---

## 2. Hardware Comparison

| Feature | Primary Laptop (Arch) | HP ProBook 430 (Target) |
| :--- | :--- | :--- |
| **GPU** | NVIDIA (Difficult for Wayland) | Intel (Highly Compatible) |
| **Wi-Fi** | Intel (Requires sleep fix) | Intel (Stable `iwlwifi`/`iwm`) |
| **CPU** | High Perf / CUDA needed | Standard Intel |
| **Recommendation** | **Keep on Arch** (for CUDA/Games) | **Install FreeBSD** (for Study) |

---

## 3. Software Compatibility Matrix

| Category | Status | Notes |
| :--- | :--- | :--- |
| **Shells** | ✅ Native | `zsh`, `fish`, `oh-my-zsh` all available in Ports/Pkg. |
| **Editors** | ✅ Native | `Neovim`, `Emacs` (Doom), `Vim`. |
| **Wayland** | ⚠️ Experimental | `niri` is available, but requires `seatd` and `drm-kmod`. |
| **Dev Tools** | ✅ Native | Rust, Go, Clang (Default), Python. |
| **Multimedia** | ✅ Native | `mpv`, `ffmpeg`. |
| **CUDA** | ❌ No | **Dealbreaker** for primary laptop workflows. |
| **Proprietary** | ⚠️ Partial | Spotify/Obsidian require Linux Binary Compatibility layer. |

---

## 4. Configuration Migration Guide

### System Management Translation
| Linux (Systemd) | FreeBSD (RC) |
| :--- | :--- |
| `systemctl enable --now <service>` | Add `<service>_enable="YES"` to `/etc/rc.conf` |
| `journalctl -u <service>` | Check `/var/log/messages` or service logs |
| `/etc/default/grub` | `/boot/loader.conf` |
| `ip addr` | `ifconfig` |

### Path Adjustments
- Most third-party binaries live in `/usr/local/bin/` rather than `/usr/bin/`.
- Configuration files for packages live in `/usr/local/etc/` instead of `/etc/`.
- Update your shebangs: `#!/usr/bin/env sh` is portable, but `#!/bin/bash` may need to be `#!/usr/local/bin/bash`.

---

## 5. Recommended Study Roadmap

### Phase 1: The "Unix Sandbox" (HP ProBook)
1.  **ZFS Installation:** Use the automated ZFS installer. Learn about `zfs list`, `zpool status`, and snapshots.
2.  **Intel Graphics:** Install `drm-kmod` and configure `rc.conf` to load the `i915kms` driver.
3.  **Basic Desktop:** Install `seatd`, `dbus`, and your preferred WM (`i3` or `niri`).
4.  **The Ports Tree:** Try building `neovim` from `/usr/ports/editors/neovim` to understand the build process.

### Phase 2: Advanced Unix Concepts
1.  **Jails:** Create a thin jail using `bastille` or `ezjail`. Host a simple static site.
2.  **Boot Environments:** Use `bectl` to create snapshots before making major system changes.
3.  **Networking:** Explore the FreeBSD firewall (`pf`)—originally from OpenBSD but excellent on FreeBSD.

---

## 6. Known "Gotchas" from Current Scripts

- **`nvidia_cuda.sh`:** This script will not work. CUDA is unsupported.
- **`fix_omen_wifi_from_sleep.sh`:** FreeBSD handles sleep/resume differently. You will likely use `acpiconf` and devd scripts instead of systemd-sleep hooks.
- **`automated_install.sh`:** You will need to replace `yay` with `pkg install` and `pacman` syntax with `pkg`.
