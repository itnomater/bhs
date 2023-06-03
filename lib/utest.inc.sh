#/**
# Helper function to perform unit tests.
# 
# Example:
#   f
# -- foobar.sh
#
# funfoo() {
#   echo 3
# }
# 
# testfoo() {
#   utest_eq 'Foo' $(funfoo) 3
#   utest_neq 'Foo' $(funfoo) 4 
#   utest_lt 'Foo' $(funfoo) 4
#   utest_le 'Foo' $(funfoo) 4 
#   utest_gt 'Foo' $(funfoo) 2 
#   utest_ge 'Foo' $(funfoo) 3 
#   utest_eq 'Foo' $(funfoo) 31 
# }
#
# utest_add 'TestFoo' testfoo           # Add tests to the queue.

# utest_show_summary                    # Show all information about tests.
# utest_show_failed 
# utest_show_passed

# utest_execute                         # Perform tests.
# 
# --
# 
# This produces the output:
# --------------------------------------
# > 1: TestFoo..
# [ OK ] Foo: 3 == 3
# [ OK ] Foo: 3 != 4
# [ OK ] Foo: 3 < 4
# [ OK ] Foo: 3 <= 4
# [ OK ] Foo: 3 > 2
# [ OK ] Foo: 3 >= 3
# [ !! ] Foo: 3 == 31
# > 1: TestFoo: 6/7
# --------------------------------------
# > Passed: 6/7
# > Failed: 1/7                                                                                                                                         1sec  ✔ 
#*/


# Main functions.

