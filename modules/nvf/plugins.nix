# Neovim plugins that are not packaged in nixpkgs or nvf. Everything here is
# pinned with fetchFromGitHub so flake.nix stays limited to large dependencies.
#
# Returns both the package set (for the Home Manager wrapper's conditional
# theme plugin) and the nvf module that installs/lazy-loads them.
{ pkgs }:
let
  kitehost = pkgs.vimUtils.buildVimPlugin {
    pname = "kitehost.nvim";
    version = "0-unstable-2026-10-01";
    src = pkgs.fetchFromGitHub {
      owner = "selimacerbas";
      repo = "kitehost.nvim";
      rev = "4cb5c94a84cc653e0b32e0c9aed95465a36fc94d";
      hash = "sha256-XHbCbooxN+29qCQT9XasihZFdYonDaWufFUSNowNdnk=";
    };
  };

  # mdkite 2.x requires kitehost >= 2.0.
  mdkite = pkgs.vimUtils.buildVimPlugin {
    pname = "mdkite.nvim";
    version = "0-unstable-2026-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "selimacerbas";
      repo = "mdkite.nvim";
      rev = "dded03dc6cce87364b48260b2ffbace575a6add7";
      hash = "sha256-V3NRsP7ZGR+6p5wC/lS1nebnPsLevLgT4HWcDO1TKyo=";
    };
    dependencies = [ kitehost ];
  };

  # Owner's colorscheme, used only when Stylix is disabled.
  wana = pkgs.vimUtils.buildVimPlugin {
    pname = "wana.nvim";
    version = "0-unstable-2026-11-01";
    src = pkgs.fetchFromGitHub {
      owner = "atalariq";
      repo = "wana.nvim";
      rev = "892151e35b234ed7d3bbb2fb94569f0082763a74";
      hash = "sha256-QI7AvJ8EkHLUB0U2xzMY6XnsA9WQPNDm3QCtyq9BAcc=";
    };
  };

  # In-editor review annotations for agent/collaborator diffs. review.nvim
  # exports AI-ready markdown and stores comments per repository.
  review = pkgs.vimUtils.buildVimPlugin {
    pname = "review.nvim";
    version = "0-unstable-2026-11-01";
    src = pkgs.fetchFromGitHub {
      owner = "georgeguimaraes";
      repo = "review.nvim";
      rev = "0a379fae01709645956005f76c4650b7740931a3";
      hash = "sha256-VT5bGxbeIAWROcRNwx1HGOAP/CTMrZvqb+i2mcCDX7M=";
    };
    dependencies = [
      pkgs.vimPlugins.codediff-nvim
      pkgs.vimPlugins.nui-nvim
    ];
  };
in
{
  packages = {
    inherit
      kitehost
      mdkite
      wana
      review
      ;
  };

  module = {
    vim = {
      # The HTTP server must be on the packpath before mdkite loads, and lz.n
      # carries no dependency list, so it stays a start plugin while mdkite
      # loads on its own command.
      startPlugins = [ kitehost ];
      lazy.plugins = {
        "mdkite.nvim" = {
          package = mdkite;
          cmd = [
            "MdKite"
            "MdKite start"
          ];
          setupModule = "mdkite";
          setupOpts = {
            instance_mode = "takeover";
            port = 0;
            open_browser = true;
            default_theme = "dark";
            debounce_ms = 300;
          };
        };

        "review.nvim" = {
          package = review;
          # lz.n has no VeryLazy event; the command is the safe load trigger.
          cmd = [ "Review" ];
          setupModule = "review";
          setupOpts = {
            codediff.readonly = true;
            branch.base = "main";
            export.clipboard = true;
          };
        };
      };
    };
  };
}
