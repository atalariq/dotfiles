# Headless network setup: NetworkManager keeps Ethernet, Wi-Fi and phone USB
# tethering on one stack, while the tailnet interface stays unmanaged.
{
  networking.networkmanager = {
    enable = true;
    unmanaged = [ "interface-name:tailscale0" ];
    wifi = {
      powersave = false;
      scanRandMacAddress = false;
    };
  };

  # NetworkManager owns Wi-Fi through wpa_supplicant; do not enable a second
  # wireless stack alongside it. The NixOS NM module already manages the
  # wpa_supplicant backend, so no explicit networking.wireless switch here.

  # The ath9k card reports PCIe AER noise on this laptop. Disable its power
  # saving first; if the spam persists, use pcie_aspm=off or blacklist ath9k
  # after the machine is on wired/Headscale access.
  boot.extraModprobeConfig = "options ath9k ps_enable=0";

  users.motd = ''
    homelab-x456urk
    - Wi-Fi:      nmtui
    - Tailnet:    sudo tailscale status
    - Jellyfin:   http://<ip>:8096
    - Navidrome:  http://<ip>:4533
    - BookOrbit:  http://<ip>:3000
  '';
}
