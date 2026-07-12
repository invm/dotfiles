# robbyrussell prompt, but show last 2 path components (worktree-friendly)
PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%2d%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'
