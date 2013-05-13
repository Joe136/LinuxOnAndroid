# System-wide .bashrc file for interactive bash(1) shells.
# LinuxOnAndroid
# the second line is for detecting this script as part of the project
# if you want that it wasn't changed, add the keyword 'exclude'

# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x "/usr/bin/lesspipe" ] && eval "$(SHELL=/bin/sh lesspipe)"


function reset_ps1 {
    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "$debian_chroot" ] && [ -r "/etc/debian_chroot" ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    # Part of Linux Mint Debian
    use_color=false

    # Set colorful PS1 only on colorful terminals.
    # dircolors --print-database uses its own built-in database
    # instead of using /etc/DIR_COLORS.  Try to use the external file
    # first to take advantage of user additions.  Use internal bash
    # globbing instead of external grep binary.
    safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
    match_lhs=""
    [[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
    [[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
    [[ -z ${match_lhs}    ]] \
            && type -P dircolors >/dev/null \
            && match_lhs=$(dircolors --print-database)
    [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

    ssh_extern="$(echo $SSH_CONNECTION | awk '{ print $3 }')"
    [[ -z "$ssh_extern" ]] && ssh_extern='\h'

    if ${use_color} ; then
            # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
            if type -P dircolors >/dev/null ; then
                    if [[ -f ~/.dir_colors ]] ; then
                            eval $(dircolors -b ~/.dir_colors)
                    elif [[ -f /etc/DIR_COLORS ]] ; then
                            eval $(dircolors -b /etc/DIR_COLORS)
                    fi
            fi

            if [[ ${EUID} == 0 ]] ; then
                    PS1="${debian_chroot:+\[\033[01;33m\]($debian_chroot)}"'\[\033[01;31m\]\u\[\033[01;32m\]@'"$ssh_extern"'\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
            #        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
            else
                    PS1="${debian_chroot:+\[\033[01;33m\]($debian_chroot)}"'\[\033[01;32m\]\u@'"$ssh_extern"'\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
            #        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
            fi

            #alias ls='ls --color=auto'
            #alias grep='grep --colour=auto'
    else
            PS1="${debian_chroot:+($debian_chroot)}"'\u@'"$ssh_extern"':\w\$ '

            #if [[ ${EUID} == 0 ]] ; then
            #        # show root@ when we don't have colors
            #        PS1='\u@\h \W \$ '
            #else
            #        PS1='\u@\h \w \$ '
            #fi
    fi

    # Try to keep environment pollution down, EPA loves us.
    unset use_color safe_term match_lhs ssh_extern
}

reset_ps1


# Alias definitions.
# You may want to put all your additions into a separate file like
# /etc/bash.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f "/etc/bash.bash_aliases" ]; then
    . /etc/bash.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this).
if ! shopt -oq posix; then
    if [ -f "/usr/share/bash-completion/bash_completion" ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f "/etc/bash_completion" ]; then
        . /etc/bash_completion
    fi

    #if [ -f ~/.bash_completion ]; then
    #    . ~/.bash_completition
    #fi
fi

# if the command-not-found package is installed, use it
if [ -x "/usr/lib/command-not-found" -o -x "/usr/share/command-not-found/command-not-found" ]; then
    function command_not_found_handle {
        # check because c-n-f could've been removed in the meantime
        if [ -x "/usr/lib/command-not-found" ]; then
            /usr/bin/python /usr/lib/command-not-found -- "$1"
            return $?
        elif [ -x "/usr/share/command-not-found/command-not-found" ]; then
            /usr/bin/python /usr/share/command-not-found/command-not-found -- "$1"
            return $?
        else
            printf "%s: command not found\n" "$1" >&2
            return 127
        fi
    }
fi