#/**
# Add test function to the queue.
#
# @param    String  $1      Test label.
# @param    String  $2      Function name contains tests.
#*/
utest_add() {
    local label_id=${1}
    local fun=${2}

    ! is_function ${fun} && fun=tests_${fun}
    ! is_function ${fun} && fun=u${fun}
    ! is_function ${fun} && return 1

    declare -p __UTEST_TASKS > /dev/null 2>&1 \
        && eval 'eval ${__UTEST_TASKS}' \
        || declare -Ax __UTEST_TASKS_LOCAL

    __UTEST_TASKS_LOCAL[${label_id// /!}]=${fun}
    
    export __UTEST_TASKS="$(declare -p __UTEST_TASKS_LOCAL 2> /dev/null)";
}

#/**
# Execute all queued tests.
#*/
utest_execute() {
    local num=1
    local use_summary=$(_conf_get 'show_summary' '0')
    local use_details=$(_conf_get 'show_failed' '0'):$(_conf_get 'show_passed' '0')
    local use_legend=$(_conf_get 'show_legend' '0')
    local use_numbers=$(_conf_get 'show_global_numbers' '0')
    local label= fun= prefix=

    eval 'eval ${__UTEST_TASKS}'

    test "${use_details}" != '0:0' -a "${use_legend}" != '0' && line && echo "[ status ] label: returns operator expected"

    for label in ${!__UTEST_TASKS_LOCAL[@]}; do
        fun=${__UTEST_TASKS_LOCAL[$label]}
        label=${label//!/ }

        _utest_start_tests

#        local output="$(${fun})"

        test "${use_numbers}" != '0' && prefix="${num}: " || prefix=
        test "${use_details}" != '0:0' && line && header -m "${prefix}${label}.." 

        ${fun}

        if test "${use_summary}" = '1'; then
            test "$(utest_get_num_failed)" = '0' \
                && success -m "${prefix}${label}: $(utest_get_num_passed)/$(utest_get_num_total)" \
                || error -m "${prefix}${label}: $(utest_get_num_passed)/$(utest_get_num_total)"
        fi

        let num++
    done

    test "${use_summary}" = '1' && _utest_summary
    test "$(utest_get_num_FAILED)" = '0' && return 0 || return 1
}


# Checking actions.

## Booleans

#/**
# Return the truth if the previous function returns true.
# 
# @param    String          $1      The label.
# @param    String/Number   $2      The argument.
#*/
utest_true() {
    local status=$?
    local label="${1}"
#    local argA="${2%%\\n*}"
    shift 
    shift 
    test -n "${1}" && label+="($*)"

    test ${status} -eq 0 \
        && _utest_pass "${label}" "true == true" \
        || _utest_fail "${label}" "false == true"
}

#/**
# Return the truth if the previous function returns false.
# 
# @param    String          $1      The label.
# @param    String/Number   $2      The argument.
#*/
utest_false() {
    local status=$?
    local label="${1}"
#    local argA="${2%%\\n*}"
    shift 
    shift 
    test -n "${1}" && label+="($*)"
    
    test ${status} -ne 0 \
        && _utest_pass "${label}" "false == false" \
        || _utest_fail "${label}" "true == false"
}


## Numbers

#/**
# Return the truth if two arguments are equal.
# 
# @param    String          $1      The label.
# @param    String/Number   $2      The first argument.
# @param    String/Number   $3      The second argument.
#*/
utest_eq() {
    local label="${1}"
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="${argA} == ${argB}"

    test "${argA}" = "${argB}" \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}

#/**
# Return the truth if two arguments are different.
# 
# @param    String          $1      The label.
# @param    String/Number   $2      The first argument.
# @param    String/Number   $3      The second argument.
#*/
utest_neq() {
    local label=${1}
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="${argA} != ${argB}"

    test "${argA}" != "${argB}" \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}

#/**
# Return the truth if the first argument is less than two.
# 
# @param    String  $1      The label.
# @param    Number  $2      The first argument.
# @param    Number  $3      The second argument.
#*/
utest_lt() {
    local label=${1}
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="${argA} < ${argB}"

    test "${argA}" -lt "${argB}" \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}

#/**
# Return the truth if the first argument is less or equal to two.
# 
# @param    String  $1      The label.
# @param    Number  $2      The first argument.
# @param    Number  $3      The second argument.
#*/
utest_le() {
    local label=${1}
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="${argA} <= ${argB}"

    test "${argA}" -le "${argB}" \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}

#/**
# Return the truth if the first argument is greater than two.
# 
# @param    String  $1      The label.
# @param    Number  $2      The first argument.
# @param    Number  $3      The second argument.
#*/
utest_gt() {
    local label=${1}
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="${argA} > ${argB}"

    test "${argA}" -gt "${argB}" \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}

#/**
# Return the truth if the first argument is greater than or equal to two.
# 
# @param    String  $1      The label.
# @param    Number  $2      The first argument.
# @param    Number  $3      The second argument.
#*/
utest_ge() {
    local label=${1}
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="${argA} >= ${argB}"

    test "${argA}" -ge "${argB}" \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}


## Strings

#/**
# Return the truth when two strings are the same.
# 
# @param    String  $1      The label.
# @param    Number  $2      The first argument.
# @param    Number  $3      The second argument.
#*/
utest_cmp() {
    local label=${1}
    local argA="${2}"
    local argB="${3}"
    local argA="${2/\\n/ }"
    local argB="${3/\\n/ }"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="'${argA}' == '${argB}'"

    test "${argA}" = "${argB}" \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}

#/**
# Return the truth when two strings are not the same.
# 
# @param    String  $1      The label.
# @param    Number  $2      The first argument.
# @param    Number  $3      The second argument.
#*/
utest_ncmp() {
    local label=${1}
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="'${argA}' != '${argB}'"

    test "${argA}" != "${argB}" \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}


## Regexp

#/**
# Return the truth if the first argument match to the pattern in the second one.
# 
# @param    String  $1      The label.
# @param    Number  $2      The first argument.
# @param    Number  $3      The second argument.
#*/
utest_regexp() {
    local label=${1}
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="'${argA}' =~ '${argB}'"

    [[ ${argA} =~ ${argB} ]] \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}

#/**
# Return the truth if the first argument not match to the pattern in the second one.
# 
# @param    String  $1      The label.
# @param    Number  $2      The first argument.
# @param    Number  $3      The second argument.
#*/
utest_nregexp() {
    local label=${1}
    local argA="${2%%\\n*}"
    local argB="${3%%\\n*}"
    shift 3
    test -n "${1}" && label+="($*)"
    local test_expr="'${argA}' !~ '${argB}'"

    ! [[ ${argA} =~ ${argB} ]] \
        && _utest_pass "${label}" "${test_expr}" \
        || _utest_fail "${label}" "${test_expr}"
}


# Get information

#/**
# Get the passed tests number in the current group.
#*/
utest_get_num_passed() {
    _conf_get 'num_passed' '0'
}

#/**
# Get the failed tests number in the current group.
#*/
utest_get_num_failed() {
    _conf_get 'num_failed' '0'
}

#/**
# Get the all tests number in the current group.
#*/
utest_get_num_total() {
    _conf_get 'num_total' '0'
}

#/**
# Get the total passed tests number.
#*/
utest_get_num_PASSED() {
    _conf_get 'num_PASSED' '0'
}

#/**
# Get the total failed tests number.
#*/
utest_get_num_FAILED() {
    _conf_get 'num_FAILED' '0'
}

#/**
# Get the all tests number.
#*/
utest_get_num_TOTAL() {
    _conf_get 'num_TOTAL' '0'
}


# Configuration

#/**
# Show details of the failed tests.
#*/
utest_show_failed() {
    _conf_set 'show_failed' '1'
}

#/**
# Hide details of the failed tests.
#*/
utest_hide_failed() {
    _conf_set 'show_failed' '0'
}


#/**
# Show details of the passed tests.
#*/
utest_show_passed() {
    _conf_set 'show_passed' '1'
}

#/**
# Hide details of the passed tests.
#*/
utest_hide_passed() {
    _conf_set 'show_passed' '0'
}


#/**
# Show tests summary.
#*/
utest_show_summary() {
    _conf_set 'show_summary' '1'
}

#/**
# Hide tests summary.
#*/
utest_hide_summary() {
    _conf_set 'show_summary' '0'
}


#/**
# Show legend.
#*/
utest_show_legend() {
    _conf_set 'show_legend' '1'
}

#/**
# Hide legend.
#*/
utest_hide_legend() {
    _conf_set 'show_legend' '0'
}


#/**
# Show numbers in the test summaries.
#*/
utest_show_global_numbers() {
    _conf_set 'show_global_numbers' '1'
}

#/**
# Hide numbers in the test summaries.
#*/
utest_hide_global_numbers() {
    _conf_set 'show_global_numbers' '0'
}


#/**
# Show numbers for each unit tests.
#*/
utest_show_local_numbers() {
    _conf_set 'show_local_numbers' '1'
}

#/**
# Hide numbers for each unit tests.
#*/
utest_hide_local_numbers() {
    _conf_set 'show_local_numbers' '0'
}


utest_init() {
    lib echo3
    return 0
}


# Private helpers.

_conf_set() {
    local key=${1}
    local value=${2}

    declare -p __UTEST_CONF > /dev/null 2>&1 \
        && eval 'eval ${__UTEST_CONF}' \
        || declare -Ax __UTEST_CONF_LOCAL

    if test -z "${value}"; then
        unset __UTEST_CONF_LOCAL[$key]
    else
        __UTEST_CONF_LOCAL[$key]=${value}
    fi
    
    export __UTEST_CONF="$(declare -p __UTEST_CONF_LOCAL 2> /dev/null)";
}

_conf_inc() {
    local key=${1}
    local value=$(_conf_get ${key} '0')
    
    test -z "${value}" && value=1 || let value++
    
    _conf_set "${key}" "${value}"
}

_conf_get() {
    local key=${1}
    local def=${2}

    declare -p __UTEST_CONF > /dev/null 2>&1 && eval 'eval ${__UTEST_CONF}'

    test -n "${__UTEST_CONF_LOCAL[$key]}" && echo ${__UTEST_CONF_LOCAL[$key]} || echo $def
}

_conf_clear() {
    local key=${1}

    unset _UTEST_CONF[$key]
}


#/**
# Increment the number of passed tests.
#*/
_utest_pass() {
    _conf_inc 'num_passed'
    _conf_inc 'num_total'
    _conf_inc 'num_PASSED'
    _conf_inc 'num_TOTAL'
    
    local is_show=$(_conf_get 'show_passed' '0')
    local use_numbers=$(_conf_get 'show_local_numbers' '0')
    local prefix=
    
    test "${use_numbers}" != '0' && prefix="$(utest_get_num_total): " || prefix=
    test "${is_show}" != '0' && success -m "${prefix}${1}: ${2}" -t 'OK'
    return 0
}

#/**
# Increment the number of failed tests.
#*/
_utest_fail() {
    _conf_inc 'num_failed'
    _conf_inc 'num_total'
    _conf_inc 'num_FAILED'
    _conf_inc 'num_TOTAL'

    local is_show=$(_conf_get 'show_failed' '0')
    local use_numbers=$(_conf_get 'show_local_numbers' '0')
    local prefix=

    test "${use_numbers}" != '0' && prefix="$(utest_get_num_total): " || prefix=
    test "${is_show}" != '0' && error -m "${prefix}${1}: ${2}" -t '!!'
    return 1
}

#/**
# Show the tests summary.
#*/
_utest_summary() {
    local num_passed=$(utest_get_num_PASSED)
    local num_failed=$(utest_get_num_FAILED)
    local num_total=$(utest_get_num_TOTAL)

    line
    if test ${num_failed} -eq 0; then
        success -m "All ${num_total} tests passed" 
    else 
        success -m "Passed: ${num_passed}/${num_total}"
        error -m "Failed: ${num_failed}/${num_total}"
    fi
}

_utest_start_tests() {
    _conf_set 'num_failed' '0'
    _conf_set 'num_passed' '0'
    _conf_set 'num_total' '0'
}

