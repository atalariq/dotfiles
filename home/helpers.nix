{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [
    bash
    wl-clipboard
    wl-clip-persist
    cliphist
    playerctl
    grim
    slurp
    libnotify
    fyi
    imagemagick
  ];
  home.file.".local/script/autostart".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/autostart";
  home.file.".local/script/clipboard".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/clipboard";
  home.file.".local/script/clipboard-delete-fzf".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/clipboard-delete-fzf";
  home.file.".local/script/controller".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/controller";
  home.file.".local/script/import-gsettings".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/import-gsettings";
  home.file.".local/script/jellyfin-start-server".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/jellyfin-start-server";
  home.file.".local/script/noctalia-autostart".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/noctalia-autostart";
  home.file.".local/script/rsync-backup".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/rsync-backup";
  home.file.".local/script/server-mode".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/server-mode";
  home.file.".local/script/server-status".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/server-status";
  home.file.".local/script/vimv".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/scripts/vimv";
}
