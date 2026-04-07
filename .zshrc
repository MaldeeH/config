########## Prompt ##########
autoload -U colors && colors
autoload -U colors && colors
PROMPT='%F{blue}%n%f %F{green}%~%f %# '

########## History (Zsh-native) ##########
HISTSIZE=10000
SAVEHIST=20000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
setopt APPEND_HISTORY              # append rather than overwrite
setopt INC_APPEND_HISTORY          # write each command as it's entered
setopt SHARE_HISTORY               # share history across shells
setopt HIST_IGNORE_DUPS            # don’t record consecutive dupes
setopt HIST_IGNORE_SPACE           # ignore cmds starting with a space

########## Colors + ls/grep aliases ##########
if command -v dircolors >/dev/null 2>&1; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

alias ls='ls -C -t -U -A -p --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias la='ls -A'
alias l='ls -CF'

#neovim fzf:
unalias nf 2>/dev/null
nf() {
  local file
  file=$(fzf) || return
  [[ -n "$file" ]] || return
  nvim -- "$file"
}

########## Completion (Zsh-native) ##########
autoload -U compinit && compinit
# Show dotfiles in completion results
_comp_options+=(globdots)

########## nvm (normal init + lazy-load wrappers) ##########
export NVM_DIR="$HOME/.nvm"
# Load immediately (simple & reliable)
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"

# OR: lazy-load (comment the line above if you prefer lazy)
lazy_load_nvm() {
  unset -f node npm npx nvm
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
}
node() { lazy_load_nvm; command node "$@"; }
npm()  { lazy_load_nvm; command npm  "$@"; }
npx()  { lazy_load_nvm; command npx  "$@"; }
nvm()  { lazy_load_nvm; command nvm  "$@"; }

# (Optional) bash-style nvm completion in Zsh:
# autoload -U +X bashcompinit && bashcompinit
# [[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

if command -v tmux &> /dev/null; then
  if [ -z "$TMUX" ]; then
    tmux attach -t default || tmux new -s default
  fi
fi

typeset -U path; path+=(/snap/bin)

[ -f "$HOME/.dotfiles.sh" ] && source "$HOME/.dotfiles.sh"
eval "$(ssh-agent -s)" >/dev/null 2>&1
ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1 || true

cd code
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
