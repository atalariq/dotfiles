# gtasks (https://github.com/BRO3886/gtasks) is required!
command -q gtasks || return 1

function task --description "gtasks wrapper"
  # default to `view`
  set -q argv[1] || set argv view

  # available subcommand: add, clear, done, info, rm, undo, update, view
  gtasks tasks --tasklist terminal $argv
end
