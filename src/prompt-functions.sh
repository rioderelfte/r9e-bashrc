################################################################################
#                                                                              #
# Copyright (c) 2011 - 2013, Florian Sowade <f.sowade@r9e.de>                  #
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

_r9e_prompt_function_string()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"
    shift 3
    local text="${*}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" "${text}"
    _r9e_prompt_command_const
}

_r9e_prompt_function_user()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" '\u'
    _r9e_prompt_command_const
}

_r9e_prompt_function_path()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" '\W'
    _r9e_prompt_command_const
}

_r9e_prompt_function_full_path()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" '\w'
    _r9e_prompt_command_const
}

# This idea is from the fish shell (https://github.com/fish-shell/fish-shell)
_r9e_prompt_function_fish_path()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" "$(pwd | sed -e "s|^${HOME}|~|"';s|\([^/]\)[^/]*/|\1/|g')"
    _r9e_prompt_command_const false
}

_r9e_prompt_function_hostname()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" '\h'
    _r9e_prompt_command_const
}

_r9e_prompt_function_full_hostname()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" '\H'
    _r9e_prompt_command_const
}

_r9e_prompt_function_dollar()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" '\\\$'
    _r9e_prompt_command_const
}

_r9e_prompt_function_at()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" '@'
    _r9e_prompt_command_const
}

_r9e_prompt_function_rainbow_hostname()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    local hostname="$(_r9e_short_hostname)"

    _r9e_colorize_rainbow -pb "${bg_color}" "${hostname}"
    _r9e_prompt_command_const
}

_r9e_prompt_function_rainbow_full_hostname()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    local hostname="$(hostname)"

    _r9e_colorize_rainbow -pb "${bg_color}" "${hostname}"
    _r9e_prompt_command_const
}

_r9e_prompt_function_errcode()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"
    local format="${4:- %d}"

    if [ "${return_code}" -ne '0' ]; then
        _r9e_colorize -pf "${fg_color}" -b "${bg_color}" "$(printf "${format}" "${return_code}")"
    fi
    _r9e_prompt_command_const false
}

_r9e_prompt_function_jobs_summary()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"
    local format="${4:- %dr, %ds}"

    local running_jobs="$(jobs -rp | wc -l)"
    local sleeping_jobs="$(jobs -sp | wc -l)"

    if [ "${running_jobs}" -gt '0' -o "${sleeping_jobs}" -gt '0' ]; then
        _r9e_colorize -pf "${fg_color}" -b "${bg_color}" "$(printf "${format}" "${running_jobs}" "${sleeping_jobs}")"
    fi
    _r9e_prompt_command_const false
}

_r9e_prompt_function_user_string()
{
    local return_code="${1}"
    local fg_color="${2}"
    local bg_color="${3}"

    _r9e_colorize -pf "${fg_color}" -b "${bg_color}" "${_R9E_PROMPT_CURRENT_USER_STRING}"
    _r9e_prompt_command_const false
}
