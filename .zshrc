ZDOTDIR=~/.zsh.d

# set zshrc to this file
zstyle :compinstall filename '~/.zshrc'

# skip global compinit as we'll call it ourselves in a moment
skip_global_compinit=1

# add extra completion functions
fpath=($ZDOTDIR/completers $fpath)

autoload -Uz compinit  && compinit -d $ZDOTDIR/zcompdump

## ====================
## Section 1 -- Options
## ====================

# Let's make the zsh environment fit for human consumption

# Enables advanced command line editing
# via the Zsh Line Editor, which replaced readline
setopt zle

# Disables the bell "\a" or "x07" which annoys people to death.
# Fatalities are bad, and should be avoided.
setopt no_beep

# Force the user to pause for 10 seconds before running "rm -rf *"
setopt rm_star_wait

# If you have a background process "cmd", typing "cmd" again
# is equivalent to running "fg %cmd"
setopt auto_resume

# Force the user to double-check the job table before exiting.
setopt check_jobs

# Automatically send CONT to disowned processes
setopt auto_continue

# In functions, $0 contains the name of the function
# This is useful in metaprogramming.
setopt function_argzero

# Allow comments in interactive shells (for presenting)
setopt interactive_comments


## correction

# Correct the arguments of commands
# as well as the commands themselves
setopt correct_all

# List all matches if there are more than one
setopt auto_list

# Complete at the cursor position, which is useful
# if the cursor is not at the end of a word
setopt complete_in_word

# Complete "menu style"
setopt menu_complete          # add first of multiple

# Completed directories have a slash appended to prepare
# for completing their contents
setopt auto_param_slash

# Remove extra slashes added at the end of directories
setopt auto_remove_slash


setopt auto_param_keys

# Allow zsh to use smarter logic to fit more text on the screen
setopt list_packed            # conserve space


## globbing


# Sort globs numerically (i.e 10a comes after 1a)
setopt numeric_glob_sort

# Enable advanced glob usage (negation, union, and regex multipliers)
setopt extended_glob

# Enable KSH style modifiers before groups (mostly regex style)
setopt ksh_glob

# Given abc=(a b c), a$abc ==> aa ab ac
setopt rc_expand_param

# Because that SHIFT key is sooo hard to hit
setopt no_case_glob

# Don't hide files in globs by default
setopt glob_dots

# Case insensitive matching on the command line too
setopt no_case_match

# Allow a glob qualifier (like (/)) to match all by itself
setopt bare_glob_qual

# Append a trailing slash to distinguish directories
setopt mark_dirs

# Also mark symlink with @ and various special files with other
# miscelaneous symbols
setopt list_types

# Simply replace null globs with nothing
setopt null_glob

# Allow brace expansion (e.g {a-z}{a-z} ==> aa ab ac...)
# in places it would normally be ignore
setopt brace_ccl


## history


# Remove extra whitespace in history entries
setopt hist_reduce_blanks

# Ignore history entries starting with a space
setopt hist_ignore_space

# Ignore immediate duplicate lines in history
setopt hist_ignore_dups

# Ignore identical lines when searching for duplicates
setopt hist_find_no_dups

# Allow patterns in parameter expansion substitutions
setopt hist_substpattern

# Also log time and exit code
setopt extended_history

# Append the history, (faster than re-writing)
setopt append_history

# Append to history on every command
setopt inc_append_history

# SHare the history between zsh instances
setopt share_history

# Avoiding meta: don't store commands that reference the history
# in the history
setopt hist_no_store

# Kill duplicate lines first, when history is full
setopt hist_expire_dups_first

# Force the user to check history expanders before they
# shoot themselves in the foot.
setopt hist_verify

# Allow usage of a single bang instead of a double bang
setopt csh_junkie_history

# ... And always make a single bang special
setopt bang_hist

# i/o and syntax

# Allow multiple IO redirections
# E.g. :>* blanks all files
setopt multios

# Support Unicode characters
setopt multibyte              # Unicode!

# Don't overwrite with > use !>
setopt noclobber

# 'Isn''t' ==> Isn't
setopt rc_quotes

# "=ps" ==> "$(which ps)"
setopt equals

# hash the command list for every command
setopt hash_list_all

# Nobody does columns first anymore
setopt list_rows_first

# Force the hashing of cmds to save time
setopt hash_cmds

# if a=~ then cd a takes you to ~
setopt cdable_vars

# Allow the following syntax
# if [[ cond ]] body
# for (( cond )) body
# wile [[ cond  ]] body
setopt short_loops

