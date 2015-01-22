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

# general
setopt ZLE                    # magic stuff
setopt NO_BEEP                # beep is annoying
setopt RM_STAR_WAIT           # are you REALLY sure?
setopt AUTO_RESUME            # running a suspended program
setopt CHECK_JOBS             # check jobs before exiting
setopt AUTO_CONTINUE          # send CONT to disowned processes
setopt FUNCTION_ARGZERO       # $0 contains the function name
setopt INTERACTIVE_COMMENTS   # shell comments (for presenting)

# correction
setopt CORRECT_ALL            # autocorrect misspelt commands
setopt AUTO_LIST              # list if multiple matches
setopt COMPLETE_IN_WORD       # complete at cursor
setopt MENU_COMPLETE          # add first of multiple
setopt AUTO_REMOVE_SLASH      # remove extra slashes if needed
setopt AUTO_PARAM_SLASH       # completed directory ends in /
setopt AUTO_PARAM_KEYS        # smart insert spaces " "
setopt LIST_PACKED            # conserve space

# globbing
setopt NUMERIC_GLOB_SORT      # sort globs numerically
setopt RC_EXPAND_PARAM        # globbing arrays
setopt EXTENDED_GLOB          # awesome globs
setopt NO_CASE_GLOB           # lazy case
setopt BARE_GLOB_QUAL         # can use qualifirs by themselves
setopt MARK_DIRS              # glob directories end in "/"
setopt LIST_TYPES             # append type chars to files
setopt NULL_GLOB              # don't err on null globs
setopt BRACE_CCL              # extended brace expansion

# history
setopt HIST_REDUCE_BLANKS     # collapse extra whitespace
setopt HIST_IGNORE_SPACE      # ignore lines starting with " "
setopt HIST_IGNORE_DUPS       # ignore immediate duplicates
setopt HIST_FIND_NO_DUPS      # ignore all search duplicates
setopt APPEND_HISTORY         # append is good, append!
setopt INC_APPEND_HISTORY     # append in real time
setopt SHARE_HISTORY          # share history between terminals
setopt HIST_NO_STORE          # don't store history commands
setopt HIST_EXPIRE_DUPS_FIRST # kill the dups! kill the dups!

# I/O and syntax
setopt MULTIOS                # redirect to globs!
setopt MULTIBYTE              # Unicode!
setopt NOCLOBBER              # don't overwrite with > use !>
setopt EQUALS                 # "=ps" ==> "/usr/bin/ps"
setopt HASH_LIST_ALL          # more accurate correction
setopt LIST_ROWS_FIRST        # rows are way better
setopt HASH_CMDS              # don't search for commands
setopt CDABLE_VARS            # in p, cd x ==> ~/x if x not p
setopt SHORT_LOOPS            # sooo lazy: for x in y do cmd
setopt CHASE_LINKS            # resolve links to their location

# navigation
setopt AUTO_CD                # just "dir" instead of "cd dir"
setopt AUTO_PUSHD             # push everything to the dirstack
setopt PUSHD_SILENT           # don't tell me though, I know.
setopt PUSHD_IGNORE_DUPS      # duplicates are redundant (duh)
setopt PUSHD_MINUS            # invert pushd behavior
setopt PUSHD_TO_HOME          # pushd == pushd ~
setopt AUTO_NAME_DIRS         # if I set a=/usr/bin, cd a works

setopt PROMPT_SUBST           # I might use this one day
setopt IGNORE_EOF             # I never EOF. Must be accidental

zmodload -a stat
autoload zargs
autoload zmv

# ================================
# Section 2 -- Persistent dirstack
# ================================

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

touch $ZDOTDIR/zdirs

zstyle ':chpwd:*' recent-dirs-max 100
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-pushd true
zstyle ':chpwd:*' recent-dirs-file "$ZDOTDIR/zdirs"

dirstack=(${(nu@Q)$(<$ZDOTDIR/zdirs)})

zstyle ':completion:*:cdr:*' verbose true
zstyle ':completion:*:cdr:*' extra-verbose true

