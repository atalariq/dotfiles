local options = { noremap = true, silent = false }
local cp_dir = "$(HOME)/Repos/cp"

-- Requirements:
-- - https://github.com/xeluxee/competitest.nvim
-- - https://github.com/jmerle/competitive-companion
return {
  "xeluxee/competitest.nvim",
  enabled = false,
  lazy = true,
  dependencies = { "muniftanjim/nui.nvim", lazy = true },
  cmd = "CompetiTest",
  keys = {
    { "<leader>cpa", "<CMD>CompetiTest add_testcase<CR>", options, desc = "CP: add testcases" },
    { "<leader>cpe", "<CMD>CompetiTest edit_testcase<CR>", options, desc = "CP: edit testcases" },
    { "<leader>cpd", "<CMD>CompetiTest delete_testcase<CR>", options, desc = "CP: delete testcases" },
    { "<leader>cpr", "<CMD>CompetiTest run<CR>", options, desc = "CP: run testcases" },
    { "<leader>cpD", "<CMD>CompetiTest receive problem<CR>", options, desc = "CP: download testcases (Problem)" },
    { "<leader>cpp", "<CMD>CompetiTest receive problem<CR>", options, desc = "CP: download testcases (Problem)" },
    { "<leader>cpc", "<CMD>CompetiTest receive contest<CR>", options, desc = "CP: download testcases (Contest)" },
  },
  opts = {
    local_config_file_name = ".competitest.lua",

    floating_border = "rounded",
    floating_border_highlight = "FloatBorder",
    picker_ui = {
      width = 0.3,
      height = 0.4,
      mappings = {
        focus_next = { "j", "<down>", "<Tab>" },
        focus_prev = { "k", "<up>", "<S-Tab>" },
        close = { "<esc>", "<C-c>", "q", "Q" },
        submit = { "<cr>" },
      },
    },
    editor_ui = {
      popup_width = 0.4,
      popup_height = 0.5,
      show_nu = true,
      show_rnu = false,
      normal_mode_mappings = {
        switch_window = { "<C-h>", "<C-l>", "<C-i>" },
        save_and_close = "<C-s>",
        cancel = { "q", "Q" },
      },
      insert_mode_mappings = {
        switch_window = { "<C-h>", "<C-l>", "<C-i>" },
        save_and_close = "<C-s>",
        cancel = "<C-q>",
      },
    },
    runner_ui = {
      interface = "popup",
      selector_show_nu = false,
      selector_show_rnu = false,
      show_nu = true,
      show_rnu = false,
      mappings = {
        run_again = "R",
        run_all_again = "<C-r>",
        kill = "K",
        kill_all = "<C-k>",
        view_input = { "i", "I" },
        view_output = { "a", "A" },
        view_stdout = { "o", "O" },
        view_stderr = { "e", "E" },
        toggle_diff = { "d", "D" },
        close = { "q", "Q" },
      },
      viewer = {
        width = 0.6,
        height = 0.6,
        show_nu = true,
        show_rnu = false,
        close_mappings = { "q", "Q" },
      },
    },
    popup_ui = {
      total_width = 0.8,
      total_height = 0.8,
      layout = {
        { 4, "tc" },
        { 5, { { 1, "so" }, { 1, "si" } } },
        { 5, { { 1, "eo" }, { 1, "se" } } },
      },
    },
    split_ui = {
      position = "right",
      relative_to_editor = true,
      total_width = 0.3,
      vertical_layout = {
        { 1, "tc" },
        { 1, { { 1, "so" }, { 1, "eo" } } },
        { 1, { { 1, "si" }, { 1, "se" } } },
      },
      total_height = 0.4,
      horizontal_layout = {
        { 2, "tc" },
        { 3, { { 1, "so" }, { 1, "si" } } },
        { 3, { { 1, "eo" }, { 1, "se" } } },
      },
    },

    save_current_file = true,
    save_all_files = false,
    multiple_testing = -1,
    maximum_time = 5000,
    output_compare_method = "squish",
    view_output_diff = false,

    testcases_directory = "./test",
    testcases_use_single_file = true,
    testcases_auto_detect_storage = true,
    testcases_single_file_format = "$(FNOEXT).testcases",

    compile_directory = "./bin",
    running_directory = "./bin",
    compile_command = {
      -- references: https://codeforces.com/blog/entry/64218 | https://codeforces.com/blog/entry/79024 | https://bytes.usc.edu/cs104/wiki/gcc
      cpp = {
        exec = "g++", --[[ clang++ | g++ ]]
        args = {
          "-std=c++20",
          "-O2",
          "-Wall",
          -- "-Wextra",
          -- "-Wshadow",
          -- "-Wconversion",
          -- "-Wfloat-equal",
          -- "-Wduplicated-cond",
          -- "-Wlogical-op",
          -- "-fsanitize=undefined,address",
          "../$(FNAME)",
          "-o",
          "$(FNOEXT)",
        },
      },
    },
    run_command = {
      cpp = { exec = "./$(FNOEXT)" },
    },
    companion_port = 27121,
    receive_print_message = true,
    open_received_problems = true,
    open_received_contests = true,

    received_problems_prompt_path = false,
    received_contests_prompt_directory = false,
    received_contests_prompt_extension = false,

    received_files_extension = "cpp",
    received_contests_directory = cp_dir .. "/problems/$(JUDGE)/$(CONTEST)",
    received_problems_path = cp_dir .. "/problems/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)",
    received_contests_problems_path = cp_dir .. "/problems/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)",

    template_file = vim.fn.stdpath("config") .. "/template/competitest/template.$(FEXT)",
    evaluate_template_modifiers = true,
    date_format = "%c",
  },
}
