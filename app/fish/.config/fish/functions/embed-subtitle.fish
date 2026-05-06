function embed-subtitle --description "Embed subtitle into video file" -a subtitle video

  # --- Parse optional flags ---
  set lang ind
  set subname Indonesian

  # --- Derive extension and temp output ---
  set ext (string match -r '[^.]+$' $video)
  set base (string replace -r '\.[^.]+$' '' $video)
  set tmpfile "$base.embedsub_tmp.$ext"
  set assfile "$base.ass"

  # --- Embed ---
  switch $ext
  case mkv
    echo "Soft-embedding subtitle into MKV..."

    ffmpeg -i $subtitle $assfile

    mkvmerge -o $tmpfile $video \
      --language 0:$lang \
      --track-name "0:$subname" \
      --default-track 0:yes \
      $assfile

    # ffmpeg -i $video -i $subtitle \
    #   -c copy -map 0 -map 1 -metadata:s:s:0 \
    #   language=$lang -metadata:s:s:0 title="$subname" \
    #   $tmpfile

  case '*'
    echo "Unsupported format '$ext'. Use --burn to force hard-burn, or convert to MKV/MP4 first."
    return 1
  end

  # --- Replace original with result ---
  if test $status -eq 0
    mv $tmpfile $video && echo "> Done: $video (original overwritten)"
    rm $subtitle $assfile && echo "> Done: subtitle file deleted"
  else
    echo "Something went wrong. Original untouched."
    rm -f $tmpfile
    return 1
  end

end
