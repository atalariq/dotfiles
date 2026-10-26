{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  programs.herdr.package =
    lib.mkIf config.programs.herdr.enable
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
  programs.herdr.settings = lib.mkIf config.programs.herdr.enable {
    "onboarding" = false;
    "theme" = {
      "name" = if config.dotfiles.appearance.enable then "custom" else "terminal";
    };
    "terminal" = { };
    "update" = { };
    "keys" = {
      "prefix" = "ctrl+b";
      "help" = "prefix+?";
      "settings" = [
        "prefix+s"
        "prefix+,"
      ];
      "detach" = "prefix+q";
      "reload_config" = "prefix+shift+r";
      "open_notification_target" = "prefix+o";
      "workspace_picker" = "prefix+w";
      "goto" = "prefix+g";
      "new_workspace" = "prefix+shift+n";
      "rename_workspace" = "prefix+shift+w";
      "close_workspace" = "prefix+shift+d";
      "new_worktree" = "prefix+shift+g";
      "next_workspace" = [
        "ctrl+alt+."
        "alt+shift+j"
      ];
      "previous_workspace" = [
        "ctrl+alt+,"
        "alt+shift+k"
      ];
      "switch_workspace" = "prefix+shift+1..9";
      "previous_agent" = "alt+shift+p";
      "next_agent" = "alt+shift+n";
      "focus_agent" = "prefix+alt+1..9";
      "remote_image_paste" = "ctrl+alt+v";
      "new_tab" = [
        "prefix+c"
        "prefix+t"
      ];
      "rename_tab" = "prefix+shift+t";
      "close_tab" = "prefix+shift+x";
      "next_tab" = [
        "prefix+n"
        "alt+shift+l"
      ];
      "previous_tab" = [
        "prefix+p"
        "alt+shift+h"
      ];
      "switch_tab" = "prefix+1..9";
      "rename_pane" = "prefix+shift+p";
      "edit_scrollback" = "prefix+e";
      "focus_pane_left" = [
        "prefix+h"
        "alt+h"
      ];
      "focus_pane_down" = [
        "prefix+j"
        "alt+j"
      ];
      "focus_pane_up" = [
        "prefix+k"
        "alt+k"
      ];
      "focus_pane_right" = [
        "prefix+l"
        "alt+l"
      ];
      "cycle_pane_next" = "prefix+tab";
      "cycle_pane_previous" = "prefix+shift+tab";
      "close_pane" = "prefix+x";
      "split_vertical" = "prefix+v";
      "split_horizontal" = "prefix+minus";
      "zoom" = "prefix+z";
      "resize_mode" = "prefix+r";
      "toggle_sidebar" = "prefix+b";
      "navigate_workspace_up" = "up";
      "navigate_workspace_down" = "down";
      "navigate_pane_left" = "h";
      "navigate_pane_down" = "j";
      "navigate_pane_up" = "k";
      "navigate_pane_right" = "l";
      "command" = [
        {
          "key" = "prefix+alt+g";
          "type" = "pane";
          "command" = "lazygit";
        }
      ];
    };
    "ui" = {
      "sidebar_width" = 27;
      "sidebar_min_width" = 18;
      "sidebar_max_width" = 36;
      "mouse_capture" = true;
      "confirm_close" = true;
      "prompt_new_tab_name" = false;
      "pane_borders" = true;
      "pane_gaps" = true;
      "show_agent_labels_on_pane_borders" = true;
      "agent_panel_sort" = "spaces";
      "accent" = "cyan";
      "toast" = {
        "delivery" = "herdr";
        "herdr" = {
          "position" = "bottom-right";
        };
        "clipboard" = {
          "enabled" = true;
          "position" = "bottom-center";
        };
      };
      "sound" = {
        "enabled" = false;
      };
    };
    "session" = {
      "resume_agents_on_restore" = true;
    };
    "remote" = {
      "manage_ssh_config" = true;
    };
    "experimental" = {
      "pane_history" = true;
      "switch_ascii_input_source_in_prefix" = false;
    };
    "advanced" = { };
  };
}
