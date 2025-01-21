set -l YT_DL yt-dlp

abbr yt "$YT_DL"

# List all Format
abbr ytf "$YT_DL --cookies-from-browser brave --list-formats"

# Subtitle
abbr yts "$YT_DL --convert-subs vtt --write-auto-subs --skip-download"

# Video
abbr ytv "$YT_DL --output '%(title)s by %(uploader)s.%(ext)s' --no-playlist --embed-metadata --xattrs --embed-thumbnail --embed-chapters --write-auto-subs --embed-subs -f 'ba+bv'"
abbr ytp "$YT_DL -o '%(playlist_index)s %(title)s.%(ext)s' --ignore-errors --continue --no-overwrites --download-archive 0-LIST.txt --yes-playlist --embed-metadata --xattrs --embed-thumbnail  --embed-chapters --write-auto-subs --embed-subs -f 'ba+bv'"

# Music
abbr ytm "$YT_DL -o '%(title)s.%(ext)s' --no-playlist --embed-metadata --embed-thumbnail --xattrs --extract-audio --audio-quality 0 --audio-format opus"
abbr ytmp "$YT_DL -o '%(title)s.%(ext)s' --ignore-errors --continue --no-overwrites --download-archive 0-LIST.txt --yes-playlist --embed-metadata --embed-thumbnail --xattrs --extract-audio --audio-quality 0 --audio-format opus"
