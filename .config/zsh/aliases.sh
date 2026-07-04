alias q=exit
export EDITOR=nvim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CLAUDE_CODE_SUBAGENT_MODEL="claude-sonnet-4-6"
export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1
unset CLAUDE_CODE_OAUTH_TOKEN
alias v=nvim
alias pn=pnpm
alias t=tmux
alias k=kubectl
alias f="kubectl logs -f"
alias d="kubectl describe"

source <(fzf --zsh)
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory

# usage: git_clone_folder <repo> <folder>
git_clone_folder() {
	local repo=$1
	local name
	name=$(echo "$1" | awk -F'/' '{print $NF}' | sed 's/.git$//')
	local folder=$2
	git clone -n --depth=1 --filter=tree:0 "$repo"
	cd "$name" || exit 1
	git sparse-checkout set --no-cone "$folder"
	git checkout
}
