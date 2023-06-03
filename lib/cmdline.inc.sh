#/**
# COMMAND LINE.
#
# Manage the command line arguments and options.
#
# There are 3 functions mainly using functions to manage command line options:
# 
# - opt_is      - Check if the option is set.
# - opt_get     - Get the option variable.
# - opt_size    - Get the number of all options.
# 
# For numerical options you can use:
# 
# - opt_gt      - Check if the option is set and its value is greater than..
# - opt_ge      - Check if the option is set and its value is greater than or equal to..
# - opt_lt      - Check if the option is set and its value is less than..
# - opt_le      - Check if the option is set and its value is less than or equal to..
# 
# For manage the command line arguments you have 3 functions:
# 
# - arg_is      - Check if the argument with given index exists.
# - arg_get     - Get the value of the argument with given index.
# - arg_size    - Get the number of all arguments.
# 
# All functions are using global variables:
# 
# - _OPTS
# - _ARGS
# 
# These variables are declared in `core` library. So remember not to use these variables directly!
#*/

#/**
# Check if the option in command line exists.
#
# In command line the options must be proceeded by `-` (short name) or `--` (long name). When you check the option don't use `-`."
# 
# Example:
#   $ foobar.sh -a --foo
#
# To check the option in script call:
#   opt_is 'a' or opt_is 'foo' # opt_is '-a' or opt_is '--foo' doesn't work.
# 
# @param    String  $1      Option to check. If empty it returns true (but only if any option is set).
# @return   Number          Operation status.
#*/
opt_is() {
    { test "${1}" != '' && test "${_OPTS[$1]}" != '' \
        || test "${1}" = '' && test ${#_OPTS[@]} -ne 0; } 2> /dev/null 
}

#/**
# Print the option value.
#
# See the `opt_is()` function for more information.
# 
# You can pass a blank option value:
# ./foo.sh -a
#
# Then the option value is equal 1.
#
# When you pass a blank option value many times:
# ./foo.sh -a -a -a -a 
# 
# then the option value is set to the number of repetitions.
#
# @param    String  $1      Option name.
# @return   Number          Operation status.
#*/
opt_get() {
    {
    test "${1}" == '' && return 1

    test "${_OPTS[$1]}" != '' \
        && ( echo ${_OPTS[$1]}; return 0; ) \
        || return 1

    return $?; } 2> /dev/null
}

#/**
# Check if the command line option exists and its value is greater than $2.
#
# See the `opt_is()` function for more information.
# 
# @param    String  $1      Option to check.
# @param    Number  $2      Value to compare.
# @return   Number          Operation status.
#*/
opt_gt() {
    {
    test "${1}" != '' \
        && [[ ${_OPTS[$1]} =~ ^[0-9]+$ ]] \
        && [[ ${2} =~ ^[0-9]+$ ]] \
        && test ${_OPTS[$1]} -gt ${2}; } 2> /dev/null
}

#/**
# Check if the command line option exists and its value is greater than or equal to $2.
#
# See the `opt_is()` function for more information.
# 
# @param    String  $1      Option to check.
# @param    Number  $2      Value to compare.
# @return   Number          Operation status.
#*/
opt_ge() {
    {
    test "${1}" != '' \
        && [[ ${_OPTS[$1]} =~ ^[0-9]+$ ]] \
        && [[ ${2} =~ ^[0-9]+$ ]] \
        && test ${_OPTS[$1]} -ge ${2} ; } 2> /dev/null
}

#/**
# Check if the command line option exists and its value is less than $2.
#
# See the `opt_is()` function for more information.
#
# @param    String  $1      Option to check.
# @param    Number  $2      Value to compare.
# @return   Number          Operation status.
#*/
opt_lt() {
    {
    test "${1}" != '' \
        && [[ ${_OPTS[$1]} =~ ^[0-9]+$ ]] \
        && [[ ${2} =~ ^[0-9]+$ ]] \
        && test ${_OPTS[$1]} -lt ${2} ; } 2> /dev/null
}

#/**
# Check if the command line option exists and its value is lower than or equal to $2.
#
# See the opt_is function for more information.
#
# @param    String  $1      Option to check.
# @param    Number  $2      Value to compare.
# @return   Number          Operation status.
#*/
opt_le() {
    {
    test "${1}" != '' \
        && [[ ${_OPTS[$1]} =~ ^[0-9]+$ ]] \
        && [[ ${2} =~ ^[0-9]+$ ]] \
        && test ${_OPTS[$1]} -le ${2} ; } 2> /dev/null
}

#/**
# Print the number of command line options.
# 
# @return   Number          Operation status.
#*/
opt_size() {
    {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        test ${#_OPTS[@]} -eq $1 && return 0 || return 1
    else
        echo ${#_OPTS[@]}
        test ${#_OPTS[@]} -ne 0 && return 0 || return 1
    fi; } 2> /dev/null
}


#/**
# Print the number of command line arguments.
# 
# @return   Number          Operation status.
#*/
arg_size() {
    {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        test ${#_ARGS[@]} -eq $1 && return 0 || return 1
    else
        echo ${#_ARGS[@]}
        test ${#_ARGS[@]} -ne 0 && return 0 || return 1
    fi; } 2> /dev/null
}

#/**
# Print the command line argument by its index.
# 
# @param    Number  $1      Index of the command line argument to print.
# @return   Number          Operation status.
#*/
arg_get() {
    {
    local num=${1}

    [[ ${num} =~ ^[0-9]+$ ]] || return 1
    test ${num} -ge ${#_ARGS[@]} && return 2

    echo ${_ARGS[$1]}
    return 0; } 2> /dev/null
}

# [DEPRECATED]
arg_list() {
    {
        local arg_num=0
        local arg_max=$(arg_size)
        while test ${arg_num} -lt ${arg_max}; do
            echo -n "$(arg_get ${arg_num}) "
            let arg_num++
        done;
    } 2> /dev/null
}

#/**
# Parse command line. The convenient version of getopt.
#
# The function starts automatically after loading the core library. Its is unset after call.
#   parseline "$@"
# 
# Parse variable are stored in global variables:
#   _OPTS - Assoc array of options.
#   _ARGS - Array of arguements.
# 
# Examples of use:
#   _parseline --key0=value0 \                  - option: key0      value: value0
#              --key1="value with spaces" \     - option: key1      value: value with spaces
#              --key2 value2 \                  - option: key2      value: value2
#              --key3 "value with spaces" \     - option: key3      value: value with spaces
#              -f \                             - option: f         value: 1
#              -b \                             - option: b         value: 1
#              -w -w -w \                       - option: w         value: 3
#              -xxvdvx \                        - options: xvd      values: 3, 2, 1
#              arg1 \                           - argument 1: arg1
#              "arg2 with spaces"               - argument 2: arg2 with spaces
# 
# Number of arguments / options is limited by shell limits.
# The function is unset after use.
#*/
_parseline() {
    local optname
    local optvalue
    local opts
    local i

    while [ "${1}" ]; do

        #   --key=value
        #   --key="value with spaces"
        if [[ ${1} =~ ^--[a-zA-Z0-9]+=.+$ ]]; then
            optname=${1%%=*}
            optname=${optname:2}

            optvalue=${1##*=}

            _OPTS[${optname}]="${optvalue}"
            optname=
            optvalue=


        #   --key
        elif [[ ${1} =~ ^--[a-zA-Z0-9]+$ ]]; then
            optname=${1:2}

            _OPTS[${optname}]='1'


        #   -<opts_list>
        elif [[ ${1} =~ ^-[a-zA-Z0-9]+$ ]]; then
            optname=
            opts=${1:1}
            i=$((${#opts} - 1))

            while [ $i -ge 0 ]; do
                optname=${opts:$i:1}

                if [ -z ${_OPTS[${optname}]} ]; then
                    _OPTS[${optname}]=1
                elif [[ ${_OPTS[${optname}]} =~ ^[0-9]+$ ]]; then
                    _OPTS[${optname}]=$((${_OPTS[${optname}]} + 1))
                fi

                i=$((i - 1))
            done
        elif [ "${optname}" != '' ]; then
            _OPTS[${optname}]="${1}"
            optname=
        else
            _ARGS+=("${1}")
        fi

        shift 1
    done
}

cmdline_init() {
    # Parse the command line arguments and unset the _parseline() function.
    _parseline "$@"; unset _parseline
}

