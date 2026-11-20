{
  description = "A standalone Home Manager profile from atalariq/dotfiles";

  inputs.dotfiles.url = "github:atalariq/dotfiles";
  inputs.nixpkgs.follows = "dotfiles/nixpkgs";
  inputs.home-manager.follows = "dotfiles/home-manager";

  outputs =
    { dotfiles, ... }:
    let
      # Change these two lines for the device you are on.
      username = "atalariq";
      device = "heighliner";
    in
    {
      homeConfigurations = {
        "${username}@x86_64-linux" = dotfiles.lib.mkHome {
          system = "x86_64-linux";
          inherit username device;
        };
        "${username}@aarch64-linux" = dotfiles.lib.mkHome {
          system = "aarch64-linux";
          inherit username device;
        };
        "${username}@x86_64-darwin" = dotfiles.lib.mkHome {
          system = "x86_64-darwin";
          inherit username device;
        };
        "${username}@aarch64-darwin" = dotfiles.lib.mkHome {
          system = "aarch64-darwin";
          inherit username device;
        };
      };
    };
}
