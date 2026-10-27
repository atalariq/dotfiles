{
  config,
  lib,
  dotfilesLib,
  ...
}:
{
  config = lib.mkIf config.programs.fish.enable {
    programs.fish.generateCompletions = true;
    # conf.d also contains generated integrations and owner/private snippets, so
    # it is a mixed-ownership directory. Link only our snippets; history and
    # universal variables remain in their writable native locations.
    xdg.configFile =
      lib.mapAttrs'
        (name: _: {
          name = "fish/conf.d/${name}";
          value.source = dotfilesLib.sourceFor "fish" (./config + "/${name}");
        })
        (
          lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".fish" name) (
            builtins.readDir ./config
          )
        );
  };
}
