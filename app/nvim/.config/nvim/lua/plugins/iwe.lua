return {
  "iwe-org/iwe.nvim",
  config = function()
    require("iwe").setup({
      lsp = {
        cmd = { "iwes" },
        auto_format_on_save = false,
        enable_inlay_hints = true,
        debounce_text_changes = 500,
      },
      mappings = {
        enable_markdown_mappings = true, -- Core markdown editing keybindings
        enable_picker_keybindings = true, -- Set to true to enable gf, gs, ga, g/, gb, gR, go
        enable_lsp_keybindings = true, -- Set to true to enable IWE-specific LSP keybindings
        enable_preview_keybindings = true, -- Set to true to enable preview keybindings
        leader = "<leader>",
        localleader = "<localleader>",
      },
      picker = {
        backend = "auto", -- "auto", "telescope", "fzf_lua", "snacks", "mini", "vim_ui"
        fallback_notify = true,
      },
      telescope = {
        enabled = false,
        setup_config = true,
        load_extensions = { "ui-select", "emoji" },
      },
      preview = {
        output_dir = "~/tmp/preview",
        temp_dir = "/tmp",
        auto_open = false,
      },
    })
  end,
}
