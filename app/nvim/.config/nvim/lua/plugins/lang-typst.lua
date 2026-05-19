return {
  {
    "chomosuke/typst-preview.nvim",
    cmd = { "TypstPreview", "TypstPreviewToggle", "TypstPreviewUpdate" },
    keys = {
      { "<leader>cp", false },
    },
    opts = {
      debug = false,
      -- open_cmd = "firefox %s -P previewer --class previewer",
      open_cmd = "/opt/brave-bin/brave --app=%s --profile-directory=Default --app-id=previewer",
      port = 0,
      host = "127.0.0.1",
      invert_colors = "never",
      follow_cursor = true,
      dependencies_bin = {
        tinymist = "/usr/bin/tinymist",
        websocat = "/usr/bin/websocat",
      },
    },
  },
}
