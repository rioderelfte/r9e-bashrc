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

_r9e_prompt_command()
{
    local return_code="${1}"

    # Store the current history to disk.
    history -a

    _r9e_export_prompt "${return_code}"
}

_r9e_print_prompt_command()
{
    cat <<"EOF"
_R9E_TMP_RETURN_CODE="${?}";
type -t _r9e_prompt_command >/dev/zero && _r9e_prompt_command "${_R9E_TMP_RETURN_CODE}";
unset _R9E_TMP_RETURN_CODE;
EOF
}

_r9e_install_prompt_command()
{
    _r9e_profiling_function_start

    # TODO: Preserve the old prompt command. This can not simply be done by
    # appending our prompt command to PROMPT_COMMAND, since than our prompt
    # command would end up in the variable multiple times when the bashrc alias
    # is used.
    PROMPT_COMMAND="$(_r9e_print_prompt_command)"

    _r9e_profiling_function_end
}
