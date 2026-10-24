# One registry generates the correct output family; adding a machine needs no
# copy of flake construction logic. Example identities must be adapted first.
{
  thinkpad-x13 = {
    kind = "nixos";
    system = "x86_64-linux";
    username = "atalariq";
    module = ./nixos/thinkpad-x13;
    home = ./nixos/thinkpad-x13/home.nix;
  };
  macos-example = {
    kind = "darwin";
    system = "aarch64-darwin";
    username = "example";
    homeDirectory = "/Users/example";
    module = ./darwin/example.nix;
    profiles = [
      ../profiles/cli.nix
      ../profiles/development.nix
    ];
  };
}
// builtins.listToAttrs (
  builtins.concatLists (
    map
      (
        system:
        map
          (kind: {
            name = "${kind}-${system}";
            value = {
              inherit system;
              username = "example";
              homeDirectory = "/home/example";
              kind = if kind == "nixos-wsl" then "wsl" else "home";
              genericLinux = kind != "nixos-wsl";
              profiles = [
                ../profiles/cli.nix
                ../profiles/development.nix
              ];
            };
          })
          [
            "ubuntu"
            "ubuntu-wsl"
            "nixos-wsl"
          ]
      )
      [
        "x86_64-linux"
        "aarch64-linux"
      ]
  )
)
