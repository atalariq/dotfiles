function compress-pdf --description "Compress PDF using GhostScript"
    set file $argv[1]
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        -dPDFSETTINGS=/ebook \
        -dNOPAUSE -dQUIET -dBATCH \
        -sOutputFile="$(string replace '.pdf' '' $file)_compressed.pdf" \
        "$file"
end
