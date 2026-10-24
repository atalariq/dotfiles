{ ... }:
{
  imports = [ ../../modules/darwin ];
  networking.hostName = "macos-example";
  system.primaryUser = "example";
  users.users.example.home = "/Users/example";
  # New example installation only. Preserve this number after first deployment.
  system.stateVersion = 6;
}
