
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

# aliases for APT
alias apt-autoclean='apt-get autoclean'
alias apt-autoremove='apt-get autoremove'
alias apt-build-dep='apt-get build-dep'
alias apt-changelog='apt-get changelog'
alias apt-check='apt-get check'
alias apt-clean='apt-get clean'
alias apt-dist-upgrade='apt-get dist-upgrade'
alias apt-download='apt-get download'
alias apt-dselect-upgrade='apt-get dselect-upgrade'
alias apt-install='apt-get install'
alias apt-purge='apt-get purge'
alias apt-remove='apt-get remove'
alias apt-search='apt-cache search'
alias apt-source='apt-cache source'
alias apt-update='apt-get update'
alias apt-upgrade='apt-get upgrade'

# extra aliases for APT
alias apt-list='dpkg -l'


# aliases for coloring
# enable color support of ls and also add handy aliases
if [ -x "/usr/bin/dircolors" ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -A --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    #alias lessv='/usr/share/vim/vim71/macros/less.sh'
else
    alias ls='ls -A'
fi

# forced color effects
alias lsc='ls --color=always'
alias llc='ll --color=always'
alias grepc='grep --color=always'
alias fgrepc='fgrep --color=always'
alias egrepc='egrep --color=always'
alias lessc='less -R'


# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias du='du -hs'


# general aliases
alias free="free; echo \"\"; cat /proc/swaps"
#alias newscreen="screen -dmS linux -T xterm-color -s /usr/bin/tmux"
alias newscreen="screen -dmS linux -s /usr/bin/tmux"
alias nanosh="nano -Y sh"

