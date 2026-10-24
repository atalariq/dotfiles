# android

Core packages: `jdk17`, `android-tools`.

Run `nix develop`, or review `.envrc` and run `direnv allow` once. Entering the directory then loads the cached environment; leaving restores the previous environment.

Install the writable Android SDK separately in Android Studio. Projects use their Gradle wrapper; this shell does not install an SDK or accept licenses.

Update `flake.lock` deliberately. Without Nix, install the same package versions listed in [VERSIONS.md](VERSIONS.md).
