################################################################################
#                                                                              #
# Copyright (c) 2011 - 2014, Florian Sowade <f.sowade@r9e.de>                  #
#                                                                              #
# Permission to use, copy, modify, and/or distribute this software for any     #
# purpose with or without fee is hereby granted, provided that the above       #
# copyright notice and this permission notice appear in all copies.            #
#                                                                              #
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES     #
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF             #
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR      #
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES       #
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN        #
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF      #
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.               #
#                                                                              #
################################################################################

alias tree='tree -CA'
alias psg='ps aux | grep'

if _r9e_is_executable 'xdg-open'; then
    alias gopen='xdg-open'
fi

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

if ls --color=auto >/dev/zero 2>&1; then
    alias ls='ls --color=auto'
elif [ "$(uname)" = "Darwin" ]; then
    alias ls='ls -G'
fi

if _r9e_is_executable eza; then
    alias l='eza'
    alias ll='eza --icons -lF'
    alias la='eza -aa'
    alias lla='eza --icons -lFaa'
else
    alias l='ls'
    alias ll='ls -lh'
    alias la='ls -a'
    alias lla='ls -lah'
fi

if _r9e_is_executable bat; then
    alias batp='bat --plain'
fi

if _r9e_is_executable fd; then
    alias fd-dirs='fd --unrestricted --prune --glob'
fi

alias bashrc="source ${_R9E_BASHRC_SRC_PATH}/init.sh"

alias ymd="date '+%Y-%m-%d'"

alias find-swap-files="find . -name '.*.s[a-w][a-p]'"

if which --tty-only 'which' >/dev/zero 2>&1; then
    # Fedora already defines which as an alias before the user's bashrc is
    # sourced. This little hack makes sure there won't be an error if which is
    # an alias.

    _r9e_which()
    {
        (
            alias
            declare -f
        ) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot "${@}"
    }

    alias which='_r9e_which'
fi

alias cdg='cd_git_root'

alias ssh-without-keys='ssh -o PubkeyAuthentication=no -o ControlMaster=no -o ControlPath=none'
alias wssh='wait_for_ssh'
alias no_host_key_wssh='wssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
if [ "${_R9E_SHELL}" = 'bash' ]; then
    _r9e_set_completion_function ssh-without-keys _ssh
    _r9e_set_completion_function wssh _ssh
    _r9e_set_completion_function no_host_key_wssh _ssh
fi
