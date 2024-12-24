alias q=exit
alias v=nvim
alias cat=bat
alias grep=rg
alias ls=eza
alias pn=pnpm
alias t=tmux
alias cl=clear
alias k=kubectl
alias f="kubectl logs -f"
alias d="kubectl describe"
alias wpod="kubectl get pods -A --no-headers | fzf | awk '{ print \$2 }' | xargs -I {} sh -c 'watch \"kubectl get pods -A | grep {} \"'"
alias lpod="kubectl get pods --no-headers | fzf | awk '{ print \$1 }' | xargs -I {} sh -c 'kubectl logs -f {}'"

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
