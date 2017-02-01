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

# Source the first file which exists and is readable.
_r9e_source()
{
    local file
    for file in "${@}"; do
        if [ -r "${file}" -a ! -d "${file}" ]; then
            _r9e_profiling_timer_start "${file}"
            source "${file}"
            _r9e_profiling_timer_end
            return
        fi
    done
}

_r9e_prepend_to_path()
{
    local directory="${1}"

    # Normalize directory by removing a trailing /.
    directory="${directory%/}"

    if [ ! -d "${directory}" ]; then
        return
    fi

    if echo "${PATH}" | egrep -q "(^|:)${directory}($|:)"; then
        return
    fi

    export PATH="${directory}:${PATH}"
}

# Source every *.sh file in the given directory and follow directories named *.d
# recursively. Also add all directories named *.path to the PATH.
_r9e_source_directory()
{
    local directory="${1}"

    directory="${directory}/"

    if ! [ -d "${directory}" ]; then
        return
    fi

    local file
    while read -rd $'\0' file; do
        _r9e_source "${file}"
    done < <(find -L "${directory}" -mindepth 1 -maxdepth 1 -name '*.sh' -type f -print0)

    local subdirectory
    while read -rd $'\0' subdirectory; do
        _r9e_source_directory "${subdirectory}"
    done < <(find -L "${directory}" -mindepth 1 -maxdepth 1 -name '*.d' -type d -print0)

    while read -rd $'\0' subdirectory; do
        _r9e_prepend_to_path "${subdirectory}"
    done < <(find -L "${directory}" -mindepth 1 -maxdepth 1 -name '*.path' -type d -print0)
}

# Prints the hostname up to the first dot (like \h in bash prompting).
_r9e_short_hostname()
{
    local hostname="${HOSTNAME:-${HOST}}"
    echo "${hostname%%.*}"
}

_r9e_is_executable()
{
    local name="${1}"

    type "${name}" >/dev/zero 2>&1
}

_r9e_check_type()
{
    local name="${1}"
    local type="${2}"

    local real_type
    if [ "${_R9E_SHELL}" = 'zsh' ]; then
        if real_type="$(whence -w "${name}")"; then
            test "${real_type}" = "${name}: ${type}"
            return ${?}
        fi
    else
        if real_type="$(type -t "${name}")"; then
            test "${real_type}" = "${type}"
            return ${?}
        fi
    fi

    return 1
}

_r9e_is_shell_function()
{
    local name="${1}"

    _r9e_check_type "${name}" 'function'
}

_r9e_file_modification_timestamp()
{
    local file="${1}"

    if [ "$(uname)" = 'Darwin' ]; then
        stat -f '%m' -t '%s' "${file}"
    else
        stat -c '%Y' "${file}"
    fi
}

_r9e_current_timestamp()
{
    date '+%s'
}

_r9e_timestamp_to_date()
{
    local timestamp="${1}"

    if [ "$(uname)" = 'Darwin' ]; then
        date -r "${timestamp}"
    else
        date -d "@${timestamp}"
    fi
}

_r9e_run_git_in_directory()
{
    local directory="${1}"
    shift

    git --git-dir="${directory}/.git" --work-tree="${directory}" "${@}"
}

_r9e_array_contains()
{
    local needle="${1}"
    shift
    local haystack
    haystack=( "${@}" )

    for elem in "${haystack[@]}"; do
        if [ "${elem}" = "${needle}" ]; then
            return 0
        fi
    done

    return 1
}

_r9e_set_completion_function()
{
    local command="${1}"
    local function="${2}"

    if _r9e_is_shell_function "${function}"; then
        if [ "${_R9E_SHELL}" = 'bash' ]; then
            complete -F "${function}" "${command}"
        elif [ "${_R9E_SHELL}" = 'zsh' ]; then
            compdef "${function}" "${command}"
        fi
    fi
}
