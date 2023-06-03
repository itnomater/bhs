#/**
# CONFIGURATION MANAGEMENT
#
# Easy-to-use configuration management of bash scripts.
# 
# Separate code from configuration. No more global variables in your bash scripts. All configuration are stored in dedicated config files.

## Functions
# You can use the following functions:
#
# - conf_load           - Load the configuration from the file.
# - conf_is             - Does the configuration variable exist?
# - conf_get            - Print the config variable value.
# - conf_set            - Set the value of the configuration variable.
# - conf_add            - Add the new content to the configuration variable.
# - conf_clear          - Remove (clear) the configuration variable.
# - conf_size           - Print number of the variables in specified configuration section.
# - conf_keys           - Print all section keys.

## Configuration file structure
#
# The configuration structure is very simple. There are pairs _key=value_. 
# Variable names can contain only _letters_, _underscores_, _dashes_ or _digits_.
# Variable values can contain any characters. You can use quotes or not.
#
# Multiple white spaces in the configuration variable values will be reduced to one.
# ---
# key1=val1
# key2=val2 with spaces
# key3="val3 with spaces"
# key4='val4 with spaces'
# ---
# 
# Additionally, you can split variables into sections. Sections are placed in square brackets.
# ---
# [section1]
# key1=val1
# ---
# 
# Section name can be followed by _#_.
# ---
# #[section2]
# key1=val1
# ---

## Loading the library
# 
# After loading this library, the function `conf_init` will be called automatically with the proper script name as an argument.
# 
# --- This script is named `foobar.sh`
# . ${SHELL_BOOTSTRAP}
# lib conf      # It will try to load the config file from ${SHELL_CONFDIR}/foobar.conf.ini
# ---
# 
# [WARN] Sometimes the automatic loading of the configuration file may fail, if the proper script uses any other dependencies to the `conf` library.
# 
# --- This script is named `foobar.sh`
# 
# . ${SHELL_BOOTSTRAP}
# lib lang      # Lang library uses conf library. This will load the `conf` library without proper argument.
# lib conf      # This won't load the `conf` library again.
# ---
# 
# So that, the `conf` library should be loaded first. Alternatively, you can call function `conf_load` manually.
# 
# ---
# conf_load '/path/to/configfile'
# ---
# 

## Under the hood
# 
# The configuration variables are split into sections. 
# Each section is a global variable like this: 
# 
# ---
# ___{namespace}_{section_name}      
# ---
# 
# The `namespace` is set when the configuration file is loaded. As default is `CONF`
# 
# ---
# conf_load '/path/to/config'             # Load the data into the default namespace named 'CONF'.
# ---
# 
# You can change it if you have multiple configuration files.
# 
# ---
# conf_load '/path/to/config' foo      # Load the data into the custom namespace named 'foo'.
# conf_load '/path/to/config' bar      # Load the data into the custom namespace named 'bar'.
# conf_load '/path/to/config' doe      # Load the data into the custom namespace named 'doe'.
# ---
# 
# But you probably won't need to change it.
#*/

