{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles;
  manifestFile = ../apps/manifest.json;
  manifest = builtins.fromJSON (builtins.readFile manifestFile);
  selected = lib.filter (a: !(builtins.elem a cfg.exclude))
    (lib.unique (manifest.baseline ++ cfg.include));
  optionsFile = pkgs.writeText "dotfiles-link-options.json" (builtins.toJSON {
    inherit selected;
    manifest = toString manifestFile;
    checkout = cfg.checkout;
    home = config.home.homeDirectory;
    config = cfg.configHome;
  });
  # Use the SAME collision checks and ownership model in both deployment paths.
  # Native mappings deliberately do not also appear in home.file/xdg.configFile.
  helper = "${pkgs.python3}/bin/python3 -B ${../bootstrap}/hm-links.py";
  validation = pkgs.runCommand "dotfiles-manifest-valid" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    export PYTHONPATH=${../bootstrap}
    python3 -B - <<'PY'
    from pathlib import Path
    from dot import mappings, read_json
    manifest = read_json(Path('${manifestFile}'))
    mappings(Path('${../.}'), manifest, Path('/tmp/dotfiles-validation-home'),
             Path('/tmp/dotfiles-validation-home/.config'), ${builtins.toJSON selected},
             check_targets=False)
    PY
    touch "$out"
  '';
in {
  options.dotfiles = {
    checkout = lib.mkOption {
      type = lib.types.str;
      description = "Absolute live checkout, supplied explicitly by host/bootstrap.";
    };
    configHome = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config";
    };
    include = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    exclude = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };
  config = {
    assertions = [
      { assertion = lib.hasPrefix "/" cfg.checkout && !(lib.hasPrefix "/nix/store/" cfg.checkout);
        message = "dotfiles.checkout must name the absolute live checkout, not a store snapshot"; }
      { assertion = manifest.version == 1 && lib.all (a: builtins.hasAttr a manifest.apps) (selected ++ cfg.exclude);
        message = "Invalid dotfiles manifest version or application selection"; }
    ];
    home.packages = lib.unique (lib.concatMap
      (a: map (p: pkgs.${p}) manifest.apps.${a}.packages) selected);
    home.sessionVariables.XDG_CONFIG_HOME = cfg.configHome;
    home.activation.dotfilesPreflight = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      test -f ${validation}
      ${helper} check ${optionsFile}
    '';
    home.activation.dotfilesLinks = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run ${helper} apply ${optionsFile}
    '';
  };
}
