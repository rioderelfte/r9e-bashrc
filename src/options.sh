################################################################################
#                                                                              #
# Copyright (c) 2011 - 2021, Florian Sowade <f.sowade@r9e.de>                  #
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

if [ "${TERM}" = 'xterm' -a "${COLORTERM}" = 'gnome-terminal' ]; then
    export TERM='xterm-256color'
fi

if dircolors --sh >/dev/zero 2>&1; then
    eval "$(dircolors)"
elif gdircolors --sh >/dev/zero 2>&1; then
    eval "$(gdircolors)"
fi

export BAT_THEME="OneHalfLight"
export FZF_DEFAULT_OPTS='--color=fg:-1,bg:-1,preview-fg:-1,preview-bg:-1,hl:196,fg+:-1,bg+:254,hl+:196,gutter:-1,pointer:9'
export SKIM_DEFAULT_OPTIONS="${FZF_DEFAULT_OPTS},matched_bg:-1,current_match_bg:-1"
if _r9e_is_executable 'fd'; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export SKIM_DEFAULT_COMMAND="${FZF_DEFAULT_COMMAND}"
    export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --exclude .git'
fi
if _r9e_is_executable 'bat' && _r9e_is_executable 'exa'; then
    export FZF_CTRL_T_OPTS='--preview "test -d {} && exa -lF --icons --group-directories-first {} || bat -f {}"'
fi

if _r9e_is_executable brew; then
    _r9e_source "$(brew --prefix)/opt/fzf/shell/key-bindings.${_R9E_SHELL}"
fi
