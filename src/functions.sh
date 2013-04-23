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

# overwrite the command not found handles, which query the package manager for
# the package you need to install to for the command you just wanted to
# run. This takes much to long every time you mistyped some command.
#
# Instead this command_not_found_handle strips an initial $ from the command, so
# you could paste code which has the dollar prefixed to each line.
command_not_found_handle()
{
    if [ "${1}" = '$' ]; then
        shift
        "${@}"
    else
        _r9e_print_message "bash: ${1}: command not found"
        return 127
    fi
}

makeh()
{
    (
        make "${@}" 2>&1 1>&3 | grep '\(error\|warning\|Fehler\|Warnung\): \|$'
        return ${PIPESTATUS[0]}
    ) 3>&1 1>&2
}
if _r9e_is_shell_function '_make'; then
    complete -F _make makeh
fi

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
if _r9e_is_shell_function '_known_hosts'; then
    complete -F _known_hosts wait_for
fi
