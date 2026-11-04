{
  lib,
  pkgs,
  ...
}:
let
  apps = import ./apps.nix { inherit pkgs; };
  ides = import ../../../modules/packages/ides.nix { inherit pkgs lib; };
in
{
  imports = [
    ../../../modules/nixos
    ./hardware-configuration.nix
    ./per-device.nix
  ];

  # System owns GUIs. The IDE list is still written by hand in apps.nix, but a
  # declared stack without its editor is a mistake worth failing eval for.
  assertions = [
    {
      assertion = lib.all (pkg: builtins.elem pkg apps.gui) (ides.expected apps.stacks);
      message = "hosts/nixos/thinkpad-x13/apps.nix: a declared stack is missing its JetBrains IDE in `gui`.";
    }
  ];
  networking.hostName = "thinkpad-x13";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = builtins.listToAttrs (
    map
      (name: {
        inherit name;
        value = "en_GB.UTF-8";
      })
      [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ]
  );
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Device input policy belongs to this host; headless hosts stay inert.
  services.keyd = {
    enable = true;
    keyboards.superkey = {
      ids = [ "*" ];
      settings = {
        main.capslock = "overload(superkey, esc)";
        "superkey:C-M-A" = { };
      };
    };
  };
  users.users.atalariq = {
    isNormalUser = true;
    description = "Atalariq Barra Hadinugraha";
    shell = pkgs.bash;
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "gamemode"
      "tss"
    ];
    linger = true;
  };
  dotfiles = {
    system.base.enable = true;
    system.appimage.enable = true;
    desktop.audio.enable = true;
    desktop.bluetooth.enable = true;
    desktop.files.enable = true;
    desktop.printing.enable = true;
    desktop.fonts.enable = true;
    desktop.espanso.enable = true;
    desktop.umbriel.enable = true;
    desktop.greeter.enable = true;
    desktop.noctalia.enable = true;
    security.authentication.enable = true;
    security.ssh-server.enable = false;
    security.secrets.enable = true;
    security.tpm.enable = true;
    system.podman.enable = true;
    system.emulation.enable = true;
    hardware.thinkpad.enable = true;
    gaming.enable = true;
  };
  services.displayManager.defaultSession = "umbriel";
  services.displayManager.noctalia-greeter.settings.session.default = "Umbriel";

  # Remote access to the homelab and to the tailnet; the shared LAN is not
  # trusted. Headscale later only changes the login server.
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Attic CLI for pushing store paths. Substituter URL and the cache public key
  # are filled in after `attic cache create main` on the homelab:
  #   dotfiles.system.binary-cache.client = {
  #     enable = true;
  #     url = "http://homelab-x456urk:8080/main";
  #     publicKey = "main:...";
  #   };
  environment.systemPackages = apps.gui ++ [
    pkgs.attic-client
    pkgs.tailscale
  ];

  system.stateVersion = "26.05";
}
