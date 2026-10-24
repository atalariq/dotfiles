# Preserve inherited agents, including SSH forwarding. NixOS's user service
# owns this socket; portable shells never start an agent or guess desktop ones.
if test -z "$SSH_AUTH_SOCK"; and test -n "$XDG_RUNTIME_DIR"
    if test -S "$XDG_RUNTIME_DIR/ssh-agent"
        set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent"
    end
end
