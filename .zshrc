
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/seanwatson/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"

DEFAULT_USER=$USER

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	history-substring-search
	brew
	macos
	ruby
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

function spinssh() {
	SPINNAME=$(spin show -o fqdn)
	echo Connecting to active shopify spin server at: $SPINNAME
	TERM=xterm-256color kitty +kitten ssh $SPINNAME 
}

alias grsm='git reset --soft $(git_main_branch)'
alias gcfi='git commit --fixup'
alias glog="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
alias gtup='gt get && dev up'
alias gtre='gt get && gt submit'

function gget() {
	local branch
	branch=$(git branch --show-current)

	if [[ -z "$branch" ]]; then
		echo "gget: not on a branch" >&2
		return 1
	fi

	if [[ "$branch" == "main" ]]; then
		git fetch --no-tags --no-write-fetch-head -f origin refs/heads/main:refs/remotes/origin/main
		git merge --ff-only origin/main
	else
		git fetch --no-tags --no-write-fetch-head -f origin refs/heads/main:refs/remotes/origin/main
		# Best-effort: update the branch's remote-tracking ref if it has been pushed.
		# Unpushed branches have no remote ref, so ignore failures here.
		git fetch --no-tags --no-write-fetch-head -f origin "refs/heads/${branch}:refs/remotes/origin/${branch}" 2>/dev/null

		local stashed=0
		if [[ -n "$(git status --porcelain)" ]]; then
			git stash push -u -m "gget-autostash" && stashed=1
		fi

		git rebase origin/main

		(( stashed )) && git stash pop
	fi
}

alias cv='dev cd customerview-mobile'
alias pos='dev cd //areas/clients/pos-mobile'
alias shopify='dev cd //areas/core/shopify'
alias pos-channel='dev cd pos-channel'
alias web='dev cd //areas/clients/admin-web'
alias shop-server='dev cd //areas/platforms/shop-server'
alias shop-client='dev cd shop-client'

