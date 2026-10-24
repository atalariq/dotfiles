function ff
  # 1. Fix typo and set a safe default search term
  set -l query "."
  if set -q argv[1]
    set query $argv[1]
  end

  # 2. Feed fd directly to fzf to avoid memory overhead and allow streaming
  set -l file (fd --type f $query | fzf \
  --reverse \
  --height 80% \
  --border \
  --preview 'bat --style=numbers --color=always --line-range :500 {}' \
  --preview-window 'right:60%:wrap')

  # 3. Use standard string checking
  string length -q -- "$file"; or return 1

  # 4. Use bat instead of cat for consistent, beautiful output
  bat --color=always "$file"
  echo -e "\nSelected: $file"
end
