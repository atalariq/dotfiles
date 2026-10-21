# yazi

Requires Yazi 26.9.1 (pinned).

Manual copy: `yazi.toml` → `$XDG_CONFIG_HOME/yazi/yazi.toml`. If XDG_CONFIG_HOME is unset, use `~/.config`.
Copy the listed files (or entire folder for Neovim) without needing this repository.

No plugins or first-run downloads. Optional file previews need their own tools (for example ffmpeg, poppler or ImageMagick); this baseline does not install all preview backends. This TOML has no assumed local include facility: edit the native file or use Yazi-supported runtime options. Other files in the destination folder remain unmanaged.
