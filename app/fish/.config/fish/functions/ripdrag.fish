function drop -a PATH -d "Drop file(s)"
  # -v, --verbose                  Be verbose
  # -t, --target                   Act as a target instead of source
  # -k, --keep                     With --target, keep files to drag out
  # -r, --resizable                Make the window resizable
  # -x, --and-exit                 Exit after first successful drag or drop
  # -i, --icons-only               Only display icons, no labels
  # -d, --disable-thumbnails       Don't load thumbnails from images
  # -s, --icon-size <SIZE>         Size of icons and thumbnails [default: 32]
  # -W, --content-width <WIDTH>    Min width of the main window [default: 360]
  # -H, --content-height <HEIGHT>  Default height of the main window [default: 360]
  # -I, --from-stdin               Accept paths from stdin
  # -a, --all                      Show a drag all button
  # -A, --all-compact              Show only the number of items and drag them together
  # -n, --no-click                 Don't open files on click
  # -b, --basename                 Always show basename of each file
  # -h, --help                     Print help
  # -V, --version                  Print version
  ripdrag  --and-exit --basename --no-click --resizeable --all $argv
end

function drag -a PATH -d "Drop file(s)"
  # -v, --verbose                  Be verbose
  # -t, --target                   Act as a target instead of source
  # -k, --keep                     With --target, keep files to drag out
  # -r, --resizable                Make the window resizable
  # -x, --and-exit                 Exit after first successful drag or drop
  # -i, --icons-only               Only display icons, no labels
  # -d, --disable-thumbnails       Don't load thumbnails from images
  # -s, --icon-size <SIZE>         Size of icons and thumbnails [default: 32]
  # -W, --content-width <WIDTH>    Min width of the main window [default: 360]
  # -H, --content-height <HEIGHT>  Default height of the main window [default: 360]
  # -I, --from-stdin               Accept paths from stdin
  # -a, --all                      Show a drag all button
  # -A, --all-compact              Show only the number of items and drag them together
  # -n, --no-click                 Don't open files on click
  # -b, --basename                 Always show basename of each file
  # -h, --help                     Print help
  # -V, --version                  Print version
  ripdrag  --and-exit --basename --no-click --resizeable --all $argv
end
