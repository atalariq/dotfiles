# Native applications

Each configured app folder documents its manual destination, dependencies,
version assumptions and local-override behavior. Copy only the listed native
files, or the entire folder where indicated. Nothing sources sibling folders.

eza, zoxide, fd and ripgrep are package-only baseline entries: they need no
configuration copy and cause no downloads during shell startup. Fish optionally
initializes zoxide when it is installed. Git owns repository operations;
application plugin managers will own plugin locks if plugins are added.

The manifest is authoritative for application IDs, links and Nix packages.
Keep credentials, caches, histories and mutable state outside these folders.
For manual installs, use the app's documented version requirement and native
platform packages; config-only installation does not install any binaries.
