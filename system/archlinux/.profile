#!/bin/sh
# vim: ft=sh ts=4 sw=4:
# shellcheck disable=SC2155,SC1091

# ========================================== Directory

export EDITOR="nvim"
export VISUAL=$EDITOR
export SUDO_EDITOR=$EDITOR
export SUDO_PROMPT="$(tput bold setaf 1)(sudo)$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput bold setaf 3)%p$(tput sgr0): "

export LESS='-RQS'
# export MANPAGER="less -R"
export MANPAGER="nvim +Man!"
