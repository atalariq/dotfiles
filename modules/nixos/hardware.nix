{ config, lib, ... }:
{
  # Gen 2a already has AMD microcode, firmware and graphics in the generated
  # hardware/device configuration. Keep those intact; measure before tuning.
  config = lib.mkIf config.dotfiles.hardware.thinkpad.enable {
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    # Do not run TLP alongside power-profiles-daemon or change suspend modes
    # without a measured regression and a device acceptance test.
  };
}
