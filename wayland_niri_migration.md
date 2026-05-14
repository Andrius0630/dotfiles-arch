# Wayland / Niri Migration: What Was Changed and Why

This is a record of the transition from i3 (X11) to niri (Wayland) with explanations of
every concept involved. Written so future-me can understand *why*, not just *what*.

---

## Table of Contents

1. [X11 vs Wayland — the architecture](#1-x11-vs-wayland--the-architecture)
2. [KDL config format and the silent /-comment bug](#2-kdl-config-format-and-the-silent---comment-bug)
3. [Mouse scroll inversion — libinput and natural-scroll](#3-mouse-scroll-inversion--libinput-and-natural-scroll)
4. [Auto scale 2 on startup — HiDPI and output configuration](#4-auto-scale-2-on-startup--hidpi-and-output-configuration)
5. [Session startup — .zprofile, login shells, and environment inheritance](#5-session-startup--zprofile-login-shells-and-environment-inheritance)
6. [XDG standards — what those variables actually mean](#6-xdg-standards--what-those-variables-actually-mean)
7. [D-Bus — what it is and why we export into it](#7-d-bus--what-it-is-and-why-we-export-into-it)
8. [Electron and Ozone — why VS Code and Discord defaulted to X11](#8-electron-and-ozone--why-vs-code-and-discord-defaulted-to-x11)
9. [CEF vs Electron — why Spotify needed a different fix](#9-cef-vs-electron--why-spotify-needed-a-different-fix)
10. [Desktop file override system](#10-desktop-file-override-system)
11. [XWayland — the X11 compatibility layer](#11-xwayland--the-x11-compatibility-layer)
12. [mpv — GPU contexts and hardware decoding](#12-mpv--gpu-contexts-and-hardware-decoding)
13. [i3 to niri keybinding migration](#13-i3-to-niri-keybinding-migration)
14. [Summary of all changed files](#14-summary-of-all-changed-files)

---

## 1. X11 vs Wayland — the architecture

### What X11 is

X11 (or X.Org) is a display system from the 1980s. It uses a **client-server model**:

```
app (client) ──────────────────► X server (display server)
                 X protocol              │
                                         ▼
                                   compositor (e.g. i3)
                                         │
                                         ▼
                                      screen
```

The X server is a separate process that owns the screen. Apps talk to it using the X
protocol (over a socket at `/tmp/.X11-unix/X0`). A compositor like i3 is just another
client of the X server — it draws window decorations and arranges things, but the X
server is the actual authority.

This creates problems:
- Every app can read any other app's keystrokes (keyloggers possible by design)
- Every app can screenshot any other app's window
- The X server has to handle input, output, rendering — it became a massive ball of
  complexity keeping 40-year-old code alive

### What Wayland is

Wayland is a **protocol** (not a program). In Wayland, the compositor IS the display
server — there is no separate process:

```
app (Wayland client) ──────────────────► compositor (e.g. niri)
                       Wayland protocol        │
                                               ▼
                                            screen
```

Each app gets only its own surface to draw on. It cannot read other apps' input or
screenshot other windows without going through the compositor. Security is better by
default.

The tradeoff: X11 had decades of features built on top of it. Wayland starts fresh, so
some things that "just worked" in X11 need explicit solutions in Wayland (like screen
sharing, global hotkeys for non-compositor apps, etc.).

### What niri is

niri is a **Wayland compositor**. It replaces both the X11 display server AND the window
manager. It speaks the Wayland protocol to apps, manages windows in its scrolling-column
layout, and talks directly to the kernel's graphics stack via KMS/DRM (Kernel Mode
Setting / Direct Rendering Manager).

---

## 2. KDL config format and the silent /-comment bug

niri uses **KDL** (KDL Document Language — kdl.dev). It's a configuration language
designed to be readable for humans.

In KDL, `//` comments out a single line. But `/-` is different — it comments out the
**entire next node** including all its children. Example:

```kdl
// this line is commented
key "value"

/- key "value" {    // this ENTIRE BLOCK is commented out
    child "a"       // these lines are never read
    child "b"
}
```

**The bug**: The `output "eDP-1"` block was prefixed with `/-`:

```kdl
/-output "eDP-1" {   // <-- the whole block is disabled
    scale 2
    ...
}
```

Without an explicit output block, niri auto-detects settings. It calculated that your
screen's physical DPI warranted 2x scaling (common for ~1080p 14" laptop screens where
text becomes small). The fix was simply removing the `/-` prefix and setting `scale 1`.

**Lesson**: `/-` in KDL is not just a comment marker — it's a structural disabler. If
you think a config block is "commented out as an example", check whether it uses `//`
(harmless line comment) or `/-` (silently disables the whole node).

---

## 3. Mouse scroll inversion — libinput and natural-scroll

### What libinput is

On Linux, hardware input (keyboard, mouse, touchpad, tablet) goes through the kernel as
raw events (`/dev/input/eventX`). A library called **libinput** sits on top of the
kernel and provides higher-level interpretation: gesture recognition, scroll acceleration,
palm detection, etc.

Both X11 and Wayland compositors typically use libinput to handle input devices. The niri
`input {}` block in the config maps directly to libinput settings.

### What "natural scroll" means

The term comes from Apple's OS X Lion (2011). On a touchpad, "natural" scroll means the
**content** moves in the same direction as your fingers — scroll two fingers down, the
page moves down (like sliding a physical piece of paper). Before this, the convention was
the **scrollbar** moved in the direction of the gesture, so scrolling down would move the
scrollbar indicator down, meaning the content moved UP.

This makes sense on a touchpad because you're directly "touching" the content. But on a
**mouse scroll wheel**, the original convention was universal: scroll down = page moves
down-ish (scrollbar moves down). "Natural scroll" on a mouse wheel means scroll wheel
down = page moves UP, which feels backwards to most people used to mice.

**The config**: niri's input section separates `touchpad {}` and `mouse {}` blocks. They
are separate libinput "seat" configurations. `natural-scroll` in the `touchpad {}` block
is correct and wanted. `natural-scroll` in the `mouse {}` block was the problem — it was
inverted for external mice. The fix was commenting it out in the mouse block only.

```kdl
touchpad {
    natural-scroll    // correct: touchpad content follows fingers
}
mouse {
    // natural-scroll // removed: would invert scroll wheel direction
}
```

---

## 4. Auto scale 2 on startup — HiDPI and output configuration

### What DPI and HiDPI mean

DPI = Dots Per Inch. Physical pixels per inch of screen. A 1920x1080 screen on a 24"
monitor has ~92 DPI. The same 1920x1080 on a 14" laptop screen has ~157 DPI. At ~92 DPI,
a UI element that's 96 pixels wide (the CSS "1 inch") actually looks about 1 inch. At
157 DPI, that same 96-pixel element looks about 0.6 inches — too small.

HiDPI (or Retina on Apple products) means "more physical pixels than the interface
pretends to use". With scale 2, niri tells apps the screen is 960x540 **logical pixels**,
but actually renders at 1920x1080 **physical pixels**. Everything looks crisp but
full-size.

### Why niri auto-picked scale 2

Niri (like most Wayland compositors) reads the monitor's EDID data (the monitor
identifying itself to the system, including physical dimensions). It calculates DPI from
that. If DPI is high enough (~150+), it defaults to scale 2.

On a ~14" 1080p laptop, that detection is borderline. The scale-2 rendering makes
everything legible but large; you wanted scale 1.

### The fix

Remove `/-` from the output block and explicitly set scale:

```kdl
output "eDP-1" {
    mode "1920x1080@120.030"   // resolution @ refresh rate
    scale 1                     // explicit: do NOT auto-scale
    transform "normal"          // rotation (normal = no rotation)
}
```

The `mode` line is important too — without it, niri picks the highest resolution but not
necessarily the highest refresh rate you want. `120.030` pins it to 120 Hz.

---

## 5. Session startup — .zprofile, login shells, and environment inheritance

### How processes and environment variables work

Every process on Linux has an **environment** — a set of key=value pairs. When a process
creates a child process (via `fork()` + `exec()`), the child **inherits** the parent's
environment. This is how variables like `$HOME` and `$PATH` end up in every terminal you
open.

### Login shells vs interactive shells

When zsh starts, it reads different files depending on context:

| Situation | Files read |
|-----------|-----------|
| Login shell (TTY login, SSH) | `/etc/zprofile`, `~/.zprofile`, then `~/.zshrc` |
| Interactive non-login shell (opening terminal in GUI) | only `~/.zshrc` |
| Script (non-interactive) | none |

`~/.zprofile` is for **login shells** — the first shell that starts when you log in.
This is the right place to set environment variables that should exist for the entire
graphical session, because everything launched from here (including niri) will inherit
them.

**Note**: `~/.bashrc` and `~/.zshrc` are NOT read for graphical sessions unless you're
opening a new interactive terminal. If you put `export WAYLAND_DISPLAY=wayland-1` in
`.zshrc`, it won't be visible to apps launched from niri's keybindings or app launchers.

### What `exec niri` does

The `exec` shell builtin is process **replacement** — instead of forking a child,
the current shell process transforms itself into niri. This is important because:

1. It means there's no "shell parent" holding an extra TTY session
2. niri inherits all env vars exported in `.zprofile` before the `exec`
3. When niri exits, you're logged out (the session ends)

The flow:
```
tty1 login ──► zsh (login shell) ──► reads .zprofile ──► exec niri
                                                              │
                                            niri IS the zsh process now
                                            (same PID, same env)
```

### What was missing

Before the fix, `.zprofile` only had `exec niri` with no environment setup. So niri
started with the bare login environment: `$HOME`, `$PATH`, `$USER`, `$SHELL`, and
whatever `/etc/environment` had. It was missing:

- `XDG_SESSION_TYPE=wayland` — critical, many apps gate behavior on this
- `XDG_CURRENT_DESKTOP=niri` — tells apps which desktop environment is running
- `ELECTRON_OZONE_PLATFORM_HINT=auto` — Electron's Wayland flag
- `QT_QPA_PLATFORM=wayland` — Qt framework's platform plugin selector
- `MOZ_ENABLE_WAYLAND=1` — Firefox/librewolf Wayland mode
- `SDL_VIDEODRIVER=wayland` — SDL library (many games) Wayland mode

### Why display managers (GDM, SDDM, ly) handle this automatically

A display manager is a graphical login screen. When it starts a session, it reads session
description files (`/usr/share/wayland-sessions/niri.desktop`) and runs the session
startup scripts which properly set `XDG_SESSION_TYPE`, set up the PAM session, start
the systemd user session with the right environment, etc.

Since you log in directly on tty1 without a display manager, all of that setup is skipped.
The `.zprofile` additions manually replicate the most critical parts.

---

## 6. XDG standards — what those variables actually mean

XDG stands for "X Desktop Group", now called freedesktop.org. It's an organization that
defines shared specifications so that different desktop environments (GNOME, KDE, etc.)
can interoperate. The XDG variables are their "well-known names" that apps agreed to
check.

### XDG_SESSION_TYPE

Values: `x11`, `wayland`, `mir`, `tty`

This is the single most important variable. Apps check it to decide how to connect to
the display:
- Electron: if `wayland`, can use native Wayland; if `x11`, falls back to XWayland
- libva (hardware video decoding): if `wayland`, uses DRM/VA-API paths
- screen capture portals: gates on this being `wayland`
- many apps that have both X11 and Wayland codepaths

When you start niri from TTY without a display manager, this defaults to `tty` (the type
of the TTY you're on). Apps see `tty` and think "I'm in a terminal, not a graphical
session" and fail or behave unexpectedly.

### XDG_CURRENT_DESKTOP

Value: `niri`, `GNOME`, `KDE`, `i3`, etc.

Apps use this to enable DE-specific integrations. For example, a GTK app might check if
`XDG_CURRENT_DESKTOP=GNOME` to decide whether to show GNOME-specific settings. For niri,
setting this to `niri` is correct; some apps also accept semicolon-separated fallbacks
like `niri:GNOME` to get broader compatibility.

### XDG_RUNTIME_DIR

Not in our changes but important to know: this is the per-user directory for runtime
files (usually `/run/user/1000`). Wayland sockets live here (e.g.,
`/run/user/1000/wayland-1`). This is set by the PAM session on login.

### QT_QPA_PLATFORM

QPA = Qt Platform Abstraction. Qt apps can render using different backends: `xcb` (X11),
`wayland`, `offscreen`, etc. Without this, Qt apps on Wayland default to xcb (X11 via
XWayland). Setting `QT_QPA_PLATFORM=wayland` makes Qt apps render natively in Wayland,
with better scaling, touchpad gestures, and clipboard integration.

Telegram Desktop is a Qt app — this fixes it.

### MOZ_ENABLE_WAYLAND

Mozilla-specific. Firefox and librewolf detect Wayland separately from the XDG
variables. Setting this to `1` enables their native Wayland backend. Without it they use
XWayland even when Wayland is available.

### SDL_VIDEODRIVER

SDL (Simple DirectMedia Layer) is a library used by many games and multimedia apps.
`SDL_VIDEODRIVER=wayland` makes SDL apps connect natively to Wayland instead of X11.

---

## 7. D-Bus — what it is and why we export into it

### What D-Bus is

D-Bus is an **IPC (Inter-Process Communication) bus** for Linux desktops. Think of it as
a message-passing system where processes can:
- **Call methods** on other processes (like RPC)
- **Subscribe to signals** from other processes (like events)
- **Provide services** that other processes can discover and use

There are two buses:
- **System bus** (`/run/dbus/system_bus_socket`): for system-wide services (NetworkManager,
  BlueZ, polkit, etc.)
- **Session bus** (`/run/user/1000/bus`): per-user, for desktop apps

Apps use the session bus to talk to things like: the notification daemon, the media player
controller (MPRIS), the portal services (screen capture, file chooser), the tray icon
host, etc.

### Activation

D-Bus supports **activation**: a service can be "activated" (auto-started) when another
app tries to talk to it, rather than being pre-started. The D-Bus daemon reads service
files and starts the right process on demand.

When it starts a service this way, it passes a specific **environment** to that new
process. By default, that environment is minimal — just what `systemd --user` knows
about.

### dbus-update-activation-environment

This command updates the environment that D-Bus uses when activating services:

```bash
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_SESSION_TYPE
```

The `--systemd` flag also updates the **systemd user instance** environment (same
concept, different daemon). This matters because:

1. Apps launched via systemd user services (e.g., desktop autostart) inherit this env
2. Apps launched via D-Bus activation inherit this env
3. portals (xdg-desktop-portal) are activated this way — without `WAYLAND_DISPLAY` in
   the D-Bus environment, screen sharing, file pickers, etc. wouldn't work

**What changed**: The original command only exported `WAYLAND_DISPLAY` and hardcoded
`XDG_CURRENT_DESKTOP=niri`. The updated version exports all the session variables:
`DISPLAY`, `WAYLAND_DISPLAY`, `XDG_CURRENT_DESKTOP`, `XDG_SESSION_TYPE`,
`ELECTRON_OZONE_PLATFORM_HINT`, and `QT_QPA_PLATFORM`. Since these are now set in
`.zprofile` before `exec niri`, they exist in niri's environment and can be passed along.

---

## 8. Electron and Ozone — why VS Code and Discord defaulted to X11

### What Electron is

Electron is a framework for building desktop apps using web technologies (JavaScript,
HTML, CSS). It bundles a **Chromium** browser engine and a **Node.js** runtime together.
VS Code, Discord, Slack, Obsidian, and many others are built on it.

Because it bundles Chromium, Electron inherits Chromium's platform support — including
its Wayland support (or lack thereof).

### What Ozone is

Chromium (and therefore Electron) doesn't talk directly to X11 or Wayland. Instead, it
has an abstraction layer called **Ozone** that has backends for different platforms:
- `x11` — connects via XCB (X11 client library), works on X11 and XWayland
- `wayland` — connects natively to Wayland compositor
- `headless` — no display (for testing/bots)

Without explicit configuration, Electron on Linux defaults to the `x11` backend — even
when running inside a Wayland session. This is a conservative choice for compatibility:
XWayland is always available if Wayland is running, so X11 mode "works" (but doesn't
get native Wayland benefits like proper scaling, better performance, clipboard
integration).

### ELECTRON_OZONE_PLATFORM_HINT

This environment variable tells Electron which Ozone backend to try:
- `auto` — detect: if `WAYLAND_DISPLAY` is set, use Wayland; otherwise fall back to X11
- `wayland` — always use Wayland (fails if no Wayland compositor)
- `x11` — always use X11 (via XWayland on Wayland)

`auto` is the right choice: it uses Wayland when available and falls back gracefully.

Setting this in `.zprofile` means ALL Electron apps inherit it without per-app
configuration.

### code-flags.conf

VS Code also reads `~/.config/code-flags.conf` — a list of command-line flags passed
to the `code` binary on startup. This is VS Code specific (not an Electron standard).
The flags added:

```
--ozone-platform-hint=auto
--enable-features=WaylandWindowDecorations
```

`WaylandWindowDecorations` enables server-side decorations via the xdg-decoration Wayland
protocol — niri draws the window border instead of VS Code drawing its own titlebar
(which can look inconsistent). This is optional but cleaner.

Note: `--ozone-platform-hint=auto` in the flags file takes effect even without the
env var, so VS Code has double coverage.

---

## 9. CEF vs Electron — why Spotify needed a different fix

### What CEF is

CEF (Chromium Embedded Framework) is a project that embeds Chromium into other apps.
Unlike Electron (which is a full Node.js + Chromium application framework), CEF is just
a C++ library for embedding a browser view.

Spotify uses CEF. The important difference: `ELECTRON_OZONE_PLATFORM_HINT` is an
Electron-specific environment variable. Spotify doesn't use Electron, so it doesn't
check that variable. Spotify needs Wayland flags passed directly on the command line:

```
spotify --ozone-platform=wayland
```

### How the fix was applied — .desktop file override

Apps on Linux are described by `.desktop` files (freedesktop.org spec). The system
ones are in `/usr/share/applications/`. The user-local overrides are in
`~/.local/share/applications/`. When an app launcher (like fuzzel) or a file manager
looks for an app, it checks user-local first — user overrides take priority.

Spotify already had a local override at `~/.local/share/applications/spotify.desktop`
(probably created when Spotify was installed or when you added it to a launcher). The
`Exec=` line was changed from:

```ini
Exec=spotify %U
```
to:
```ini
Exec=spotify --ozone-platform=wayland %U
```

`%U` is a `.desktop` file variable meaning "the URI/file arguments passed to this app"
(used when opening a spotify:// link or dropping a file on the icon). It must stay at
the end after the flags.

---

## 10. Desktop file override system

The full precedence for `.desktop` files (highest priority first):

1. `~/.local/share/applications/` — user overrides
2. `/usr/local/share/applications/` — local system overrides
3. `/usr/share/applications/` — package-provided files

When multiple files have the same name, the highest-priority one wins entirely (not
merged). So `~/.local/share/applications/spotify.desktop` completely replaces
`/usr/share/applications/spotify.desktop`.

**Caveat**: When Spotify updates (package update via pacman), `/usr/share/applications/
spotify.desktop` gets updated but your local override does NOT. If Spotify adds new Exec
flags in their system desktop file, you won't get them until you manually update your
local copy. This is a tradeoff of the override approach.

---

## 11. XWayland — the X11 compatibility layer

### What XWayland is

XWayland is an X11 server that runs as a **Wayland client**. It sits between X11
applications and the Wayland compositor:

```
X11 app (nsxiv) ──► XWayland (X server) ──► niri (Wayland compositor) ──► screen
                    pretends to be X11        real display authority
```

From nsxiv's perspective, it's talking to a normal X11 server. From niri's perspective,
XWayland is just another Wayland client that happens to manage many sub-surfaces.

XWayland translates the X11 protocol into Wayland protocol calls. It's a compatibility
shim, not a full solution — some X11 features (like global hotkeys, screen capture of
other windows) don't translate cleanly.

### Lazy initialization

Niri starts XWayland **lazily** — only when an X11 app tries to connect. This saves
startup time and memory if you never use X11 apps. The downside: the first X11 app you
launch in a session triggers XWayland startup (takes ~0.5s).

When XWayland starts, it picks a display number (e.g., `:0`) and creates a socket at
`/tmp/.X11-unix/X0`. It also sets `DISPLAY=:0` in niri's **internal** environment for
newly spawned processes.

### The DISPLAY variable problem

`$DISPLAY` is how X11 apps find the X server. Value format: `:0`, `:1`, `:0.0` etc.
The `:0` means "first X server on localhost" (the `.0` is the screen number, defaulting
to 0).

The problem: `DISPLAY` is set in niri's environment only after XWayland first starts.
If you launch an X11 app before any other X11 app has triggered XWayland, niri will
start XWayland and the app will work. But apps launched via D-Bus activation or systemd
units (before XWayland started) won't have `DISPLAY` in their environment because
`dbus-update-activation-environment` ran at session start before XWayland was up.

This is why the `dbus-update-activation-environment` line now includes `DISPLAY` in the
list — once XWayland starts and DISPLAY is in niri's environment, it gets propagated
to D-Bus too. (Though in practice, most apps are now native Wayland and this is mostly
needed for things like nsxiv.)

### nsxiv and X11-only apps

nsxiv (formerly sxiv) is a minimal image viewer written in C using Xlib (X11 client
library). It has no Wayland support and never will without a rewrite. It works via
XWayland.

If you want a native Wayland image viewer: **swayimg** is a drop-in replacement for
most use cases. `imv` is another option. Both speak Wayland natively.

---

## 12. mpv — GPU contexts and hardware decoding

### Video output backends

mpv separates how it **decodes** video from how it **displays** it:
- Decoding: CPU (software) or GPU (hardware, via VA-API/NVDEC/VDPAU)
- Display: VO (video output) backend — how decoded frames get to the screen

`vo=gpu` is mpv's GPU-accelerated display backend. It handles color management,
scaling, post-processing filters, etc. on the GPU before presenting frames to the
display.

### GPU contexts

Within `vo=gpu`, mpv has different **contexts** for how it interacts with the display:
- `x11` / `x11egl` — connects via X11 (via XWayland on Wayland)
- `wayland` — connects directly to the Wayland compositor
- `drm` — renders directly to the DRM/KMS kernel layer (no display server needed)
- `auto` — mpv picks based on environment

With `gpu-context=wayland`, mpv renders directly to a Wayland surface — no XWayland
involved, proper HDR support (if your display supports it), better vsync via
Wayland's presentation protocol.

### hwdec=auto-safe

Hardware decoding offloads video decoding from CPU to GPU. This saves power on laptops
and allows playing high-bitrate 4K content smoothly.

`hwdec=auto-safe` (vs just `hwdec=auto`) uses hardware decoding only for codecs where
it's known to work reliably on Linux. `auto` would try NVDEC/VDPAU/VA-API
aggressively and sometimes causes green screens or crashes on certain hardware/driver
combinations. `auto-safe` is conservative and falls back to software if needed.

---

## 13. i3 to niri keybinding migration

### Layout model differences

**i3** uses a **tree-based layout**. Every window is a node in a tree. You can nest
containers, split horizontally or vertically, stack windows, etc. Workspaces are
named/numbered and fixed to monitors. You move a window "to workspace 3" and it
teleports there.

**niri** uses a **scrollable column layout**. Windows are arranged in columns on an
infinite horizontal canvas. Workspaces exist per monitor and are dynamic (automatically
created/destroyed). There's no concept of splitting a container — instead you "consume"
a window into a column (stacking vertically) or "expel" it back out.

This is a fundamentally different mental model. i3's `split h/v`, `layout stacking`,
`layout tabbed` concepts don't map 1:1.

### What was ported from i3

| i3 bind | i3 action | niri bind | niri action |
|---------|-----------|-----------|-------------|
| Mod+Return | alacritty | Mod+Return | alacritty |
| Mod+D | rofi -show drun | Mod+D | fuzzel |
| Mod+W | kill window | Mod+W | close-window |
| Mod+1..9 | switch workspace | Mod+1..9 | focus-workspace |
| Mod+Shift+1..9 | move to workspace | Mod+Ctrl+1..9 | move-column-to-workspace |
| Mod+T | Telegram | Mod+T | Telegram (NEW) |
| Mod+E | Thunar | Mod+E | Thunar (NEW) |
| Mod+B | bookmarks | Mod+B | bookmarks-rofi.sh (NEW) |
| Mod+Shift+C | webcam.sh | Mod+Shift+C | webcam.sh (NEW) |
| Mod+Shift+P | power-menu.sh | Mod+Shift+P | power-menu.sh (was power-off-monitors) |
| Print | flameshot gui | Print | flameshot gui |
| Mod+Shift+F | fullscreen | Mod+Shift+F | fullscreen-window |

### What couldn't be ported (conflicts with niri's native binds)

| i3 bind | i3 action | niri's existing use | Resolution |
|---------|-----------|---------------------|------------|
| Mod+F | librewolf | maximize-column | Use fuzzel or Mod+D to launch |
| Mod+C | code (VS Code) | center-column | Use fuzzel |
| Mod+Shift+E | folder-menu-rofi | quit | Can't use same key for quit + app |

`Mod+Shift+E` in niri is `quit` (with a confirmation dialog). This is too dangerous to
rebind accidentally.

### What niri has that i3 didn't

- `Mod+V` — toggle floating/tiling for the focused window
- `Mod+Q` — toggle tabbed column display
- `Mod+R` / `Mod+Shift+R` — cycle preset column widths / window heights
- `Mod+BracketLeft/Right` — consume/expel windows from columns
- `Mod+O` — overview (zoomed-out workspace view)
- `Mod+U/I` — move between workspaces by direction (i3 had only by number)

### Window rules replacing i3's for_window

In i3, you'd write:
```
for_window [class="mpv"] fullscreen enable
```

In niri, `window-rule` blocks do the same job but match on Wayland app IDs instead of
X11 class names:
```kdl
window-rule {
    match app-id="^mpv$"
    open-fullscreen true
}
```

The difference: X11 window classes are set by the app and can be anything. Wayland app
IDs follow the reverse-DNS convention (e.g., `org.mozilla.firefox`, `mpv`, `alacritty`).
You can find an app's ID with: `niri msg windows` while it's running.

---

## 14. Summary of all changed files

### `~/dotfiles-arch/home_dir/dotfiles/.zprofile` (symlinked to `~/.zprofile`)

**Why changed**: niri is started here via `exec niri`. Environment variables exported
before `exec` are inherited by niri and all apps it spawns. Without this, apps had no
way to know they were in a Wayland session.

**What was added**: 6 environment variable exports before `exec niri`:
- `XDG_SESSION_TYPE=wayland` — most critical, gates Wayland behavior in many apps
- `XDG_CURRENT_DESKTOP=niri` — desktop identity (moved here from niri config)
- `ELECTRON_OZONE_PLATFORM_HINT=auto` — Electron apps use native Wayland
- `MOZ_ENABLE_WAYLAND=1` — Firefox/librewolf native Wayland
- `QT_QPA_PLATFORM=wayland` — Qt apps (Telegram, etc.) native Wayland
- `SDL_VIDEODRIVER=wayland` — SDL games/apps native Wayland

---

### `~/.config/niri/config.kdl`

Multiple changes:

**Mouse natural-scroll removed**:
```kdl
// before
mouse { natural-scroll }
// after
mouse { /* natural-scroll commented out */ }
```
Reason: natural-scroll inverts mouse wheel; correct for touchpad, wrong for mice.

**Output block uncommented + scale fixed**:
```kdl
// before (silently disabled by /- prefix)
/-output "eDP-1" { scale 2; ... }
// after
output "eDP-1" { mode "1920x1080@120.030"; scale 1; transform "normal"; }
```
Reason: `/-` in KDL disables the entire node. Without it, niri auto-detected scale 2.

**dbus-update-activation-environment expanded**:
```kdl
// before
spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP=niri"
// after
spawn-at-startup "dbus-update-activation-environment" "--systemd" "DISPLAY" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP" "XDG_SESSION_TYPE" "ELECTRON_OZONE_PLATFORM_HINT" "QT_QPA_PLATFORM"
```
Reason: D-Bus-activated services need these vars; now they're set in .zprofile first,
this line propagates them into the D-Bus/systemd user session.

**New keybinds added**:
- `Mod+T` → Telegram
- `Mod+E` → Thunar
- `Mod+B` → bookmarks-rofi.sh
- `Mod+Shift+C` → webcam.sh
- `Mod+Shift+P` → power-menu.sh (was power-off-monitors; moved to Mod+Ctrl+Shift+P)
- `Print` → flameshot gui (was niri's native screenshot)

**Window rules added** (ported from i3 `for_window`):
- mpv: `open-fullscreen true`
- nsxiv: `open-fullscreen true`

---

### `~/.config/code-flags.conf` (new file)

VS Code reads this file and appends its contents as CLI flags on startup.

```
--ozone-platform-hint=auto
--enable-features=WaylandWindowDecorations
```

Reason: Belt-and-suspenders for VS Code Wayland support on top of the env var.
`WaylandWindowDecorations` lets niri draw the window titlebar instead of VS Code.

---

### `~/.local/share/applications/spotify.desktop`

```ini
// before
Exec=spotify %U
// after
Exec=spotify --ozone-platform=wayland %U
```

Reason: Spotify uses CEF (Chromium Embedded Framework), not Electron. The
`ELECTRON_OZONE_PLATFORM_HINT` env var doesn't affect it. The flag must be passed on
the command line. Local desktop file overrides the system one and survives Spotify
reinstalls (but NOT Spotify updates to its own system desktop file — check occasionally).

---

### `~/.config/mpv/mpv.conf` (new file)

```ini
vo=gpu
gpu-context=wayland
hwdec=auto-safe
```

Reason: Without this, mpv might use the X11 GPU context (via XWayland) or autodetect
incorrectly. Explicit Wayland context ensures proper vsync, HDR, and presentation
timing. `hwdec=auto-safe` enables hardware video decoding on the GPU (saves power,
enables smooth 4K) without the instability of `hwdec=auto`.

---

## Further reading

- niri wiki: https://github.com/YaLTeR/niri/wiki
- Wayland architecture deep-dive: https://wayland.freedesktop.org/architecture.html
- freedesktop.org XDG specs: https://specifications.freedesktop.org/
- Arch Wiki: Wayland — covers nearly everything in more depth
- Arch Wiki: Environment variables — how the env chain works
- libinput documentation: https://wayland.freedesktop.org/libinput/doc/latest/
- KDL language spec: https://kdl.dev
