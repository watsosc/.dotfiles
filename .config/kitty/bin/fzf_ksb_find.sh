#!/usr/bin/env bash

# Purpose: Fuzzy-find through the Kitty scrollback buffer and copy the selected line to clipboard
# Method: Pipe the scrollback buffer into this script, then use fzf to search and select a line
# Preview: Use bat to show context around the selected line in the preview window

stdin=$(mktemp)
cat >"$stdin"

show_context() {
    local n=$1
    local fin=$2

    # n is zero-based, but bat's --highlight-line is one-based
    bat \
        --color=always --decorations=never \
        --highlight-line $((n + 1)) $fin
}

# In case fzf spawns a new shell, ensure it uses bash
export -f show_context

# Filter through fzf, previewing with bat, and copy the result to clipboard
fzf \
    --ansi --no-sort --exact --tac \
    --preview-label 'Scrollback Buffer (Search Result Highlighted)' \
    --preview "show_context {n} $stdin" \
    --preview-window 'up,80%,border-rounded,+{n}/2' \
    --bind 'ctrl-c:abort' \
    --bind 'ctrl-b:preview-half-page-up' \
    --bind 'ctrl-f:preview-half-page-down' \
    <"$stdin" |
    (tr -d "\n" | kitty +kitten clipboard)

