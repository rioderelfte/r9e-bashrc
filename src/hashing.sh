################################################################################
#                                                                              #
# Copyright (c) 2011 - 2013 Florian Sowade <f.sowade@r9e.de>                   #
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

_R9E_DJB_HASH_INT_MAX="$(( 2 ** 32 - 1 ))"

# _r9e_djb_initial_hash
#
# Echo the initial value of the Bernstein hashing algorithm, i.e. the hash of
# the empty string.
_r9e_djb_initial_hash()
{
    echo '5381'
}

# _r9e_djb_iterate_hash
#   currentHash
#   currentCode
#
# Add the current code (has to be a decimal number) to the calculated hash given
# has currentHash, which has to be decimal, too.
#
# The resulting has is echoed as decimal number.
_r9e_djb_iterate_hash()
{
    local hash=${1}
    local cur_code=${2}

    echo $(( ( ( ${hash} * 33 ) ^ ${cur_code} ) & ${_R9E_DJB_HASH_INT_MAX} ))
}

# _r9e_djb_string_hash
#    text
#
# Calculate the Bernstein hash of the given text and echo it as decimal number.
_r9e_djb_string_hash()
{
    local text="${*}"

    local hash="$(_r9e_djb_initial_hash)"

    local i
    for i in $(seq 0 $(( ${#text} - 1 ))); do
        local cur_char="${text:${i}:1}"
        local cur_code="$(printf '%d' "'${cur_char}")"

        hash="$(_r9e_djb_iterate_hash "${hash}" "${cur_code}")"
    done

    echo "${hash}"
}
