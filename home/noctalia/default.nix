{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.noctalia.homeModules.default ];
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    checkConfig = true;
    customPalettes.wana = builtins.fromJSON (builtins.readFile ./config/wana.json);
    settings = {
      shell.polkit_agent = true;
      lockscreen = {
        enabled = true;
        fingerprint = true;
        lock_before_suspend = true;
      };
      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "wana";
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "gtk3"
            "gtk4"
            "qt"
            "kcolorscheme"
            "mango"
          ];
          enable_community_templates = false;
          user.kitty = {
            enabled = true;
            input_path = "${inputs.noctalia}/assets/templates/kitty/kitty.conf";
            output_path = "${config.xdg.configHome}/kitty/themes/noctalia.conf";
            post_hook = "${pkgs.procps}/bin/pkill -USR1 -x kitty || test $? -eq 1";
          };
        };
      };
    };
  };
}
