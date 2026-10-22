function dev-health --description "Show installed development tools"
    for tool in nvim git node bun php composer lerd adb java tinymist typst websocat
        if command -q $tool
            command -s $tool
        else
            printf 'missing: %s\n' $tool
        end
    end
end
