command -q yt-dlp  || return 1

abbr yt "yt-dlp"

# List all Format
abbr ytf "yt-dlp --cookies-from-browser brave --list-formats"

# Video
set -l VIDEO_FLAG "--ignore-errors --continue --no-overwrites --embed-metadata --xattrs --embed-chapters --write-auto-subs --embed-subs --merge-output-format mkv -f \"bestvideo[vcodec^=av01][ext=mp4][height<=1080]+bestaudio[acodec^=opus]/bestvideo[vcodec^=vp9][ext=mp4][height<=1080]+bestaudio[acodec^=opus]/best\""

abbr ytv "yt-dlp --output '%(title)s by %(uploader)s.%(ext)s' --no-playlist $VIDEO_FLAG"
abbr ytp "yt-dlp -o '%(playlist_index)s %(title)s.%(ext)s' --download-archive 0-LIST.txt --yes-playlist $VIDEO_FLAG"

# Music
set -l MUSIC_FLAG "--ignore-errors --continue --no-overwrites --embed-metadata --embed-thumbnail --xattrs --extract-audio --audio-format best --audio-quality 0 -f bestaudio"

abbr ytm "yt-dlp -o '%(title)s.%(ext)s' --no-playlist $MUSIC_FLAG"
abbr ytmp "yt-dlp -o '%(title)s.%(ext)s' --download-archive 0-LIST.txt --yes-playlist $MUSIC_FLAG"
