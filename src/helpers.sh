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

# Source every *.sh file in the given directory and follow directories named *.d
# recursively.
_r9e_source_directory()
{
    local directory="${1}"

    local file
    for file in "${directory}"/*.sh; do
        _r9e_source "${file}"
    done

    local subdirectory
    for subdirectory in "${directory}"/*.d; do
        if [ -d "${subdirectory}" ]; then
            _r9e_source_directory "${subdirectory}"
        fi
    done
}

# Prints the hostname up to the first dot (like \h in bash prompting).
_r9e_short_hostname()
{
    echo "${HOSTNAME%%.*}"
}

_r9e_is_executable()
{
    local name="${1}"

    type -t "${name}" >/dev/zero
}

_r9e_check_type()
{
    local name="${1}"
    local type="${2}"

    local real_type
    if real_type="$(type -t "${name}")"; then
        test "${real_type}" = "${type}"
        return ${?}
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
    local haystack=( "${@}" )

    for elem in "${haystack[@]}"; do
        if [ "${elem}" = "${needle}" ]; then
            return 0
        fi
    done

    return 1
}
