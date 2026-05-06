# Android SDK Paths
set -gx ANDROID_HOME $HOME/Dev/android-sdk

# Java Home
set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk

# Flutter with FVM
set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
set -gx FVM_CACHE_PATH $HOME/Dev/fvm

# Golang
set -gx GOPATH $HOME/Dev/go
set -gx GOBIN $GOPATH/bin

# OpenCode
set -gx OPENSPEC_TELEMETRY 0
set -gx DO_NOT_TRACK 1
set -gx OPENCODE_ENABLE_EXA 1

# ── PATH ──────────────────────────────────────────────
fish_add_path $JAVA_HOME/bin
fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $ANDROID_HOME/emulator
fish_add_path $GOBIN
fish_add_path $FVM_CACHE_PATH/default/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/script

