set -l YT_DL yt-dlp

abbr yt "$YT_DL"
abbr yts "$YT_DL --convert-subs vtt --write-auto-subs --skip-download"
abbr yt480p "$YT_DL -f 'best[height<=480][ext=mp4]'"
abbr yt720p "$YT_DL -f 'best[height<=720][ext=mp4]'"
abbr ytv "$YT_DL --output '%(title)s by %(uploader)s.%(ext)s' --no-playlist --embed-metadata --xattrs --embed-thumbnail --embed-chapters --write-auto-subs --embed-subs -f 'best[ext=mp4]'"
abbr ytp "$YT_DL -o '%(playlist_index)s %(title)s.%(ext)s' --download-archive 0-LIST.txt --yes-playlist --embed-metadata --xattrs --embed-thumbnail  --embed-chapters --write-auto-subs --embed-subs -f b"
abbr ytm "$YT_DL -o '%(title)s.%(ext)s' --no-playlist --embed-metadata --embed-thumbnail --xattrs --extract-audio --audio-quality 0 --audio-format opus"
abbr ytmp "$YT_DL -o '%(title)s.%(ext)s' --download-archive 0-LIST.txt --yes-playlist --embed-metadata --embed-thumbnail --xattrs --extract-audio --audio-quality 0 --audio-format opus"