# Always resolve links to their true location
setopt chase_links            # resolve links to their location

# Interrupt the user with messages, instead of waiting
setopt notify


## navigation


# Just type a directory to cd to it
setopt auto_cd

# Push all directories into the dirstack
setopt auto_pushd

# Don't notify the user when dirs have been pushed into the dirstack
# That would be really annoying
setopt pushd_silent

# Don't push duplicate directories into the dirstack
setopt pushd_ignore_dups

# invert pushd behavior
setopt pushd_minus

# pushd == pushd ~
setopt pushd_to_home

# if I set a=/usr/bin, a is exported as a named directory
setopt auto_name_dirs

# Allow =* to expand to ="a b c..."
setopt magic_equal_subst

# Allow parameter expansion in prompts
setopt prompt_subst

# Don't leave stale RPS1's lying around
setopt transient_rprompt

# Allow csh style control structures
setopt csh_junkie_loops

# Continue loading this init file, even if it contains syntax errors.
# This is probably due to old versions of zsh
setopt continue_on_error

# =======================
# Section 2 -- The Prompt
# =======================

# show the last error code and highlight root in red
PS1=$'%{%F{red}%}%(?..Error: (%?%)\n)%F{default}[%{%B%(!.%F{red}.%F{black})%}'

# username, reset decorations, pwd
PS1=$PS1$'%n%b%F{default} %~'"$((($SHLVL > 1))&&echo ' <%L>')]%# "

# ====================
# Section 3 -- Aliases
# ====================

typeset -A global_abbrevs command_abbrevs
typeset -a expand

expand=('mc')

function alias () {
    emulate -LR zsh
    zparseopts -D -E eg=EG ec=EC E=E
    if [[ -n $EG ]]; then
        for token in $@; do
            token=(${(s/=/)token})
            builtin alias -g $token
            global_abbrevs[$token[1]]=$token[2]
        done
    elif [[ -n $EC ]]; then
        for token in $@; do
            builtin alias $token
            token=(${(s/=/)token})
            command_abbrevs[$token[1]]=$token[2]
        done
    else
        if [[ -n $E ]]; then
            for token in $@; do
                if [[ $token == (*=*) ]]; then
                    token=(${(s/=/)token})
                    expand+="$token[1]"
                fi
            done
        fi
        builtin alias $@
    fi
}

# proxy aliases
BORING_FILES='*\~|*.elc|*.pyc|!*|_*|*.swp|*.zwc|*.zwc.old'
if [[ $OSTYPE != (free|open|net)bsd* ]]; then
    alias lsa='\ls --color --group-directories-first'
    alias -E lst="lsa -I '${BORING_FILES:gs/\|/' -I '/}'"
else
    # in BSD, -G is the equivalent of --color
    alias -E lst='\ls -G'
fi

alias -E egrep='nocorrect \egrep --line-buffered --color=auto'

# ls aliases
alias ls='lst -BFx'
alias l='lst -lFBGh'
alias ll='lsa -lAFGh'
alias lss='lst -BFshx'
alias lsp='\ls'

# safety aliases
alias rm='rm -i' cp='cp -i'
alias rmf='\rm' cpf='\cp'
alias ln="\ln -s"

# global aliases
alias -g G='|& egrep -i'
alias -g L='|& less -R'
alias -g Lr='|& less'
alias -g D='>&/dev/null'
alias -g W='|& wc -l -c'
alias -g Q='>&/dev/null&'
alias -E -g ,,=';=read -n1 -rp "Press any key to continue..."'

# regular aliases
alias su='su -'
alias watch='\watch -n 1 -d '
alias emacs='\emacs -nw'
alias df='\df -h'
alias ping='\ping -c 10'
alias exi='exit'
alias locate='\locate -ib'
alias -E exit=' exit'

# suppression aliases
alias -E man='nocorrect noglob \man'
alias -E find='noglob find'
alias -E touch='nocorrect \touch'
alias -E mkdir='nocorrect \mkdir'

if (( $+commands[killall] )); then
    alias -E killall='nocorrect \killall'
elif (( $+commands[pkill] )); then
    alias -E killall='nocorrect \pkill'
fi

# sudo aliases
if (( $+commands[sudo] )); then
    alias sudo='sudo '
    alias -ec please='echo sudo ${history[$#history]}'
fi

# yaourt aliases
if (( $+commands[yaourt] )); then
    alias y='yaourt'
    alias yi='yaourt -Sa'
    alias yu='yaourt -Syyua --noconfirm'
    alias yuu='yaourt --sucre'
