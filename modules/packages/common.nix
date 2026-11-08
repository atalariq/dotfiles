# CLI packages shared by several hosts. The Home Manager core bundle already
# owns the POSIX floor (coreutils, eza, ripgrep, fd, bat, ...); this file is
# only for extras that would otherwise be repeated in every apps.nix.
#
# Keep this list small. A tool used by one host belongs in that host's
# apps.nix, not here.
{ pkgs }:
{
  # Every host that runs the shared CLI layer.
  cli = with pkgs; [
    wget
    croc
  ];

  # Hosts that talk to GitLab as well as GitHub.
  forge = with pkgs; [ glab ];
}
