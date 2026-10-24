{
  lib,
  config,
  checkout,
  pkgs,
}:
let
  source =
    path:
    if config.dotfiles.deployment.mode == "immutable" then
      path
    else
      config.lib.file.mkOutOfStoreSymlink "${checkout}/${
        lib.removePrefix (toString ../. + "/") (toString path)
      }";
  baseline = import ../themes/source-palette.nix;
  roles = builtins.attrNames baseline;
  themedSource =
    path:
    if !config.dotfiles.appearance.enable then
      source path
    else
      pkgs.writeText (builtins.baseNameOf path) (
        lib.replaceStrings (map (role: baseline.${role}) roles) (map (
          role: config.lib.stylix.colors.${role}
        ) roles) (builtins.readFile path)
      );
  themedDirectory =
    path:
    if !config.dotfiles.appearance.enable then
      source path
    else
      pkgs.linkFarm "native-appearance" (
        lib.mapAttrsToList (name: type: {
          inherit name;
          path =
            if type == "directory" then
              themedDirectory (path + "/${name}")
            else
              themedSource (path + "/${name}");
        }) (builtins.readDir path)
      );
in
{
  inherit source themedSource themedDirectory;
}
