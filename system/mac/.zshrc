if command -v "fish" >/dev/null 2>&1; then
  if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && [[ $- == *i* ]];; then
    exec fish
  fi
fi

