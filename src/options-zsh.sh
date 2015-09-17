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

if _r9e_is_executable brew; then
    r9e_completion_paths+=(
        "$(brew --prefix)/share/zsh-completions"
        "$(brew --prefix)/share/zsh/site-functions"
    )
fi

for dir in ${r9e_completion_paths}; do
    if [ -d "${dir}" ]; then
        fpath=(
            "${dir}"
            ${fpath}
        )
    fi
done

autoload -Uz compinit
compinit

zmodload zsh/complist

zstyle ':completion:*' completer _complete _approximate _ignored
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=3

bindkey -M menuselect '^o' accept-and-infer-next-history

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt extended_history
setopt inc_append_history
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