fi

# yum aliases
if (( $+commands[yum] )); then
    if (( $user_has_root == 1 )); then
        alias -E yum-config-manager='nocorrect noglob \yum-config-manager'
        alias -E yum='nocorrect noglob \yum'
    else
        alias -E yum-config-manager='nocorrect noglob sudo \yum-config-manager'
        alias -E yum='nocorrect noglob sudo \yum'
    fi
fi

# git aliases
if (( $+commands[git] )); then
    alias gs='git status -s'
    alias gst='git status'

    alias gp="git pull --rebase -X patience"

    alias ga='git add'
    alias gau='git add -u'
    alias gaa='git add -A'

    alias gc='git commit -v'
    alias -ec gcm="echo git commit -v -m '{}'"
    alias gc!='git commit -v --amend'
    alias gca='git commit -v -a'
    alias -ec gcam="echo git commit -v -a -m '{}'"
    alias gca!='git commit -v -a --amend'

    alias gck='git checkout'
    alias -ec gfork='echo git checkout -b {} ${${(f)vcs_raw_data}[4]}'

    alias gb='git branch'
    alias gm='git merge -X patience --no-ff'
    alias gr="git rebase -X patience"

    alias gd='git diff --patience'
    alias gdc='git diff --patience --cached'
    alias gd!='git diff --word-diff'
    alias gdc!='git diff --word-diff --cached'

    alias gl='git log --oneline --graph --decorate'

    alias -eg .B='echo ${${(f)vcs_raw_data}[4]}'
fi

if (( $+commands[emacsclient] )); then
    alias -E ec='emacsclient -c -n'
    alias -E ecn='emacsclient -n'
    alias -E ect='emacsclient -t'
fi

# ==============
# Expand aliases
# ==============

# expand aliases on space
function expandAlias() {
    emulate -LR zsh
    {
        setopt function_argzero
        # hack a local function scope using unfuction
        function $0_smart_space () {
            if [[ $RBUFFER[1] != ' ' ]]; then
                if [[ ! "$1" == "no_space" ]]; then
                    zle magic-space
                fi
            else
                # we aren't at the end of the line so squeeze spaces

                zle forward-char
                while [[ $RBUFFER[1] == " " ]]; do
                    zle forward-char
                    zle backward-delete-char
                done
            fi
        }

        function $0_smart_expand () {
            zparseopts -D -E i=G
            local expansion="${@[2,-1]}"
            local delta=$(($#expansion - $expansion[(i){}] - 1))

            alias ${G:+-g} $1=${expansion/{}/}

            zle _expand_alias

            for ((i=0; i < $delta; i++)); do
                zle backward-char
            done
        }

        local cmd
        cmd=("${(@s/ /)LBUFFER}")
        if [[ -n "$command_abbrevs[$cmd[-1]]" && $#cmd == 1 ]]; then
            $0_smart_expand $cmd[-1] "$(${(s/ /e)command_abbrevs[$cmd[-1]]})"

        elif [[ -n "$global_abbrevs[$cmd[-1]]" ]]; then
            $0_smart_expand -g $cmd[-1] "$(${(s/ /e)global_abbrevs[$cmd[-1]]})"

        elif [[ ${(j: :)cmd} == *\!* ]] && alias "$cmd[-1]" &>/dev/null; then
            if [[ -n "$aliases[$cmd[-1]]" ]]; then
                LBUFFER="$aliases[$cmd[-1]] "
            fi

        elif (( ! $+expand[(r)$cmd[-1]] )) && [[ $cmd[-1] != (\\*) ]]; then
            zle _expand_alias
            $0_smart_space $1

        else
            $0_smart_space $1
        fi

    } always {
        unfunction -m "$0_*"
    }

    _zsh_highlight
}

zle -N expandAlias

bindkey " " expandAlias
bindkey "^ " magic-space
bindkey -M isearch " " magic-space

# ================================
# Section 4 -- Syntax Highlighting
# ================================

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source $ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh
source $ZDOTDIR/zsh-syntax-highlighting/highlighters/brackets/brackets-highlighter.zsh

ZSH_HIGHLIGHT_STYLES[default]='fg=grey'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=default'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[alias]='fg=default,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=default,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=default,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=default,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=black,bold'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=green'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green'
ZSH_HIGHLIGHT_STYLES[path]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue,bold,underline'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[assign]='fg=default,bold'
