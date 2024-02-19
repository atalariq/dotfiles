set -gx NNN_FIFO /tmp/nnn.fifo
set -gx NNN_TMPFILE /tmp/.lastd
set -gx NNN_OPTS aceEx
# set -gx NNN_OPENER $HOME/.config/nnn/plugins/nuke
set -gx NNN_TRASH 2

set -gx NNN_BMS "d:$HOME/Documents;D:$HOME/Downloads;m:$HOME/Media;p:$HOME/Documents/Programming;r:$HOME/Documents/Programming/Repositories"
set -gx NNN_PLUG "o:fzopen;m:nmount;x:xdgdefault;a:autojump;b:bulknew;d:dragdrop;P:preview-tui-ext;p:preview-tui;B:nbak"

function nnncd --wraps nnn --description 'support nnn quit and change directory'
    # Block nesting of nnn in subshells
    if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
        echo "nnn is already running"
        return
    end

    if test -n "$XDG_CONFIG_HOME"
        set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
    else
        set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
    end

    command nnn $argv

    if test -e $NNN_TMPFILE
        source $NNN_TMPFILE
        rm $NNN_TMPFILE
    end
end
