#!/bin/bash

# shellcheck disable=SC1090,SC1094

# ==== Bash ==== {{{

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} ]]
then
	exec fish
fi

[[ $DISPLAY ]] && shopt -s checkwinsize

# Auto "cd" when entering just a path
shopt -s autocd

# Prevent overwrite of files
set -o noclobber

# source /usr/share/doc/pkgfile/command-not-found.bash
# }}}

# Config
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

source-file(){
    [ -f "$1" ] && source "$1"
}

# ===== Prompt ===== {{{
if command -v "starship" >/dev/null 2>&1; then
    export STARSHIP_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml
    export STARSHIP_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/starship/cache
    eval "$(starship init bash)"
fi

# }}}

# ===== User ===== {{{
# User alias definition
ALIASES=${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases
source-file "$ALIASES"

# User function definition
FUNCTIONS=${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions
if [ -d "$FUNCTIONS" ]; then
    for f in "$FUNCTIONS"/?*; do
        source "$f"
    done
    unset f
fi

# User config
CONFIGS=${XDG_CONFIG_HOME:-$HOME/.config}/shell/configs
if [ -d "$CONFIGS" ]; then
    for f in "$CONFIGS"/?*; do
        source "$f"
    done
    unset f
fi

# Start CLI Apps
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

if command -v "fnm" >/dev/null 2>&1; then
    export FNM_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/fnm
    eval "$(fnm env --fnm-dir "$FNM_DIR")"
fi

# fnm
export PATH="/home/atalariq/.local/share/fnm:$PATH"
eval "`fnm env`"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
