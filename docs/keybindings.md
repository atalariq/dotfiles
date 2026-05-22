# Keybinding Convention

Standard key-to-action mappings across mangoWM, niri, and Hyprland.
Enforced by review, not mechanically. When adding or changing a bind in one WM,
update the others to follow this convention.

The modifier key is `Super` (Windows key) everywhere.
Niri uses the token `Mod` which resolves to Super.

## Window Management

| Action                         | Canonical Key           | Mango                   | Niri                    | Hyprland               |
| ------------------------------ | ----------------------- | ----------------------- | ----------------------- | ---------------------- |
| Focus left                     | Super+H / Super+Left    | both                    | both                    | both                   |
| Focus right                    | Super+L / Super+Right   | both                    | both                    | both                   |
| Focus up                       | Super+K / Super+Up      | both                    | both                    | both                   |
| Focus down                     | Super+J / Super+Down    | both                    | both                    | both                   |
| Focus previous                 | Super+Tab               | Super+Tab               | —                       | —                      |
| Swap/Move window left          | Super+Shift+Left        | Super+Shift+Left        | — (move column instead) | Super+Alt+H            |
| Swap/Move window right         | Super+Shift+Right       | Super+Shift+Right       | — (move column instead) | Super+Alt+L            |
| Swap/Move window up            | Super+Shift+Up          | Super+Shift+Up          | — (move window instead) | Super+Alt+K            |
| Swap/Move window down          | Super+Shift+Down        | Super+Shift+Down        | — (move window instead) | Super+Alt+J            |
| Resize mode (enter)            | Super+R                 | Resize keymode          | —                       | Resize submap          |
| Close/Kill window              | Super+Q                 | Super+Q                 | Super+Q                 | Alt+F4                 |
| Quit WM                        | Super+Ctrl+Q            | Super+Shift+Alt+Q       | —                       | Super+Ctrl+Q           |
| Toggle floating                | Super+Shift+Space       | Super+Shift+Space       | Super+Shift+Space       | Super+Space            |
| Toggle fullscreen              | Super+Shift+F           | Super+Shift+F           | Super+Shift+F           | Super+F12              |
| Toggle maximize/tabbed         | Super+M                 | Super+M                 | Super+M                 | —                      |
| Minimize window                | Super+I                 | Super+I                 | —                       | —                      |

### Notes

- **Mango** uses a sticky resize keymode (Super+R → release → arrow keys). Hyprland uses a submap. Niri has per-column/window resize keys (Mod+R/Shift+R/Ctrl+R).
- **Niri** conceptualizes movement as columns (vertical stacks of windows). Swapping moves columns, not individual windows. This is a paradigm difference — not a deviation.
- **Hyprland** uses `Alt+F4` for close/kill. This is intentional — single-key with Super+Q is preferred but not always available.

## Workspace / Tag Navigation

