{ pkgs, ... }:
let
  php = pkgs.php84.buildEnv {
    extensions =
      { enabled, all }:
      enabled
      ++ (with all; [
        bcmath
        intl
        pdo_mysql
        pdo_sqlite
        pdo_pgsql
        pgsql
        redis
        zip
      ]);
  };
in
{
  home.packages = [
    php
    php.packages.composer
  ]
  ++ (with pkgs; [
    nodejs_24
    bun
    intelephense
    vtsls
    vscode-langservers-extracted
    tailwindcss-language-server
    emmet-language-server
    oxfmt
    prettier
    oxlint
    # Studio owns the writable SDK; no emulator or automatic license acceptance.
    jdk17
    android-tools
    jdt-language-server
  ]);
  home.sessionVariables.JAVA_HOME = "${pkgs.jdk17}";
}
