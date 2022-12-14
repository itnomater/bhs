#/**
# A few functions to calculating probability, generating a random numbers.
#*/

#/**
# Get truth with specified probility.
#
# @param    $1      Probablity in range (0-100) returns of true value [50].
# @return           Operation status.
#*/
math_probe() {
    local p=${1:-50}

    test -z "${p}" -o "${p}" = '0' && return 1
    test "${p}" = '100' && return 0

    [[ ${p} =~ ^[1-9][0-9]*$ ]] \
        && test $(( (((${RANDOM} * 99999) % 1024) & 127) )) -le $(( 127 * ${p} / 100)) \
        || return 1
}

#/**
# Check (convert) value to integer.
#
# @param    $1      Checked value.
#*/
math_intval() {
    local arg=${1}

    [[ ${arg} =~ ^-?[0-9]+$ ]] && printf ${arg} || printf 0
}

#/**
# Generate random integer number from range.
#
# @param    $1      Maximum range value [100].
# @param    $2      Minimum range value [1].
#*/
math_random() {
    local max=$(math_intval ${1:-100})
    local min=$(math_intval ${2:-1})

    if test $((max - min)) -le 0; then
        printf 0
    else
        printf $(( min + (${RANDOM} % (max - min)) ));
    fi
}

#/**
# Generate random real number.
#
# @param   $1       Number digits of integer part [4].
# @param   $2       Number digits of decimal part [2].
# @param   $3       Probability of use negative value.
#*/
math_random_real() {
    local base_length=$(math_intval ${1:-4})
    local real_length=$(math_intval ${2:-2})
    math_probe $(math_intval ${3:-0}) && local sign='-' || local sign=''
    test ${base_length} -gt 10 && base_length=10
    test ${real_length} -gt 10 && real_length=10

    local digits="${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}"
    local digits2="${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}"

    printf '%s%i.%i' "${sign}" "${digits:0:${base_length}}" "${digits2:0:${real_length}}"
}

#/**
# Generate random digits.
#
# @param   $1       Length [11].
#*/
math_random_digits() {
    local length=$(math_intval ${1:-11})

    local digits="${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}"
    
    test ${length} -gt ${#digits} && digits+="${digits}"
    test ${length} -gt ${#digits} && length=${#digits}
    
    printf ${digits:0:${length}}
}


