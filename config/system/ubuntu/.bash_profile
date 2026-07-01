# ~/.bash_profile — bash login shell: load .profile then interactive .bashrc.
[ -r "$HOME/.profile" ] && . "$HOME/.profile"
[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"
