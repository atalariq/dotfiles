{ pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager
  ];
  home = {
    sessionVariables.DOTFILES_HOST = "homelab-x456urk";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
    # Server-side inspection tools. Neovim comes from the shared nvf kernel in
    # its minimal profile: no language servers, just a usable editor for the
    # occasional config fix over SSH.
    packages = with pkgs; [
      aria2
      btop
      fastfetch
      yazi
      yt-dlp
    ];
    # beets tags and moves music into the Navidrome library; keeping the
    # config here means the command behaves the same after a reinstall.
    file.".config/beets/config.yaml".text = ''
      directory: /data/media/music
      library: /data/media/music/library.db

      import:
        move: yes
        write: yes
        autotag: yes
        timid: no
        incremental: yes

      paths:
        default: $albumartist/$album%aunique{}/$track $title

      permissions:
        file: 0644
        dir: 0755
    '';
  };
  dotfiles = {
    deployment.liveApps = [ "tmux" ];
    programs.cli.neovim = {
      enable = true;
      profile = "minimal";
      nerdFont = false;
    };
  };
  # Headless: the shared CLI bundle is on by default, no appearance or desktop
  # modules are selected.
}
