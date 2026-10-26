# Native files follow a generation or link back to the checkout in live mode.
# Theme adapters generate immutable outputs whenever appearance is enabled.
{
  lib,
  config,
  checkout,
  pkgs,
}:
let
  # A path from another input cannot be mapped into this checkout.
  checkedPath =
    path:
    assert lib.assertMsg
      (config.dotfiles.deployment.mode != "live" || lib.hasPrefix (toString ../.. + "/") (toString path))
      "dotfiles live sources must be inside this dotfiles source tree; foreign paths cannot be mapped to the checkout.";
    path;
  source =
    path:
    if config.dotfiles.deployment.mode == "immutable" then
      path
    else
      config.lib.file.mkOutOfStoreSymlink "${checkout}/${
        lib.removePrefix (toString ../.. + "/") (toString (checkedPath path))
      }";
  baseline = import ../stylix/source-palette.nix;
  roles = builtins.attrNames baseline;
  themedSource =
    path:
    if !config.dotfiles.appearance.enable then
      source path
    else
      pkgs.writeText (builtins.baseNameOf path) (
        lib.replaceStrings (map (role: baseline.${role}) roles) (map (
          role: config.lib.stylix.colors.${role}
        ) roles) (builtins.readFile (checkedPath path))
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
        }) (builtins.readDir (checkedPath path))
      );
in
{
  inherit source themedSource themedDirectory;
}
