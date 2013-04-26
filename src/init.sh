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

# Check if this is a bash.
if [ -z "${BASH_VERSION}" ]; then
    return
fi

# Check if this is an interactive shell.
if [[ "${-}" != *i* ]] ; then
	return
fi

if "${_R9E_BASHRC_SKIP:-false}"; then
    return
fi

_r9e_path_is_absolute()
{
    local path="${1}"

    [[ "${path}" = /* ]]
}

# a portable GNU readlink -e
_r9e_readlink_e()
{
    local file="${1}"

    if ! _r9e_path_is_absolute "${file}"; then
        file="${PWD}/${file}"
    fi

    while [ -h "${file}" ]; do
        local new_file="$(readlink "${file}")"

        if _r9e_path_is_absolute "${new_file}"; then
            file="${new_file}"
        else
            file="$(cd -P "$(dirname "${file}")" && pwd)/${new_file}"
        fi
    done

    echo "${file}"
}

_r9e_print_message()
{
    local print_newline=true
    if [ "${1}" = '-n' ]; then
        shift
        print_newline=false
    fi

    printf "${@}" >&2

    if ${print_newline}; then
        echo >&2
    fi
}

# empty profiling functions used when profiling is disabled
_r9e_disable_profiling()
{
    _r9e_profiling_timer_start() { :; }
    _r9e_profiling_timer_end() { :; }
    _r9e_profiling_function_start() { :; }
    _r9e_profiling_function_end() { :; }

    _R9E_BASHRC_ENABLE_PROFILING=false
}

_r9e_enable_profiling()
{
    # I can't use _r9e_include because it depends on the profiling.
    source "${_R9E_BASHRC_SRC_PATH}/profiling.sh"

    _R9E_BASHRC_ENABLE_PROFILING=true
}

_r9e_include()
{
    local file="${1}"

    _r9e_profiling_timer_start "${file}.sh"
    source "${_R9E_BASHRC_SRC_PATH}/${file}.sh"
    _r9e_profiling_timer_end
}

_r9e_bashrc_main()
{
    local init_file="$(_r9e_readlink_e "${BASH_SOURCE[0]}")"
    _R9E_BASHRC_SRC_PATH="$(dirname "${init_file}")"
    _R9E_BASHRC_BASE_PATH="$(dirname "${_R9E_BASHRC_SRC_PATH}")"
    unset init_file

    if ${_R9E_BASHRC_ENABLE_PROFILING:-false}; then
        _r9e_enable_profiling
    else
        _r9e_disable_profiling
    fi

    _r9e_profiling_function_start

    _r9e_include 'helpers'

    # Don't source r9e-bashrc twice if there is a per user and system wide
    # version.
    _R9E_BASHRC_SKIP=true

    # source some system config files
    # Fedora:
    _r9e_source '/etc/bashrc'
    # Debian/Ubuntu:
    # check if bash_completion has already been sourced
    if [ -z "${BASH_COMPLETION_COMPAT_DIR}" ]; then
        _r9e_source '/usr/share/bash-completion/bash_completion' '/etc/bash_completion'
    fi

    unset _R9E_BASHRC_SKIP

    # some helper functions
    _r9e_include 'hashing'
    _r9e_include 'colorize'
    _r9e_include 'prompt'
    _r9e_include 'prompt-functions'
    _r9e_include 'path'
    _r9e_include 'options'
    _r9e_include 'alias'
    _r9e_include 'functions'
    _r9e_include 'prompt-command'

    # user config
    _r9e_source '/etc/r9e-bashrc.sh'
    _r9e_source_directory '/etc/r9e-bashrc.d'
    _r9e_source "${HOME}/.bashrc.local"
    _r9e_source "${HOME}/.bash_aliases"
    _r9e_source_directory "${HOME}/.bashrc.d"

    _r9e_export_prepared_prompts
    _r9e_install_prompt_command

    if ${_R9E_BASHRC_ENABLE_UPDATER:-false}; then
        _r9e_include 'updater'

        _r9e_bashrc_updater_check_last_run
    fi

    _r9e_profiling_function_end
}

_r9e_bashrc_main