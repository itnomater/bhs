#/**
# CONFIGURATION MANAGEMENT.
#
# The interface to manage the script configuration.
# 
# You can store the script configuration instead the proper script.
#
# [WARN] 
# After loaded this module the function `conf_init` will be call automatically with the proper script name as an argument.
# Example:
#
# The proper script is:
# foobar.sh
#
# When you call inside it (load this module):
# . ${SHELL_BOOTSTRAP}
# lib conf
#
# It tries to load the config file from:
# ${SHELL_CONFDIR}/foobar.conf.ini
#
# [WARN]
# Sometimes the automatic loading of the configuration file may fail. If the proper script uses any other dependencies to the `conf` module.
# Example:
#
# The proper script is:
# foobar.sh
#
# . ${SHELL_BOOTSTRAP}
# lib lang      # this will load the `conf` module without proper argument.
# lib conf      # this won't load the `conf` module again.
#
# So that, the `conf` module should be loaded at first. Optional, you can call manually:
# conf_load 'foobar'
#
# 
# The configuration variables are split into sections. 
# Each section is a global environment varible like: 
#   ___<prefix>_<section_name>      
#
# There are completely transparent for the user.
# 
# To set a configuration variable use this:
#   conf_set <section_name> <key> <value>
# 
# You can read the configuration variables from text file using:
#   conf_load <section_name>:<config_file_path>
#   conf_load <section_name> <config_file_path>
#   conf_load <config_file_path>
#
# The file structure:
#       key1=val1
#       key2=val2 with spaces
#       key3="val3 with spaces"
#       key3='val3 with spaces'
#       ..
# 
# In the configuration file you can declare a sections (like INI files). 
#   [section1]
#   key1=val1
#   ..
# 
# Section name can be followed by '#':
#   #[section2]
#   key1=val1
#   ..
#
# Read configuration variables:
#   conf_get [<section_name>:]<key>
#
# Read number of the section variables:
#   conf_size [<section_name>]
# 
# Get all section names:
#   conf_keys [<section_name>]
# 
# [WARN] 
# Multiple white spaces in the configuration variable values will be reduced to one.
#*/

#/**
# Load the configuration from the file.
#
# @param    String  $1      Path to the configuration file.
# @param    String  $2      Section name for the variables without specified section. [DEFAULT]
# @param    String  $3      Prefix of the global environment variable name. [CONF]
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
# Print the config variable value.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2+     Extra arguments for config variable. It replaces any occur of '%s' to extra variable list. It is similar to the printf() function in C.
#                           Last argument means extra prefix, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
# @return   Number          Operation status.
#*/
function conf_get() {
    {
    local var=$1
    local args=()
    local prefix=''
    local msg

    shift
    while test "${1}" != ''; do
        args+=("${1}")
        prefix=${1}
        shift
    done

    if [[ ${prefix} =~ [a-z] ]]; then
        prefix=CONF
    elif test ${#args[@]} -gt 0; then
        unset 'args[${#args[@]}-1]'
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
# Print the configuration variable value.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      Prefix for the global environment variable name, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
# @return   Number          Operation status.
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
# Is the configuration variable exist?
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      Prefix for the global environment variable name, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
# @return   Number          Operation status.
#*/
function conf_is() {
    { 
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

    [ "${prefix}" = '' ] && prefix=CONF || prefix=${prefix^^}

    declare -p ___${prefix}_${section} 2> /dev/null 1> /dev/null \
        && ( eval 'eval ${___'${prefix}'_'${section}'}'; eval '[ "${'${section}[${key}]'}" != "" ]'; local ret=$?; return ${ret}) \
        || ( return 1 ); } 2> /dev/null
}

#/**
# Set the value of the configuration variabel.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      The new value of the configuration variable.
# @param    String  $3      Prefix for the global environment variable name, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
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
# Add the new content to the configuration variable.
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
# Remove (empty) the configuration variable.
#
# @param    String  $1      Configuration variable name in format: [section:]key.
# @param    String  $2      Prefix for the global environment variable name, see the conf_load() function. If you don't use extra prefixes with conf_load() then skip this.
# @return   Number          Operation status.
#*/
function conf_clear() {
    { conf_set "$1" '' "$2"; } 2> /dev/null
}

#/**
# Print number of the variables in specified configuration section.
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
# Print all section keys.
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
# Initialize the module.
#*/
function conf_init() {
    local conf_fpath=${SHELL_CONFDIR}/${1}.conf.ini
    test -f ${conf_fpath} && conf_load ${conf_fpath}

    local conf_fpath=${HOME}/.config/bash/${1}.conf.ini
    test -f ${conf_fpath} && conf_load ${conf_fpath}
    
    return 0
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