# =======================
# Section 3 -- The Prompt
# =======================

# show the last error code and highlight root in red
PS1=$'%{%F{red}%}%(?..Error: (%?%)\n)%F{default}[%{%B%(!.%F{red}.%F{black})%}'

# username, reset decorations, pwd
PS1=$PS1$'%n%b%F{default} %~'"$((($SHLVL > 1))&&echo ' <%L>')]%# "

# ====================
# Section 4 -- Aliases
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
    alias -E yum-config-manager='nocorrect noglob \yum-config-manager'
    alias -E yum='nocorrect noglob \yum'
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

    alias gb='git branch'
    alias gm='git merge -X patience --no-ff'
    alias gr="git rebase -X patience"

    alias gd='git diff --patience'
    alias gdc='git diff --patience --cached'
    alias gd!='git diff --word-diff'
    alias gdc!='git diff --word-diff --cached'

    alias gl='git log --oneline --graph --decorate'
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
# Section 5 -- Syntax Highlighting
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

# ===============================
# Section 6 -- FASD teleportation
# ===============================

function {
    emulate -LR zsh
    local fasd_cache=$ZDOTDIR/fasd-init-cache
    local fasd_path=$ZDOTDIR/fasd/fasd

    source $fasd_path

    if [[ ! -w $fasd_cache ]]; then
        echo setting fasd up
        touch $fasd_cache
        $fasd_path --init \
                   zsh-hook \
                   zsh-wcomp \
                   zsh-wcomp-install \
                   > $fasd_cache
    fi

    source $fasd_cache
}

# interactive directory selection
alias sd='fasd -sid'
# interactive file selection
alias sf='fasd -sif'

# cd, same functionality as j in autojump
alias j='fasd -e cd -d'

# ===========================
# Section 7 -- the go command
# ===========================

alias -E go="nocorrect go"
function go() {
    emulate -LR zsh
    setopt no_case_glob no_case_match equals
    cmd=(${(s/ /)1})
    # if it's a file and it's not binary and I don't need to be root
    if [[ -f "$1" ]]; then
        if file $1 |& grep '\(ASCII text\|Unicode text\|no magic\)' &>/dev/null; then
            if [[ -r "$1" ]]; then
                if ps ax |& egrep -i 'emacs.*--daemon' &>/dev/null; then
                    # launch GUI editor
                    emacsclient -t -a "emacs" $1
                else
                    # launch my editor
                    $EDITOR "$1"
                fi
            else
                echo "zsh: insufficient permissions"
            fi
        else
            # it's binary, open it with xdg-open
            if [[ -n =xdg-open && -n "$DISPLAY" && ! -x $1 ]]; then
                (xdg-open "$1" &) &> /dev/null
            else
                # without x we try suffix aliases
                ($1&)>&/dev/null
            fi
        fi

    elif [[ -d "$1" ]]; then \cd "$1" # directory, cd to it
    elif [[ "" = "$1" ]]; then \cd    # nothing, go home

    # if it's a program, launch it in a seperate process in the background
    elif [[ $(type ${cmd[1]}) != *not* ]]; then
        ($@&)>/dev/null

        # check if dir is registered in database
    elif [[ -n $(fasd -d $@) ]]; then
        local fasd_target=$(fasd -d $@)
        local teleport
        teleport=${(D)fasd_target}
        teleport=" ${fg_bold[blue]}$teleport${fg_no_bold[default]}"
        if [[ $fasd_target != (*$@*) ]]; then
            read -k REPLY\?"zsh: teleport to$teleport? [ny] "
            if [[ $REPLY == [Yy]* ]]; then
                echo " ..."
                cd $fasd_target
            fi
        else
            echo -n "zsh: teleporting: $@"
            echo $teleport
            cd $fasd_target
        fi
    else
        command_not_found=1
        command_not_found_handler $@
        return 1
    fi
}

# =============================
# Section 8 -- history settings
# =============================

HISTFILE=~/.zsh.d/histfile
HISTSIZE=50000
SAVEHIST=50000
