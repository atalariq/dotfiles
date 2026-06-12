if test -z "$SSH_AUTH_SOCK"
      for sock in "$XDG_RUNTIME_DIR/keyring/ssh" "$XDG_RUNTIME_DIR/gcr/ssh"
          if test -S "$sock"
              set -gx SSH_AUTH_SOCK "$sock"
              break
          end
      end
  end