#/**
# Load configuration from the file.
# 
# @param    String  $1      Path to the configuration file. The name is enough when the configuration file is stored in `${SHELL_CONFDIR}`.
# @param    String  $2      Section name for the variables without specified section. [DEFAULT]
# @param    String  $3      Namespace of the configuration set. [CONF]
# @return   Number          Operation status.
#*/
function conf_load() {
    {
    local fpath=${1} section=${2} prefix=${3}

    # Configuration file not specified.
    if test -z "${fpath}"; then
#        echo "No config file name"
        return 1
    elif ! test -f "${fpath}"; then
        if test -f "${fpath}.conf.ini"; then
            fpath+=".conf.ini"
        elif test -f "${SHELL_CONFDIR}/${fpath}.conf.ini"; then
            fpath="${SHELL_CONFDIR}/${fpath}.conf.ini"
        elif test -f "${SHELL_CONFDIR}/${fpath}"; then
            fpath="${SHELL_CONFDIR}/${fpath}"
        fi
    fi

    if ! test -f "${fpath}"; then
        echo "No config file ${fpath}"
        return 2
    fi

    test -z "${section}" && section=DEFAULT || section=${section^^}
    test -z "${prefix}" && prefix=CONF || prefix=${prefix^^}
    test "${prefix:0:1}" = '@' && prefix=${prefix:1}
             
    declare -i num_lines=$(cat ${fpath} | wc -l)
    declare -i i=1

    local _pattern_section="^#*\\[[^\]+\\]$"
    local _pattern_comment="^[#! ].*$"
    local _pattern_blank_line="^ *$"
    local _pattern_quotes="['\"]"
    local key val line

#    for line in $(cat "${fpath}"); do
    while read line; do
        # A new section.
        if [[ ${line} =~ $_pattern_section ]]; then
#            section=$(echo "${line}" | sed 's@^#*\[@@;s@\].*$@@')
            section=${line//[\#\[\]]}
#            let i++
            continue

        # A Comment (A hash '#' or space at the begging of the line).
        elif [[ ${line} =~ $_pattern_comment ]]; then
#            let i++
            continue

        # A Blank line (only spaces).
        elif [[ ${line} =~ $_pattern_blank_line ]]; then
#            let i++
            continue
        fi

        key=${line%%=*}
        key=$(echo ${key})  # Trim spaces.
        key=${key// /_}     # Conert spaces to underscores.
        val="${line#*=}"
#        val=$(echo ${val} | sed -r "s@^${_pattern_quotes}@@;s@${_pattern_quotes}\$@@")
#        val="${val//[\'\"]}"
        if [[ ${val} =~ ^\ *\'.*\'\ *$ ]]; then
            val=${val#*\'}
            val=${val%\'*}
        elif [[ ${val} =~ ^\ *\".*\"\ *$ ]]; then
            val=${val#*\"}
            val=${val%\"*}
        else
            val=$(echo ${val}) # trim spaces
        fi

        conf_set "${section}:${key}" "${val}" "${prefix}"

    done <<EOF
$(cat ${fpath})
EOF

    return 0
} 2> /dev/null
}

#/**
# Check if the configuration variable exist.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      Prefix of the global environment variable name, see the `conf library description` and `conf_load` function. If you don't need extra prefixes with `conf_load()` function then skip this."
# @return   Number          Operation status.
#*/
function conf_is() {
    { 
    test "${1}" = '' && return 1

    local section key prefix="${2}"
    test "${prefix:0:1}" = '@' && prefix=${prefix:1}

    if [[ $1 =~ ^[_a-zA-Z0-9\.-]+:[_a-zA-Z0-9\.-]+$ ]]; then
        section=${1%%:*}
        section=${section^^}
        section=${section//[- ]/_}
        key=${1##*:}
    else
        section=DEFAULT
        key=${1}
    fi

    test "${prefix}" = '' && prefix=CONF || prefix=${prefix^^}

    declare -p ___${prefix}_${section} 2> /dev/null 1> /dev/null \
        && ( eval 'eval ${___'${prefix}'_'${section}'}'; eval '[ "${'${section}[${key}]'}" != "" ]'; local ret=$?; return ${ret}) \
        || ( return 1 ); } 2> /dev/null
}

#/**
# Print the config variable value.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2+     Extra arguments for config variable. It replaces any occurrence of '%s' with extra variable from the arguments list, 
#                           similarly to the `printf()` function in C."
#                           You can pass many arguments, but the last one denotes a namespace. See the `conf_load()` function for details. 
#                           If you use the namespace with `conf_load()` you need to add '@' character before it. Otherwise just skip it.
# @return   Number          Operation status.
#*/
function conf_get() {
    {
    local var=$1
    local args=()
    local prefix=''
    local msg

    shift
    while test -n "${1}"; do
        args+=("${1}")
        prefix=${1}
        shift
    done

    if [[ ${prefix} =~ ^@[a-zA-Z0-9_]+$ ]]; then
        prefix=${prefix:1}
        test ${#args[@]} -gt 0 && unset 'args[${#args[@]}-1]'
    else
        prefix=CONF
    fi

    local i=0    
    if conf_is "${var}" "${prefix}"; then
        msg=$(_conf_get "${var}" "${prefix}")

        while [[ $msg =~ %s ]]; do
            msg=${msg/\%s/${args[$i]}}
            let i++
        done

        echo ${msg}
    else
        return 1
    fi; } 2> /dev/null
}

#/**
# Set the value of the configuration variable.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      New value of the configuration variable.
# @param    String  $3      Configuration namespace, see the `conf library description` and `conf_load()` function for details. If you don't need multiple configuration sets then skip this."
# @return   Number          Status operacji.
#*/
function conf_set() {
    {
    test -z "${1}" && return 1

    local section= key= val= prefix=${3}
    if [[ $1 =~ ^[_a-zA-Z0-9\.-]+:[_a-zA-Z0-9\.-]+$ ]]; then
        section=${1%%:*}
        section=${section^^}
        section=${section//[- ]/_}
        key=${1##*:}
        val="${2}"
    else
        section=DEFAULT
        key=${1}
        val="${2}"
    fi

    test -z "${prefix}" && prefix=CONF || prefix=${prefix^^}
    test "${prefix:0:1}" = '@' && prefix=${prefix:1}

    declare -p ___${prefix}_${section} 2> /dev/null 1> /dev/null \
        && eval 'eval ${___'${prefix}'_'${section}'}' \
        || declare -Ax ${section}

    if test -z "${val}"; then
        eval unset ${section}[${key}]
    else
        val=$(_conf_line_parse "${val}")
#        echo "**${val}**"
        eval "${section}[${key}]='${val}'"
    fi

#    declare -p "${section}"
#    declare -p ${section} 1> /dev/null 2> /dev/null && export ___${prefix}_${section}="$(declare -p ${section})"; } 2> /dev/null
    
    export ___${prefix}_${section}="$(declare -p ${section} 2> /dev/null)"; } 2> /dev/null

#    eval 'echo ${___'${prefix}'_'${section}'}'
}

#/**
# [DEPRECATED] Add the new content to the configuration variable.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      The new content to add to the configuration variable.
# @param    String  $3      Prefix for the global environment variable name, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
# @return   Number          Operation status.
#*/
function conf_add() {
    {
    local curr=$(conf_get "$1" "$3")
    curr+=$2
    conf_set "$1" "${curr}"; } 2> /dev/null
}

#/**
# Remove (clear) the configuration variable.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      Prefix for the global environment variable name, see the `conf library` and `conf_load`. If you don't need extra prefixes with `conf_load()` function then skip this.
# @return   Number          Operation status.
#*/
function conf_clear() {
    { conf_set "$1" '' "$2"; } 2> /dev/null
}

#/**
# [DEPRECATED] Print number of the variables in specified configuration section.
#
# @param    String  $1      Section name [DEFAULT].
# @param    String  $2      Prefix for the global environment variable name, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
# @return   Number          Operation status.
#*/
function conf_size() {
    {
    local section="${1}"
    local prefix="${2}"

    test -z "${section}" && section=DEFAULT || section=${section^^}
    test -z "${prefix}" && prefix=CONF || prefix=${prefix^^}

    section=${section// /_}

    declare -p ___${prefix}_${section} 2> /dev/null 1> /dev/null \
        && ( eval 'eval ${___'${prefix}'_'${section}'}'; eval 'echo ${#'${section}'[@]}'; return 0 ) \
        || ( echo 0; return 1; ); } 2> /dev/null
}

#/**
# [DEPRECATED] Print all section keys.
#
# @param    String  $1      Section name [DEFAULT].
# @param    String  $2      Prefix for the global environment variable name, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
# @return   Number          Operation status.
#*/
function conf_keys() {
    {
    local section="${1}"
    local prefix="${2}"

    test -z "${section}" && section=DEFAULT || section=${section^^}
    test -z "${prefix}" && prefix=CONF || prefix=${prefix^^}

    section=${section//[- ]/_}
        
    declare -p ___${prefix}_${section} 2> /dev/null 1> /dev/null \
        && ( eval 'eval ${___'${prefix}'_'${section}'}'; eval 'echo ${!'${section}'[@]}'; return 0 ) \
        || ( return 1; ); } 2> /dev/null
}


#/**
# Initialize the library.
#*/
function conf_init() {
    local conf_fpath=${SHELL_CONFDIR}/${1}.conf.ini
    test -f ${conf_fpath} && conf_load ${conf_fpath}

    local conf_fpath=${HOME}/.config/bash/${1}.conf.ini
    test -f ${conf_fpath} && conf_load ${conf_fpath}
    
    return 0
}

#/**
# Print the configuration variable value.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      Prefix for the global environment variable name, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
# @return   Number          Operation status.
#*/
function _conf_get() {
    test "${1}" = '' && return 1

    local section key prefix="${2}"

    if [[ $1 =~ ^[_a-zA-Z0-9\.-]+:[_a-zA-Z0-9\.-]+$ ]]; then
        section=${1%%:*}
        section=${section^^}
        section=${section//[- ]/_}
        key=${1##*:}
    else
        section=DEFAULT
        key=${1}
    fi

    test -z "${prefix}" && prefix=CONF || prefix=${prefix^^}

#    declare -p ___${prefix}_${section} 2> /dev/null 1> /dev/null \
    test -n "___${prefix}_${section}" \
        && ( eval 'eval ${___'${prefix}'_'${section}'}'; eval 'echo -n ${'${section}[${key}]'}'; return 0; ) \
        || return 1
}


#/**
# Parse input data and replace all occurs of the ${variable} using the environment variables.
# 
# @param    String  $*      Input data.
#*/
function _conf_line_parse() {
    local rawdata="$*"
    local var=

#    if [[ ${rawdata} =~ \$\{.+\} ]]; then
        while [[ ${rawdata} =~ \$\{.+\} ]]; do
            var=${rawdata#*\$\{}
            var=${var%%\}*}
#            echo $var
            rawdata="${rawdata/\$\{${var}\}/$(eval 'echo ${'${var}'}')}"
        done
#    fi

#    rawdata="${rawdata//$/\\$}"
    rawdata="${rawdata//\~/\/home\/$(whoami)}"

    echo "${rawdata}"
#    printf '%s' "${rawdata}"
}

