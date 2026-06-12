function dev-health --description "Check shared language tooling from PATH"
    set -l tools \
        mise node fvm rustup go jdtls kotlin-lsp vtsls gopls \
        basedpyright phpactor tinymist

    if command -q mise
        mise doctor
    else
        echo "missing: mise"
    end

    for tool in $tools
        if command -q $tool
            printf "ok:      %-18s %s\n" $tool (command -v $tool)
        else
            printf "missing: %-18s\n" $tool
        end
    end
end
