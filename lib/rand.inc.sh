#/**
# Several useful functions to calculating probabilities and generating random numbers.
#
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

#/**
# Get the truth with a certain probability.
# 
# For example:
#   If you call this function 1000 times with an argument of 10 then approximately 100 calls will return true.
#   If you call this function 1000 times with an argument of 90 then approximately 900 calls will return true.
# 
# @param    $1      Probablity value in range (0-100). As default is 50.
# @return           Operation status.
#*/
rand_probe() {
    local p=${1:-50}

    test -z "${p}" -o "${p}" = '0' && return 1
    test "${p}" = '100' && return 0

    [[ ${p} =~ ^[1-9][0-9]*$ ]] \
        && test $(( (((${RANDOM} * 99999) % 1024) & 127) )) -le $(( 127 * ${p} / 100)) \
        || return 1
}

#/**
# Generate a random integer number from a certain range.
#
# @param    $1      Maximum range value [100].
# @param    $2      Minimum range value [0].
#*/
rand_integer() {
    local max=$(_rand_intval ${1:-100})
    local min=$(_rand_intval ${2:-0})

    if test $((max - min)) -le 0; then
        printf 0
    else
        printf '%i' $(( min + (${RANDOM} % (1 + (max - min))) ));
    fi
}

#/**
# Generate a random real number.
#
# @param   $1       Number digits of integer part [4]. The maximum value is 18.
# @param   $2       Number digits of decimal part [2]. The maximum value is 18.
# @param   $3       Probability of use negative value [0].
#*/
rand_real() {
    local base_length=$(_rand_intval ${1:-4})
    test "${base_length}" = '.' && base_length=4

    local real_length=$(_rand_intval ${2:-2})
    test "${real_length}" = '.' && real_length=2

    rand_probe $(_rand_intval ${3:-0}) && local sign='-' || local sign=''
    test ${base_length} -gt 18 && base_length=18
    test ${real_length} -gt 18 && real_length=18

    local digits="${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}"
    local digits2="${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}"

    test ${#digits} -lt ${base_length} && digits+="${digits}${digits}${digits}"
    test ${#digits2} -lt ${real_length} && digits2+="${digits2}${digits2}${digits2}"
#    test ${digits:0:1} = '0' && digits=$(echo ${digits} | sed 's@^0+@@')
#    test ${digits2:0:1} = '0' && digits2=$(echo ${digits2} | sed 's@^0+@@')

    printf '%s%i.%i' "${sign}" "${digits:0:${base_length}}" "${digits2:0:${real_length}}"
}

#/**
# Generate random digits.
#
# @param   $1       Number of digits [11]. Maximium value is 100.
#*/
rand_digits() {
    local length=$(_rand_intval ${1:-11})

    local digits="${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}"
    
    test ${length} -gt ${#digits} && digits+="${digits}${digits}${digits}"
    test ${length} -gt ${#digits} && length=${#digits}
    
    printf ${digits:0:${length}}
}

#/**
# Convert a value to integer.
#
# @param    $1      Source value.
#*/
_rand_intval() {
    local arg=${1}
    [[ ${arg} =~ ^-?[0-9]+$ ]] && printf '%i' "${arg}" || printf 0
}

