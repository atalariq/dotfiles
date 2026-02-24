set -l YT_DL yt-dlp

abbr yt "$YT_DL"

# List all Format
abbr ytf "$YT_DL --cookies-from-browser brave --list-formats"

# Video
set -l VIDEO_FLAG "--ignore-errors --continue --no-overwrites --embed-metadata --xattrs --embed-chapters --write-auto-subs --embed-subs --merge-output-format mkv -f \"bestvideo[vcodec^=av01][ext=mp4][height<=1080]+bestaudio[acodec^=opus]/bestvideo[vcodec^=vp9][ext=mp4][height<=1080]+bestaudio[acodec^=opus]/best\""

abbr ytv "$YT_DL --output '%(title)s by %(uploader)s.%(ext)s' --no-playlist $VIDEO_FLAG"
abbr ytp "$YT_DL -o '%(playlist_index)s %(title)s.%(ext)s' --download-archive 0-LIST.txt --yes-playlist $VIDEO_FLAG"

# Music
set -l MUSIC_FLAG "--ignore-errors --continue --no-overwrites --embed-metadata --embed-thumbnail --xattrs --extract-audio --audio-format best --audio-quality 0 -f bestaudio"

abbr ytm "$YT_DL -o '%(title)s.%(ext)s' --no-playlist $MUSIC_FLAG"
abbr ytmp "$YT_DL -o '%(title)s.%(ext)s' --download-archive 0-LIST.txt --yes-playlist $MUSIC_FLAG"
