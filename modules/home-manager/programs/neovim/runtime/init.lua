-- Entry point of the live tree. runtime-layer.nix sources this last, so every
-- module below runs after nvf's generated configuration and can override it.
require("core.options")
require("core.keymaps")
require("core.commands")
require("core.autocmds")
