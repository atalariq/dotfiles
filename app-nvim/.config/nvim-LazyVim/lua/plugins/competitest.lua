local options = { noremap = true, silent = false }

-- Requirements:
-- - https://github.com/xeluxee/competitest.nvim
-- - https://github.com/jmerle/competitive-companion
return {
  "xeluxee/competitest.nvim",
  dependencies = { "muniftanjim/nui.nvim", lazy = true },
  cmd = "CompetiTest",
  keys = {
    { "<leader>cpa", "<CMD>CompetiTest add_testcase<CR>", options, desc = "CP: add testcases" },
    { "<leader>cpe", "<CMD>CompetiTest edit_testcase<CR>", options, desc = "CP: edit testcases" },
    { "<leader>cpd", "<CMD>CompetiTest delete_testcase<CR>", options, desc = "CP: delete testcases" },
    { "<leader>cpr", "<CMD>CompetiTest run<CR>", options, desc = "CP: run testcases" },
    { "<leader>cpD", "<CMD>CompetiTest receive problem<CR>", options, desc = "CP: download testcases" },
    { "<leader>cpp", "<CMD>CompetiTest receive problem<CR>", options, desc = "CP: download testcases" },
    { "<leader>cpc", "<CMD>CompetiTest receive contest<CR>", options, desc = "CP: download testcases" },
  },
  opts = {
    local_config_file_name = ".competitest.lua",

    floating_border = "rounded",
    floating_border_highlight = "FloatBorder",
    picker_ui = {
      width = 0.2,
      height = 0.3,
      mappings = {
        focus_next = { "j", "<down>", "<Tab>" },
        focus_prev = { "k", "<up>", "<S-Tab>" },
        close = { "<esc>", "<C-c>", "q", "Q" },
        submit = { "<cr>" },
      },
    },
    editor_ui = {
      popup_width = 0.4,
      popup_height = 0.6,
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
        width = 0.5,
        height = 0.5,
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
    compile_command = {
      c = { exec = "gcc", args = { "-Wall", "../$(FNAME)", "-o", "$(FNOEXT)" } },
      cpp = { exec = "g++", args = { "-Wall", "-Wextra", "../$(FNAME)", "-o", "$(FNOEXT)" } },
      rust = { exec = "rustc", args = { "../$(FNAME)" } },
      java = { exec = "javac", args = { "../$(FNAME)" } },
    },
    running_directory = "./bin",
    run_command = {
      c = { exec = "./$(FNOEXT)" },
      cpp = { exec = "./$(FNOEXT)" },
      rust = { exec = "./$(FNOEXT)" },
      python = { exec = "python", args = { "$(FNAME)" } },
      java = { exec = "java", args = { "$(FNOEXT)" } },
    },

    companion_port = 27121,
    receive_print_message = true,
    open_received_problems = true,
    open_received_contests = true,

    received_problems_prompt_path = true,
    received_contests_prompt_directory = false,
    received_contests_prompt_extension = false,

    received_files_extension = "cpp",
    -- received_problems_directory = "$(HOME)/Documents/Programming/Competitive/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)",
    -- received_contests_directory = "$(HOME)/Documents/Programming/Competitive/$(JUDGE)/$(CONTEST)",
    received_problems_directory = "$(HOME)/Documents/repos/cp/problems/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)",
    received_contests_directory = "$(HOME)/Documents/repos/cp/problems/$(JUDGE)/$(CONTEST)",
    received_contests_problems_path = "$(PROBLEM).$(FEXT)",

    template_file = "~/.config/nvim/template/competitest/template.$(FEXT)",
    evaluate_template_modifiers = true,
    date_format = "%c",
  },
}