[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh
if [ -e /Users/seanwatson/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/seanwatson/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer


[[ -x /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/seanwatson/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/seanwatson/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/seanwatson/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/seanwatson/google-cloud-sdk/completion.zsh.inc'; fi

[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

export EDITOR="nvim"

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }

eval "$(starship init zsh)"
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Auto-launch zellij with session management
if [[ -z "$ZELLIJ" && -z "$SSH_CONNECTION" && -z "$INSIDE_EMACS" && "$TERM_PROGRAM" != "vscode" ]]; then
    # Get list of active sessions
    sessions=$(zellij list-sessions 2>/dev/null)
    if [[ $? -eq 0 && -n "$sessions" ]]; then
        # Sessions exist, attach to the first one
        session_name=$(echo "$sessions" | head -n1 | cut -d' ' -f1)
        zellij attach "$session_name" 2>/dev/null || zellij
    else
        # No sessions exist, create a new one
        zellij
    fi
fi

# Added by tec agent
[[ -x /Users/seanwatson/.local/state/tec/profiles/base/current/global/init ]] && eval "$(/Users/seanwatson/.local/state/tec/profiles/base/current/global/init zsh)"

# opencode
export PATH=/Users/seanwatson/.opencode/bin:$PATH
export DISABLE_SPRING=1

# Load AI agent tokens (this file is gitignored and contains secrets)
[[ -f ~/.dotfiles/.zshrc.ai-tokens ]] && source ~/.dotfiles/.zshrc.ai-tokens

# gsyn - replicates `gt sync` using raw git commands with stack awareness
# 1. Fetch from origin (prune stale remote-tracking branches)
# 2. Fast-forward (or reset) local trunk to match origin
# 3. Discover stack parentage from GitHub PR base branches
# 4. Restack all branches in topological order (parent before child)
# 5. Re-parent children of deleted branches, then prompt to delete
function gsyn() {
  local trunk="main"
  local current_branch
  current_branch=$(git branch --show-current)

  if [[ -z "$current_branch" ]]; then
    echo "gsyn: not on a branch (detached HEAD)" >&2
    return 1
  fi

  # 0. Stash local changes so rebases/checkouts run on a clean tree
  local stashed=0
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "📦 Stashing local changes..."
    git stash push -u -m "gsyn-autostash" && stashed=1
  fi

  # 1. Fetch with prune so merged remote branches disappear
  echo "🔄 Fetching from origin..."
  if ! git fetch --no-tags origin 2>/dev/null; then
    # Fetch can fail on stale refs (e.g. deleted Graphite MQ branches).
    # Prune first to remove them, then retry.
    git remote prune origin 2>/dev/null
    if ! git fetch --no-tags origin; then
      echo "❌ Fetch failed" >&2
      return 1
    fi
  fi
  git remote prune origin 2>/dev/null

  # 2. Update local trunk to match remote trunk (no network — already fetched above)
  echo "🔄 Updating $trunk..."
  if [[ "$current_branch" == "$trunk" ]]; then
    if ! git merge --ff-only "origin/$trunk" 2>/dev/null; then
      echo "⚠️  Fast-forward failed — resetting $trunk to origin/$trunk"
      git reset --hard "origin/$trunk"
    fi
  else
    git branch -f "$trunk" "origin/$trunk" 2>/dev/null
  fi

  # 3. Discover stack parentage from PR base branches (single API call)
  echo "🔍 Discovering stack..."
  local -a local_branches
  local_branches=(${(f)"$(git branch --format='%(refname:short)' | grep -v "^${trunk}$")"})

  typeset -A parent_of
  local pr_json
  pr_json=$(gh api graphql -f query='{
    viewer {
      pullRequests(first: 100, states: OPEN) {
        nodes { headRefName baseRefName }
      }
    }
  }' 2>/dev/null)

  for branch in "${local_branches[@]}"; do
    local base
    base=$(echo "$pr_json" | jq -r --arg b "$branch" \
      '.data.viewer.pullRequests.nodes[] | select(.headRefName == $b) | .baseRefName' 2>/dev/null)
    if [[ -n "$base" && "$base" != "null" ]]; then
      parent_of[$branch]="$base"
    fi
  done

  # Current branch always gets restacked (default to trunk if no PR)
  if [[ "$current_branch" != "$trunk" && -z "${parent_of[$current_branch]}" ]]; then
    parent_of[$current_branch]="$trunk"
  fi

  # 4. Topological restack: BFS from trunk outward so parents are rebased before children
  if [[ "$current_branch" != "$trunk" ]]; then
    echo "🔄 Restacking..."
    local -a queue=("$trunk")
    local -a restacked=()
    local -a skipped=()

    while [[ ${#queue[@]} -gt 0 ]]; do
      local parent="${queue[1]}"
      queue=("${queue[@]:1}")

      for branch in "${local_branches[@]}"; do
        # Skip if no known parent or already processed
        [[ -z "${parent_of[$branch]}" ]] && continue
        (( ${restacked[(Ie)$branch]} )) && continue
        (( ${skipped[(Ie)$branch]} )) && continue
        [[ "${parent_of[$branch]}" != "$parent" ]] && continue

        git checkout "$branch" --quiet 2>/dev/null || { skipped+=("$branch"); continue; }
        if git rebase "$parent" --quiet 2>/dev/null; then
          echo "   ✓ $branch → $parent"
          restacked+=("$branch")
          queue+=("$branch")
        else
          echo "   ⚠️  $branch — conflicts (skipped)"
          git rebase --abort 2>/dev/null
          skipped+=("$branch")
        fi
      done
    done

    git checkout "$current_branch" --quiet 2>/dev/null
  fi

  # 5. Clean up merged branches
  local -a gone_branches=()
  while IFS= read -r branch; do
    [[ -n "$branch" ]] && gone_branches+=("$branch")
  done < <(git branch -vv | grep ': gone]' | awk '{print $1}')

  if [[ ${#gone_branches[@]} -gt 0 ]]; then
    # Re-parent children of branches about to be deleted
    for gone in "${gone_branches[@]}"; do
      local gone_parent="${parent_of[$gone]:-$trunk}"
      for branch in "${local_branches[@]}"; do
        if [[ "${parent_of[$branch]}" == "$gone" ]]; then
          echo "   ↪ Re-parenting $branch → $gone_parent (was → $gone)"
          git checkout "$branch" --quiet 2>/dev/null || continue
          if git rebase "$gone_parent" --quiet 2>/dev/null; then
            parent_of[$branch]="$gone_parent"
          else
            echo "   ⚠️  Re-parenting $branch failed — conflicts"
            git rebase --abort 2>/dev/null
          fi
        fi
      done
    done

    # Switch to trunk if current branch will be deleted
    if (( ${gone_branches[(Ie)$current_branch]} )); then
      echo "   ↪ Switching to $trunk ($current_branch will be deleted)"
      current_branch="$trunk"
    fi
    git checkout "$current_branch" --quiet 2>/dev/null

    echo ""
    echo "🗑  ${#gone_branches[@]} branch(es) with merged/closed PRs:"
    for b in "${gone_branches[@]}"; do
      echo "   - $b"
    done
    echo ""
    read "reply?Delete them? [Y/n] "
    if [[ "$reply" != "n" && "$reply" != "N" ]]; then
      for b in "${gone_branches[@]}"; do
        git branch -D "$b" && echo "   ✓ $b"
      done
    else
      echo "   Skipped."
    fi
  fi

  # Restore stashed changes now that all rebases are done
  if (( stashed )); then
    echo "📦 Restoring stashed changes..."
    git stash pop
  fi

  echo "✅ Sync complete."
}
