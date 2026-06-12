# ~/.config/fish/functions/gignore.fish

function gignore
    if test (count $argv) -eq 0
        echo "Usage: gignore <template>"
        echo "Example: gignore node"
        return 1
    end

    curl -fsSL "https://www.toptal.com/developers/gitignore/api/$argv" > .gitignore
end
