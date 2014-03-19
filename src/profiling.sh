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

_R9E_BASHRC_PROFILING_START_TIME_LIST=()
_R9E_BASHRC_PROFILING_END_TIME_LIST=()
_R9E_BASHRC_PROFILING_DESCRIPTION_LIST=()
_R9E_BASHRC_PROFILING_CURRENT_FUNCTIONS_STACK=()

if [ "${_R9E_SHELL}" = 'zsh' ]; then
    _R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX='1'
else
    _R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX='0'
fi

_r9e_profiling_current_time()
{
    date +'%s%N'
}

_r9e_profiling_subshell_test()
{
    local subshell
    if [ "${_R9E_SHELL}" = 'bash' ]; then
        subshell="${BASH_SUBSHELL}"
    elif [ "${_R9E_SHELL}" = 'zsh' ]; then
        subshell="${ZSH_SUBSHELL}"
    fi

    if [ "${subshell}" -gt 0 ]; then
        _r9e_print_message 'error: calling profiling functions from within a subshell is not supported'
        false
    fi
}

_r9e_profiling_timer_start()
{
    local description="${*}"

    _r9e_profiling_subshell_test || return

    local stack_index=${#_R9E_BASHRC_PROFILING_CURRENT_FUNCTIONS_STACK[*]}
    stack_index=$(( ${stack_index} + ${_R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX} ))

    if [ "${stack_index}" -gt "${_R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX}" ]; then
        local parent_index=${_R9E_BASHRC_PROFILING_CURRENT_FUNCTIONS_STACK[${stack_index} - 1]}
    fi

    local index=${#_R9E_BASHRC_PROFILING_START_TIME_LIST[*]}
    index=$(( ${index} + ${_R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX} ))

    _R9E_BASHRC_PROFILING_END_TIME_LIST[${index}]='-1'
    _R9E_BASHRC_PROFILING_DESCRIPTION_LIST[${index}]="${description}"
    _R9E_BASHRC_PROFILING_CURRENT_FUNCTIONS_STACK+=( ${index} )

    eval "_R9E_BASHRC_PROFILING_${index}_CHILDREN=()"

    if [ "${stack_index}" -gt "${_R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX}" ]; then
        eval "_R9E_BASHRC_PROFILING_${parent_index}_CHILDREN+=( '${index}' )"
    fi

    # Do this as last thing to not count this function into the runtime.
    _R9E_BASHRC_PROFILING_START_TIME_LIST[${index}]="$(_r9e_profiling_current_time)"
}

_r9e_profiling_timer_end()
{
    _r9e_profiling_subshell_test || return

    # Do this as first thing to not count this function into the runtime.
    local end_time="$(_r9e_profiling_current_time)"

    local stack_index=$(( ${#_R9E_BASHRC_PROFILING_CURRENT_FUNCTIONS_STACK[*]} - 1 ))
    stack_index=$(( ${stack_index} + ${_R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX} ))

    local index=${_R9E_BASHRC_PROFILING_CURRENT_FUNCTIONS_STACK[${stack_index}]}

    if [ "${_R9E_SHELL}" = 'zsh' ]; then
        _R9E_BASHRC_PROFILING_CURRENT_FUNCTIONS_STACK[${stack_index}]=()
    else
        unset _R9E_BASHRC_PROFILING_CURRENT_FUNCTIONS_STACK[${stack_index}]
    fi

    _R9E_BASHRC_PROFILING_END_TIME_LIST[${index}]="${end_time}"

    if [ "${index}" -eq "${_R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX}" ]; then
        _r9e_profiling_print_times
    fi
}

_r9e_profiling_print_times()
{
    _r9e_profiling_print_entry "${_R9E_BASHRC_PROFILING_FIRST_ARRAY_INDEX}" 0 ''

    _R9E_BASHRC_PROFILING_START_TIME_LIST=()
    _R9E_BASHRC_PROFILING_END_TIME_LIST=()
    _R9E_BASHRC_PROFILING_DESCRIPTION_LIST=()
}

_r9e_profiling_print_entry()
{
    local index="${1}"
    local indentation="${2}"
    local parent_total="${3}"

    local start_time="${_R9E_BASHRC_PROFILING_START_TIME_LIST[${index}]}"
    local end_time="${_R9E_BASHRC_PROFILING_END_TIME_LIST[${index}]}"
    local description="${_R9E_BASHRC_PROFILING_DESCRIPTION_LIST[${index}]}"

    local prefix="$(printf "%$(( 4 * ${indentation} + 2 ))s" '=>')"
    local elapsed_time="$(echo "scale=5; (${end_time} - ${start_time}) / 1000000" | bc)"

    local percent=''
    if [ -n "${parent_total}" ]; then
        percent="$(echo "scale=4; ${elapsed_time} / ${parent_total} * 100" | bc)"
        percent="$(printf ' (%7s%%)' "${percent}")"
    fi

    _r9e_print_message '%-18s%50s: %10s milliseconds%s' "${prefix}" "${description}" "${elapsed_time}" "${percent}"

    local -a children
    eval 'children=(' "\"\${_R9E_BASHRC_PROFILING_${index}_CHILDREN[@]}\"" ')'

    local indentation=$(( ${indentation} + 1 ))
    local child
    for child in "${children[@]}"; do
        _r9e_profiling_print_entry ${child} ${indentation} ${elapsed_time}
    done
}
