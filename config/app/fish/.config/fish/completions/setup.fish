# Fish completions for the `setup` dotfiles command.
# Subcommand list is kept here; module refs and profiles are discovered at runtime.

function __setup_dotfiles_dir
    set -l cmd_path (command -v setup 2>/dev/null); or return 1
    test -n "$cmd_path"; or return 1
    set -l real (readlink -f $cmd_path 2>/dev/null); or set real $cmd_path
    set -l dir (dirname $real)
    # If we're in a script/ subdir, go up one more
    if string match -q '*/script' -- $dir
        dirname $dir
    else
        echo $dir
    end
end

function __setup_modules
    set -l dotfiles (__setup_dotfiles_dir); or return
    for cat in app desktop misc system
        if test -d "$dotfiles/config/$cat"
            for module in $dotfiles/config/$cat/*/
                echo "$cat/"(basename $module)
            end
        end
    end
end

function __setup_profiles
    set -l dotfiles (__setup_dotfiles_dir); or return
    for f in $dotfiles/profiles/*.json
        basename $f .json
    end
end

function __setup_no_subcommand
    not __fish_seen_subcommand_from use undo restow adopt profile secrets lab personal doctor status diff
end

# Disable file completions entirely
complete -c setup -f

# Flags (can appear anywhere)
complete -c setup -l dry-run -d 'Preview without executing'
complete -c setup -l force   -d 'Skip interactive prompts'

# Subcommands
complete -c setup -n __setup_no_subcommand -a use      -d 'Deploy a module'
complete -c setup -n __setup_no_subcommand -a undo     -d 'Rollback a module or profile'
complete -c setup -n __setup_no_subcommand -a restow   -d 'Re-deploy a module'
complete -c setup -n __setup_no_subcommand -a adopt    -d 'Adopt existing $HOME files into repo'
complete -c setup -n __setup_no_subcommand -a profile  -d 'Deploy a profile'
complete -c setup -n __setup_no_subcommand -a secrets  -d 'Link secrets files'
complete -c setup -n __setup_no_subcommand -a doctor   -d 'Check symlink health'
complete -c setup -n __setup_no_subcommand -a status   -d 'Show deploy status'
complete -c setup -n __setup_no_subcommand -a diff     -d 'Detect symlink drift'
complete -c setup -n __setup_no_subcommand -a lab      -d 'Deploy lab profile'
complete -c setup -n __setup_no_subcommand -a personal -d 'Deploy laptop profile'

# Short form: module ref as first arg (e.g. `setup app/fish`)
complete -c setup -n __setup_no_subcommand -a '(__setup_modules)'

# After subcommands that take a module ref
complete -c setup -n '__fish_seen_subcommand_from use restow adopt status diff' \
    -a '(__setup_modules)'

# After `profile`: profile names
complete -c setup -n '__fish_seen_subcommand_from profile' \
    -a '(__setup_profiles)'

# After `undo`: module refs + the literal keyword `profile`
complete -c setup -n '__fish_seen_subcommand_from undo; and not __fish_seen_subcommand_from profile' \
    -a '(__setup_modules) profile'

# After `undo profile`: profile names
complete -c setup -n '__fish_seen_subcommand_from undo; and __fish_seen_subcommand_from profile' \
    -a '(__setup_profiles)'
