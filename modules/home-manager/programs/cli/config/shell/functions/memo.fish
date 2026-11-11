function memo --description "Post a memo to the homelab Memos instance"
    set -l server (set -q MEMOS_URL; and echo $MEMOS_URL; or echo http://homelab-x456urk:5230)
    set -l token
    if set -q MEMOS_TOKEN
        set token $MEMOS_TOKEN
    else if test -r "$HOME/.config/memos/token"
        set token (string trim < "$HOME/.config/memos/token")
    else
        echo "memo: export MEMOS_TOKEN or write an access token to ~/.config/memos/token" >&2
        echo "memo: create one in Memos under Settings -> Access tokens" >&2
        return 1
    end

    set -l content (string join ' ' -- $argv)
    if test -z "$content"; and not isatty stdin
        set content (string collect < /dev/stdin)
    end
    if test -z "$content"
        echo "usage: memo <text>   (or pipe text on stdin)" >&2
        return 1
    end

    if not command -q jq
        echo "memo: jq is required to build the request body" >&2
        return 1
    end

    set -l payload (jq -cn --arg content "$content" '{content: $content}')
    curl -fsS -X POST "$server/api/v1/memos" \
        -H "Authorization: Bearer $token" \
        -H 'Content-Type: application/json' \
        --data-binary $payload | jq -r '"posted " + (.name // "memo")'
end
