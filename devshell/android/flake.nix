{
  description = "android core development tools";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/02c087f3fe673c9e317f206a627cb6b910336dbe";
  outputs = { nixpkgs, ... }: {
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        default = pkgs.mkShell {
          packages = with pkgs; [
            jdk17
            android-tools
          ];
          JAVA_HOME = "${pkgs.jdk17}";
          shellHook = ''
            export ANDROID_HOME="''${ANDROID_HOME:-$HOME/Android/Sdk}"
            export ANDROID_SDK_ROOT="$ANDROID_HOME"
          '';
        };
      }
    );
  };
}
