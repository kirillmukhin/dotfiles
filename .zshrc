### PREREQUIREMENTS #####################
# zsh (duh).
#   If zsh wasn't set as defalt shell yet:
#   chsh -s $(which zsh)
#   On Android with Termux - just:
#   chsh -s zsh
# curl
# perl
# git
# awk
#   That is not `mawk`. zplug works with `gawk` and `nawk`
# keychain (if you need to manage ssh-agent with it)
#########################################


### UNINSTALL ###########################
# Remove plugins installed with zplug:
# (Done automatically in this config for commented/removed plugins)
#   1. remove or comment them out in .zimrc
#   2. restart shell or run `source ~/.zshrc`
#   3. run `zplug clean` to remove all unmanaged repos
# To remove zplug itself:
#   cd && rm -rf .zplug
#########################################


### INSTALL MISSING PARTS ###############
## Zplug
if [[ ! -d "$HOME/.zplug" ]]; then
  echo "\033[1;31mZplug was not found, installing...\033[0m"
  echo ""
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi
#########################################


#### INSTANT PROMPT #####################
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
#########################################


# KEYCHAIN KEY ##########################
# ssh-agent manager helps with github authentification
# If you have a key used on github in ~/.ssh - set its name here
# Otherwise leave variable's value empty:
#local github_key_name=""
local github_key_name="github_ed25519"
#########################################


### SOURCE ZPLUG ########################
if [[ -s "$HOME/.zplug/init.zsh" ]]; then
  source $HOME/.zplug/init.zsh
fi
#########################################


### ZPLUG PLUGINS #######################
# Self-managment for zplug
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
# Command-line fuzzy finder
zplug "junegunn/fzf", from:github, as:command, rename-to:fzf, hook-build:"./install --all"
# Replace zsh's default completion with fuzzy one
zplug "Aloxaf/fzf-tab"
# Suggest commands as they being typed, based on history and completions
zplug "zsh-users/zsh-autosuggestions"
# Cycle through history matches of partly typed commands
zplug "zsh-users/zsh-history-substring-search"
# Powerlevel10k theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
zplug "romkatv/powerlevel10k", as:theme, depth:1
#
# Auto-install packages if there are plugins that have not been installed
if ! zplug check; then
  zplug install
fi
# Auto-remove files for all commented-out/removed packages from above
zplug clean --force
## Then, source plugins and add commands to $PATH
zplug load #--verbose
#########################################


### SOURCE PLUGINS ######################
## p10k theme
if [[ -f "$HOME/.p10k.zsh" ]]; then
  source "$HOME/.p10k.zsh"
else
  echo "Run \"p10k configure\" to customize prompt"
  POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
fi
## fzf
[ -f "$HOME/.fzf.zsh" ] && source ~/.fzf.zsh
## Zsh-history-substring-search
if zplug check zsh-users/zsh-history-substring-search; then
  # Use `cat -v` and press desired key to find the key's binding
  bindkey "^[[A" history-substring-search-up
  bindkey "^[[B" history-substring-search-down
  #default: "bg=magenta,fg=white,bold"
  export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=default,fg=5,bold"
  #default: "bg=red,fg=white,bold"
  export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=default,fg=1,bold"
fi
## autosuggestions
export ZSH_AUTOSUGGEST_STRATEGY=(completion)
#########################################


### ZSH BINDS  ##########################
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
#########################################


### ZSH HISTORY #########################
# Location of the file where the commands history will be written to
export HISTFILE="$HOME/.zsh_history"
# Number of entries to be kept in the memory (within open shell)
export HISTSIZE=42000
# Number of entries to be saved on disk to the $HISTFILE
export SAVEHIST=69000
# Record timestamps of each command
setopt EXTENDED_HISTORY
# If a new command added to history duplicates an older one - remove the older one.
setopt HIST_IGNORE_ALL_DUPS
# Record commands to history file as they are typed and import new commands from
# (e.g. see same history in two separate terminal sessions)
setopt SHARE_HISTORY
#########################################


### MAN PAGES COLORS ####################
# https://wiki.archlinux.org/index.php/Color_output_in_console#less
# List of color codes:
#   https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
man() {
    LESS_TERMCAP_md=$'\e[01;35m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;46;37m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    command man "$@"
}
#########################################


### VIM #################################
if which vim &>/dev/null; then
# Open vim as defualt editor (e.g. during `git commit`)
  export VISUAL=vim
  export EDITOR="$VISUAL"
fi
#########################################


# Aliases ###############################
if (( $+commands[xdg-open] )); then
  alias open=xdg-open
fi
if (( $+commands[grep] )); then
  alias grep='grep --color'
  # Default grep colors from man: 'ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'
  export GREP_COLORS='ms=01;33:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'
fi
if (( $+commands[plasmashell] )); then
  alias plasmarestart='kquitapp5 plasmashell; kwin_x11 --replace & kstart5 plasmashell & exit'
fi
if (( $+commands[valgrind] )); then
  alias valeaks='valgrind --tool=memcheck --leak-check=full --track-origins=yes'
fi
# NordVPN
if (( $+commands[nordvpn] )); then  # If nordvpn-cli is installed
  alias nord_connect="nordvpn connect Estonia -g P2P"
  alias nord_re="nordvpn disconnect && nordvpn connect Estonia -g P2P"
  alias nord_info="nordvpn status && nordvpn settings && nordvpn account"
fi
# exa - modern ls replacement
if (( $+commands[exa] )); then
  alias ls="exa --color=auto --git --icons --group-directories-first --sort=name --classify --header"
fi
#########################################


# KEYCHAIN ##############################
# Launch ssh-agent with github's key alongside with shell
# if keyname is set, keychain is installed and private key found in the ~./ssh/ folder
if [ $github_key_name ] && (( $+commands[keychain] )) && [ ! -f "~/.ssh/$github_key_name" ]; then
      eval $(keychain --eval --quiet $github_key_name)
fi
#########################################
