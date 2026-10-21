{ pkgs }:
let
  php = pkgs.php84.buildEnv {
    extensions = { enabled, all }: enabled ++ (with all; [ bcmath intl pdo_mysql pdo_sqlite zip ]);
  };
in {
  laravel = pkgs.mkShell {
    packages = [ php php.packages.composer pkgs.nodejs_22 pkgs.sqlite pkgs.git pkgs.unzip ];
    shellHook = ''
      echo "Laravel: PHP, Composer, Node and SQLite ready. Run composer install / npm ci in your project."
    '';
  };
  android = pkgs.mkShell {
    packages = [ pkgs.jdk17 pkgs.android-tools ];
    JAVA_HOME = "${pkgs.jdk17}";
    shellHook = ''
      export ANDROID_HOME="''${ANDROID_HOME:-$HOME/Android/Sdk}"
      export ANDROID_SDK_ROOT="$ANDROID_HOME"
      echo "Android: JDK 17 + adb ready. Use the project's Gradle wrapper; install SDKs in Android Studio."
    '';
  };
}
