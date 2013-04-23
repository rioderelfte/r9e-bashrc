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

_R9E_BASHRC_UPDATER_LAST_RUN_FILE="${_R9E_BASHRC_BASE_PATH}/.last-r9e-bashrc-update-run"

if [ -z "${_R9E_BASHRC_UPDATER_MAX_DIFFERENCE}" ]; then
    _R9E_BASHRC_UPDATER_MAX_DIFFERENCE="$(( 7 * 24 * 3600 ))"
fi

_r9e_bashrc_updater_check_last_run()
{
    _r9e_profiling_function_start

    if [ ! -f "${_R9E_BASHRC_UPDATER_LAST_RUN_FILE}" ]; then
        _r9e_print_message 'The r9e bashrc updater has never been run'
    else
        local last_updater_run="$(_r9e_file_modification_timestamp "${_R9E_BASHRC_UPDATER_LAST_RUN_FILE}")"
        local now="$(_r9e_current_timestamp)"

        local difference="$(( ${now} - ${last_updater_run} ))"

        if [ "${difference}" -lt "${_R9E_BASHRC_UPDATER_MAX_DIFFERENCE}" ]; then
            return
        fi

        _r9e_print_message 'The r9e bashrc updater has not been run since %s' "$(_r9e_timestamp_to_date "${last_updater_run}")"
    fi

    _r9e_print_message 'Run r9e_bashrc_updater to check for updates now'

    _r9e_profiling_function_end
}

r9e_bashrc_updater()
{
    if ! _r9e_run_git_in_directory "${_R9E_BASHRC_BASE_PATH}" pull; then
        _r9e_print_message 'Error while updating the r9e-bashrc git repository (%s)' "${_R9E_BASHRC_BASE_PATH}"
        return 1
    fi

    if [ ! -e "${_R9E_BASHRC_UPDATER_LAST_RUN_FILE}" ]; then
        cat > "${_R9E_BASHRC_UPDATER_LAST_RUN_FILE}" <<EOF
This file is used by the automatic r9e-bashrc updater. Please do not touch it.
EOF
    else
        touch "${_R9E_BASHRC_UPDATER_LAST_RUN_FILE}"
    fi

    bashrc

    _r9e_print_message 'Successfully updated r9e bashrc'
}