| Action                          | Canonical Key | Mango        | Niri         | Hyprland     |
| ------------------------------- | ------------- | ------------ | ------------ | ------------ |
| Switch to workspace 1–9/10      | Super+1–0     | 1–9          | 1–9          | 1–0          |
| Switch to next workspace        | Super+]       | Super+]      | Super+PageDown | Super+PageDown |
| Switch to previous workspace    | Super+[       | Super+[      | Super+PageUp | Super+PageUp |
| Move window to workspace 1–9/10 | Super+Shift+1–0 | 1–9        | 1–9          | 1–0          |
| Move window to next workspace   | Super+Shift+] | Super+Shift+] | —            | Super+Shift+PageDown |
| Move window to previous workspace | Super+Shift+[ | Super+Shift+[ | —            | Super+Shift+PageUp |

### Notes

- **Mango** calls them "tags" (hybrid workspaces). `Super+1–9` views tag 1–9. `Super+Shift+1–9` tags the focused window to that tag (move). `Super+Alt+1–9` tags silently (move without switching view) — mango-only concept.
- **Niri** `Super+Shift+1–9` moves the column to workspace 1–9 permanently, unlike mango where tags are non-exclusive.

## Monitor / Screen

| Action                     | Canonical Key    | Mango                  | Niri                     | Hyprland |
| -------------------------- | ---------------- | ---------------------- | ------------------------ | -------- |
| Focus monitor left         | Super+Ctrl+Left  | Super+Alt+,            | Super+Ctrl+Left          | —        |
| Focus monitor right        | Super+Ctrl+Right | Super+Alt+.            | Super+Ctrl+Right         | —        |
| Focus monitor up           | Super+Ctrl+Up    | —                      | Super+Ctrl+Up            | —        |
| Focus monitor down         | Super+Ctrl+Down  | —                      | Super+Ctrl+Down          | —        |
| Move window to monitor left  | Super+Ctrl+Shift+Left | Super+Ctrl+Shift+, | Super+Ctrl+Shift+Left  | —        |
| Move window to monitor right | Super+Ctrl+Shift+Right | Super+Ctrl+Shift+. | Super+Ctrl+Shift+Right | —        |

### Notes

- **Mango** uses `,`/`.` for left/right monitor navigation (laptop-only layout). Primary binds use arrows.
- **Niri** supports multi-monitor in a grid (up/down/left/right). Mango and Hyprland are side-by-side only.

## App Launching (via Controller)

All app launching uses `controller app <name>`.

| App        | Canonical Key        | Mango                | Niri                 | Hyprland   |
| ---------- | -------------------- | -------------------- | -------------------- | ---------- |
| Terminal   | Super+Return         | Super+Return         | Super+Return         | Super+Return |
| Browser    | Super+W              | Super+W              | Super+W              | Super+W    |
| File manager | Super+F            | Super+F              | Super+F              | Super+F    |

### Notes

- **Mango** uses `spawn-and-raise` (switch to workspace then focus window if exists, spawn if not). Niri uses `run-or-raise` script. Hyprland uses window rules.
- Additional apps (chat, notes, music) use `controller app <name>`. Key binding per WM is not standardized — bind to taste.

## Media Control (via Controller)

All media control uses `controller player <action>`.

| Action     | Key             | All WMs    |
| ---------- | --------------- | ---------- |
| Play/Pause | XF86AudioPlay   | ✓          |
| Previous   | XF86AudioPrev   | ✓          |
| Next       | XF86AudioNext   | ✓          |

## System Controls (via Controller)

All system controls use `controller <domain> <action>`.

| Action               | Key                     | All WMs |
| -------------------- | ----------------------- | ------- |
| Volume up            | XF86AudioRaiseVolume    | ✓       |
| Volume down          | XF86AudioLowerVolume    | ✓       |
| Volume mute          | XF86AudioMute           | ✓       |
| Brightness up        | XF86MonBrightnessUp     | ✓       |
| Brightness down      | XF86MonBrightnessDown   | ✓       |
| Keyboard backlight up   | XF86KbdBrightnessUp  | ✓       |
| Keyboard backlight down | XF86KbdBrightnessDown | ✓       |

## Noctalia Shell (via Controller)

All noctalia actions use `controller noctalia <action>`.

| Action              | Canonical Key    | Mango          | Niri           | Hyprland |
| ------------------- | ---------------- | -------------- | -------------- | -------- |
| Launcher            | Super+Space      | Super+Space    | Super+Space    | —        |
| Clipboard manager   | Super+V          | Super+V        | Super+V        | —        |
| Emoji picker        | Super+B          | Super+E        | Super+B        | —        |
| Control center      | Super+C          | Super+C        | Super+C        | —        |
| Notification center | Super+N          | Super+N        | Super+N        | —        |
| Wallpaper browser   | Super+Y          | Super+Y        | Super+Y        | —        |
| Settings            | Super+,          | Super+,        | Super+,        | —        |
| Session menu        | Super+Escape     | Super+Escape   | Super+Escape   | —        |

### Notes

- **Hyprland** does not use Noctalia shell. No noctalia binds apply.
- **Mango** uses `Super+E` for emoji (historical). Canonical is `Super+B` to match niri.

## Screenshots

| Action          | Canonical Key      | Mango           | Niri        | Hyprland   |
| --------------- | ------------------ | --------------- | ----------- | ---------- |
| Area screenshot | XF86LaunchA        | XF86LaunchA     | XF86LaunchA | Print      |
| Full screen     | Ctrl+XF86LaunchA   | Ctrl+XF86LaunchA | Ctrl+XF86LaunchA | Shift+Print |
| Active window   | Alt+XF86LaunchA    | Alt+XF86LaunchA  | Alt+XF86LaunchA | Alt+Print  |
| Annotate        | Shift+XF86LaunchA  | Shift+XF86LaunchA | —           | —          |
| OCR             | Super+XF86LaunchA  | Super+XF86LaunchA | —           | —          |

### Notes

- **Hyprland** uses Print key instead of XF86LaunchA. Screenshot tool is grimblast, same as mango/niri.

## Deviance Log

Where a WM intentionally deviates from the canonical key, record it here with a reason.

| WM       | Action       | Canonical | Actual    | Reason                                                              |
| -------- | ------------ | --------- | --------- | ------------------------------------------------------------------- |
| Mango    | Emoji picker | Super+B   | Super+E   | Historical bind, not yet migrated. Migrate if no collision.         |
| Hyprland | Kill window  | Super+Q   | Alt+F4    | Super+Q already used for terminal raise-or-launch. Low priority.    |
| Hyprland | Toggle float | Super+Shift+Space | Super+Space | Super+Shift+Space hard to hit one-handed. Acceptable for now. |
| Hyprland | Launcher     | Super+Space | Super+R  | Super+Space conflicts with toggle float. Noctalia not used here.    |
