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

wait_for()
{
    if [ ${#} -ne 1 ]; then
        _r9e_print_message "usage: ${FUNCNAME} <hostname>"
        return 1
    fi

    local host="${1}"

    local wait_option='-w'
    if [ "$(uname)" = "Darwin" ]; then
        wait_option='-t'
    fi


    local nl=''
    while ! ping -qc1 "${wait_option}2" "${host}" >/dev/zero 2>&1; do
        # make sure we have a chance to cancel the loop:
        sleep 0.5

        _r9e_print_message -n '.'
        nl='\n'
    done

    _r9e_print_message "${nl}Host %s is now available" "${host}"
}
_r9e_set_completion_function wait_for _hosts
_r9e_set_completion_function wait_for _known_hosts

wait_for_port()
{
    if [ ${#} -ne 2 ]; then
        _r9e_print_message "usage: ${FUNCNAME} <hostname> <port>"
        return 1
    fi

    local host="${1}"
    local port="${2}"

    local timeout_flag='w'
    if nc -h 2>&1 | grep -q -- '-G .*timeout'; then
        timeout_flag='G'
    fi

    local nl=''
    while ! nc "-z${timeout_flag}" 2 "${host}" "${port}" >/dev/zero; do
        # make sure we have a chance to cancel the loop:
        sleep 0.5

        _r9e_print_message -n '.'
        nl='\n'
    done

    _r9e_print_message "${nl}port %s on %s is now available" "${port}" "${host}"
}
_r9e_set_completion_function wait_for_port _hosts
_r9e_set_completion_function wait_for_port _known_hosts

wait_for_ssh()
{
    local host="$(ssh -G "${@}" 2>&- | grep '^hostname ' | sed 's/^hostname //')"
    local port="$(ssh -G "${@}" 2>&- | grep '^port ' | sed 's/^port //')"

    if [ -z "${host}" -o -z "${port}" ]; then
        _r9e_print_message 'unable to determine remote host or port'
        return 1
    fi

    if ssh -G "${@}" 2>&- | grep -q '^proxy\(jump\|command\) '; then
        _r9e_print_message 'ProxyJump or ProxyCommand is not supported'
        return 1
    fi

    wait_for_port "${host}" "${port}"
    ssh "${@}"
}
if [ "${_R9E_SHELL}" = 'zsh' ]; then
    if _r9e_is_shell_function '_ssh'; then
        _wait_for_ssh()
        {
            local service='ssh'
            _ssh
        }

        _r9e_set_completion_function wait_for_ssh _wait_for_ssh
    fi
else
    _r9e_set_completion_function wait_for_ssh _ssh
fi

mkcd()
{
    if [ ${#} -ne 1 ]; then
        _r9e_print_message 'usage: %s <directory>' "${FUNCNAME}"
        return 1
    fi

    local dir="${1}"

    mkdir -p "${dir}" && cd "${dir}"
}

cd_git_root() {
    local currentDir="${PWD}"

    while [ "${currentDir}" != '/' ]; do
        if [ -d "${currentDir}/.git" ]; then
            _r9e_print_message 'changing to %s' "${currentDir}"
            cd "${currentDir}"
            return
        fi

        currentDir="$(dirname "${currentDir}")"
    done
}
