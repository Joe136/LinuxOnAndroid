
# LinuxOnAndroid
# the second line is for detecting this script as part of the project
# if you want that it wasn't changed, add the keyword 'exclude'
# if you want that only new aliases was added, add the keyword 'update'


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
alias apt-search-names='apt-cache search --names-only'
alias apt-show='apt-cache show'
alias apt-showpkg='apt-cache showpkg'
alias apt-source='apt-get source'
alias apt-update='apt-get update'
alias apt-upgrade='apt-get upgrade'


# extra aliases for APT
alias apt-list='dpkg -l'
alias apt-list-grep='dpkg -l | grep'


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
alias lld="ls -alFd"
alias lsd="ls -Ad"


# aliases for nano
alias nanoc="nano -Y c"
alias nanocss="nano -Y css"
#alias nanodebian="nano -Y debian"
#alias nanogentoo="nano -Y gentoo"
alias nanohtml="nano -Y html"
alias nanophp="nano -Y php"
#alias nanotcl="nano -Y tcl"
alias nanotex="nano -Y tex"
#alias nanomutt="nano -Y mutt"
alias nanopatch="nano -Y patch"
alias nanoman="nano -Y man"
#alias nanogroff="nano -Y groff"
alias nanoperl="nano -Y perl"
alias nanopython="nano -Y python"
alias nanoruby="nano -Y ruby"
alias nanojava="nano -Y java"
alias nanoawk="nano -Y awk"
alias nanoasm="nano -Y asm"
alias nanosh="nano -Y sh"
#alias nanopov="nano -Y pov"
alias nanoxml="nano -Y xml"

alias nano_c="nano -Y c"
alias nano_css="nano -Y css"
#alias nano_debian="nano -Y debian"
#alias nano_gentoo="nano -Y gentoo"
alias nano_html="nano -Y html"
alias nano_php="nano -Y php"
#alias nano_tcl="nano -Y tcl"
alias nano_tex="nano -Y tex"
#alias nano_mutt="nano -Y mutt"
alias nano_patch="nano -Y patch"
alias nano_man="nano -Y man"
#alias nano_groff="nano -Y groff"
alias nano_perl="nano -Y perl"
alias nano_python="nano -Y python"
alias nano_ruby="nano -Y ruby"
alias nano_java="nano -Y java"
alias nano_awk="nano -Y awk"
alias nano_asm="nano -Y asm"
alias nano_sh="nano -Y sh"
#alias nano_pov="nano -Y pov"
alias nano_xml="nano -Y xml"


# general aliases
alias free="free; echo \"\"; cat /proc/swaps"
#alias newscreen="screen -dmS linux -T xterm-color -s /usr/bin/tmux"
alias newscreen="screen -dmS linux -s /usr/bin/tmux"

