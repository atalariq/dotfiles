{ ... }:
{
  imports = [ ../../../modules/home-manager ];
  home.username = "atalariq";
  home.homeDirectory = "/home/atalariq";
  home.stateVersion = "26.05";
  xdg.enable = true;
  programs.home-manager.enable = true;
  # Every choice is visible here; importing a bundle never enables its siblings.
  dotfiles = {
    terminal.bash.enable = true;
    terminal.direnv.enable = true;
    terminal.fish.enable = true;
    terminal.atuin.enable = true;
    terminal.zoxide.enable = true;
    terminal.starship.enable = true;
    terminal.core.enable = true;
    terminal.bat.enable = true;
    terminal.fd.enable = true;
    terminal.ripgrep.enable = true;
    terminal.fzf.enable = true;
    terminal.yazi.enable = true;

    development.git.enable = true;
    development.gh.enable = true;
    development.lazygit.enable = true;
    terminal.tmux.enable = true;
    editors.neovim.enable = true;
    editors.vim.enable = true;
    development.tools.enable = true;
    academic.typst.enable = true;
    agents.rtk.enable = true;
    agents.tirith.enable = true;
    agents.opencode.enable = true;
    agents.codex.enable = true;
    agents.claude.enable = true;

    desktop.mango.enable = true;
    desktop.mango.monitorConfig = "monitor_rule = name:eDP-1,width:1920,height:1200,refresh:60,x:0,y:0,scale:1.25,vrr:0,rr:0";
    desktop.noctalia.enable = true;
    desktop.espanso.enable = true;
    desktop.helpers.enable = true;
    desktop.brave.enable = true;
    desktop.chrome.enable = true;
    desktop.files.enable = true;
    desktop.bitwarden.enable = true;
    desktop.discord.enable = true;
    working.slack.enable = true;
    working.linear.enable = true;
    desktop.appearance.enable = true;
    desktop.rofi.enable = true;
    working.plane.enable = true;
    terminal.kitty.enable = true;
    terminal.btop.enable = true;
    terminal.fastfetch.enable = true;
    terminal.status.enable = true;
    terminal.vimv.enable = true;
    media.mpd.enable = true;
    media.rmpc.enable = true;
    media.ncmpcpp.enable = true;
    media.mpv.enable = true;
    downloader.aria2.enable = true;
    downloader.yt-dlp.enable = true;
    media.jellyfin-helper.enable = true;
    media.obs-studio.enable = true;
    media.capture.enable = true;
    academic.anki.enable = true;
    academic.obsidian.enable = true;
    academic.readest.enable = true;
    academic.zotero.enable = false;
    development.android.enable = true;
    development.containers.enable = true;
    security.secrets.enable = true;
    security.tools.enable = true;
    agents.hermes.enable = true;
    terminal.herdr.enable = true;
    # The service waits for an explicitly provisioned immutable image pin.
    agents.omniroute.enable = true;
    security.rsync.enable = true;
    gaming.steam.enable = true;
    gaming.osu.enable = true;
    gaming.doom.enable = true;
    gaming.mcpe.enable = true;
    gaming.gba.enable = true;
    gaming.ps1.enable = true;
    gaming.snes.enable = true;
    gaming.ps2.enable = true;
  };
}
