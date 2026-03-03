return {
  "brianhuster/live-preview.nvim",
  config = function()
    require("livepreview.config").set({
      port = 55755,
      browser = "default",
      dynamic_root = false,
      sync_scroll = true,
      picker = "fzf-lua",
      address = "127.0.0.1",
    })
  end,
}
