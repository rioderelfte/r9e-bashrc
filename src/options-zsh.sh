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

# completion
r9e_completion_paths=(
    '/usr/local/share/zsh-completions'
    '/usr/local/share/zsh/site-functions'
    "${_R9E_BASHRC_SRC_PATH}/zsh-completion"
)

if ${_R9E_BASHRC_ZSH_BREW_COMPLETION:-true}; then
    if _r9e_is_executable brew; then
        r9e_completion_paths+=(
            "$(brew --prefix)/share/zsh-completions"
            "$(brew --prefix)/share/zsh/site-functions"
        )
    fi
fi

for dir in ${r9e_completion_paths}; do
    if [ -d "${dir}" ]; then
        fpath=(
            "${dir}"
            ${fpath}
        )
    fi
done


if ${_R9E_BASHRC_ZSH_COMPINIT:-true}; then
    autoload -Uz compinit
    compinit
fi

zmodload zsh/complist

zstyle ':completion:*' completer _complete _approximate _ignored
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=3
zstyle ':completion:*' use-ip true
# complete a trailing slash after ..
zstyle -e ':completion:*' special-dirs '[[ ${PREFIX} == (../)#.. ]] && reply=(..)'

bindkey -M menuselect '^o' accept-and-infer-next-history

# history
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt append_history
setopt extended_history
setopt inc_append_history_time
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

# zle
bindkey -e

bindkey '^[[Z' reverse-menu-complete

autoload -U select-word-style
select-word-style bash

setopt interactive_comments

# misc
setopt autocd extendedglob notify

autoload -U zmv

if _r9e_is_executable 'sk' && _r9e_is_executable 'fd' && _r9e_is_executable 'bat' && _r9e_is_executable 'eza'; then
    _r9e_search_file() {
        zle -I

        file="$( \
            fd \
                --type f --type d \
                --color always \
                --hidden \
                --exclude .git | \
            sk \
                --ansi \
                --preview 'test -d {} && eza -lFh --icons --color=always --group-directories-first --git --no-permissions --no-user --no-filesize --no-time {} || bat -f {}' \
        )"

        local ret="${?}"

        zle reset-prompt

        if [ "${ret}" -eq 0 -a -n "${file}" ]; then
            LBUFFER="${LBUFFER}${(q)file}"
        fi
    }

    zle -N _r9e_search_file_widget _r9e_search_file

    bindkey '^ ' _r9e_search_file_widget
fi
