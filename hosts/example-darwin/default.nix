# Generic nix-darwin example. Homebrew is not configured here on purpose:
# borrowed Macs usually do not want another package manager writing to /opt.
{ ... }:
{
  imports = [ ../../modules/darwin ];

  networking.hostName = "ix";
  system.stateVersion = 6;
  system.primaryUser = "atalariq";

  # Lets a Linux evaluator inspect the Darwin configuration; actual builds
  # still happen on a Mac.
  nixpkgs.config.allowUnsupportedSystem = true;

  users.users.atalariq.home = "/Users/atalariq";
}
