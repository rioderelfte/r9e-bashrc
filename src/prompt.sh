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

_r9e_prompt_command_const()
{
    local const="${1-true}"

    ${const}
}

_r9e_prompt_resolve_color()
{
    local color="${1}"

    if [ "${color}" = 'user' ]; then
        color="${_R9E_PROMPT_USER_COLOR_DEFAULT}"
        if [ "${EUID}" == 0 ]; then
            color="${_R9E_PROMPT_USER_COLOR_ROOT}"
        fi
    fi

    echo "${color}"
}

_r9e_prepare_prompt_single_function()
{
    local command="${1}"
    shift

    local fg_color='default'
    local bg_color='default'

    local OPTIND=1
    local OPTARG
    local cur_opt
    while getopts 'f:b:' cur_opt; do
        case "${cur_opt}" in
            f)
                fg_color="$(_r9e_prompt_resolve_color "${OPTARG}")";;
            b)
                bg_color="$(_r9e_prompt_resolve_color "${OPTARG}")";;
        esac
    done

    shift $(( OPTIND - 1 ))

    local prompt_function="_r9e_prompt_function_${command}"

    local result
    if result="$(${prompt_function} 0 "${fg_color}" "${bg_color}" "${@}")"; then
        echo "${result}"
    else
        echo -n '$('
        echo -n "${prompt_function}"
        echo -n ' "${return_code}"'

        local argument
        for argument in "${fg_color}" "${bg_color}" "${@}"; do
            echo -n " '${argument}'"
        done

        echo ')'
    fi
}

_r9e_prepare_prompt()
{
    local prompt="${1}"

    prompt="$(echo "${prompt}" | sed 's/%\([a-zA-Z0-9_]*\)(\([^)]*\))/$(_r9e_prepare_prompt_single_function \1 \2)/g')"
    eval "echo \"${prompt}\""
}

_r9e_export_prepared_prompts()
{
    _r9e_profiling_function_start

    _r9e_profiling_timer_start 'prepare prompt PS1'
    _R9E_PROMPT_PS1_PREPARED="$(_r9e_prepare_prompt "${_R9E_PROMPT_PS1}")"
    _r9e_profiling_timer_end

    _r9e_profiling_timer_start 'prepare prompt PS2'
    _R9E_PROMPT_PS2_PREPARED="$(_r9e_prepare_prompt "${_R9E_PROMPT_PS2}")"
    _r9e_profiling_timer_end

    _r9e_profiling_timer_start 'prepare prompt TERM TITLE'
    _R9E_PROMPT_TERM_TITLE_PREPARED="$(_R9E_ENABLE_COLORS='false' _r9e_prepare_prompt "${_R9E_PROMPT_TERM_TITLE}")"
    _r9e_profiling_timer_end

    _r9e_profiling_function_end
}

_r9e_generate_prompt()
{
    local prompt="${1}"
    local return_code="${2}"

    eval "prompt=\"${prompt}\"" 2>/dev/zero

    echo -ne "${prompt}"
}

_r9e_export_prompt()
{
    local return_code="${1}"

    local ps1="$(_r9e_generate_prompt "${_R9E_PROMPT_PS1_PREPARED}" "${return_code}")"
    local ps2="$(_r9e_generate_prompt "${_R9E_PROMPT_PS2_PREPARED}" "${return_code}")"
    local term_title="${_R9E_PROMPT_TERM_TITLE_PREPARED}"
    term_title="$(_R9E_ENABLE_COLORS='false' _r9e_generate_prompt "${term_title}" "${return_code}")"
    term_title="$(_r9e_term_title -p "${term_title}")"

    export PS1="${term_title}${ps1}"
    export PS2="${term_title}${ps2}"
}

# Allow the user put a string into the prompt (for one session).
_R9E_PROMPT_CURRENT_USER_STRING=''
r9e_set_prompt_string()
{
    _R9E_PROMPT_CURRENT_USER_STRING="${@}"

    if [ -n "${_R9E_PROMPT_CURRENT_USER_STRING}" ]; then
        _R9E_PROMPT_CURRENT_USER_STRING="${_R9E_PROMPT_CURRENT_USER_STRING} "
    fi
}

# the default prompts
_R9E_PROMPT_PS1="%user_string()%user(-f user)%at(-f user)%rainbow_hostname()%errcode(-f red ' err: %d')%jobs_summary(-f yellow ' (%dr, %ds)') %fish_path(-f blue) %dollar(-f blue) "
_R9E_PROMPT_PS2='> '
_R9E_PROMPT_TERM_TITLE="%user()%at()%hostname(): %full_path()"

# some configuration options
_R9E_PROMPT_USER_COLOR_DEFAULT='green'
_R9E_PROMPT_USER_COLOR_ROOT='red'
