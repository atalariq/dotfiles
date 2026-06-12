# ── Common ─────────────────────────────────────────────
abbr -a c "clear"
abbr -a h "history"
abbr -a v "nvim"
abbr -a e "nvim"
abbr -a se "sudoedit"

#? rm/trash
abbr rmm "rm -rv"
abbr rm "gio trash"
abbr trl "gio trash --list"
abbr trm "gio trash"
abbr trs "gio trash --restore"

# Source: https://www.baeldung.com/linux/delete-empty-files-dirs
abbr rm-empty-files "find . -type f -empty -print -delete"
abbr rm-empty-folders "find . -type d -empty -print -delete"

# ── Git ────────────────────────────────────────────────
abbr -a g "git"
abbr -a ga "git add"
abbr -a gaa "git add --all"
abbr -a gb "git branch"
abbr -a gca "git commit --amend"
abbr -a gcl "git clone --depth 1"
abbr -a gcm "git commit -m"
abbr -a gco "git checkout"
abbr -a gcp "git cherry-pick"
abbr -a gcpa "git cherry-pick --abort"
abbr -a gd "git diff"
abbr -a gf "git fetch --all --prune"
abbr -a gl "git pull"
abbr -a glog "git log --oneline --graph --decorate --all"
abbr -a gp "git push"
abbr -a gpf "git push --force-with-lease"
abbr -a gpsup "git push --set-upstream origin (git branch --show-current)"
abbr -a grba "git rebase --abort"
abbr -a grbc "git rebase --continue"
abbr -a grbi "git rebase -i"
abbr -a gs "git status"
abbr -a gss "git status --short --branch"
abbr -a gsw "git switch"
abbr -a gst "git stash"
abbr -a gstu "git stash push -u"
abbr -a gstp "git stash pop"

abbr -a lg lazygit

# ── Package managers ──────────────────────────────────
abbr -a ni "npm install"
abbr -a nr "npm run"
abbr -a nx "npx"
abbr -a pi "pnpm install"
abbr -a pa "pnpm add"
abbr -a pr "pnpm run"
abbr -a px "pnpm dlx"
abbr -a bi "bun install"
abbr -a br "bun run"
abbr -a bx "bunx"

# ── Docker ─────────────────────────────────────────────
abbr -a d "docker"
abbr -a dc "docker compose"
abbr -a dcb "docker compose build"
abbr -a dcd "docker compose down"
abbr -a dcl "docker compose logs -f"
abbr -a dcu "docker compose up"
abbr -a dcud "docker compose up -d"
abbr -a dps "docker ps"

# ── System ─────────────────────────────────────────────
abbr -a jctl "journalctl -xeu"
abbr -a ports "ss -tulpn"
abbr -a path "printf '%s\n' $PATH"

# ── Systemctl ──────────────────────────────────────────
abbr -a sc "sudo systemctl"
abbr -a scr "sudo systemctl restart"
abbr -a sce "sudo systemctl enable"
abbr -a scd "sudo systemctl disable"
abbr -a scss "sudo systemctl status"
abbr -a scst "sudo systemctl start"
abbr -a scsp "sudo systemctl stop"

abbr -a scu "systemctl --user"
abbr -a scur "systemctl --user restart"
abbr -a scue "systemctl --user enable"
abbr -a scud "systemctl --user disable"
abbr -a scuss "systemctl --user status"
abbr -a scust "systemctl --user start"
abbr -a scusp "systemctl --user stop"
