{ pkgs, lib }:
{
  name,
  source,
  runtimeInputs,
}:
# Keep dependencies on the command's PATH, rather than leaking them into every
# shell. Native scripts remain independently readable and executable.
pkgs.writeShellScriptBin name ''
  export PATH=${lib.makeBinPath runtimeInputs}:"$PATH"
  ${builtins.readFile source}
''
