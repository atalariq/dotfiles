if set -q DISTROBOX_ENTER
    set -e JAVA_HOME
else
    # Android SDK Paths
    set -gx ANDROID_HOME $HOME/Android/Sdk
    set -gx PATH $PATH $ANDROID_HOME/cmdline-tools/latest/bin
    set -gx PATH $PATH $ANDROID_HOME/platform-tools
    set -gx PATH $PATH $ANDROID_HOME/emulator

    # Java Home
    set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk

    # FVM
    set -gx FVM_CACHE_PATH $HOME/.local/share/fvm
    set -gx PATH $PATH $FVM_CACHE_PATH/default/bin
    set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
end
