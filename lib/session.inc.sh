#/**
# SESSIONS
# 
# Session mechanism for bash scripts.
#
# Sessions allow you to share data between many instances of the same script.
# Sessions are separated between system users. 
# Session data are stored in:
# 
# `${_TMP}/$(whoami)/sessions`
#
# Variable `${_TMP}` is declared in [core library](/bhs/lib/core).
# 
# Functions:
# - session_exists          - Does the session variable exist?
# - session_set             - Set the session variable. 
# - session_put             - Set the session variable. 
# - session_push            - Add another data content to the existing session variable.
# - session_get             - Print the session variable content.
# - session_list            - Print the session variables list.
# - session_delete          - Delete the session variable.
# - session_rootdir         - Print the session root directory.
# - session_name            - Print the session name.
# - session_hash            - Print the session hash.
# - session_clear           - Delete the entire session directory.
#*/

#/**
# CONFIGURATION
# 
# The following variables are initialize automatically by session_init() function.

# Session directory (full path).
SESSION_DIR=

# Session name (basename ${1:-$0}).
SESSION_NAME=

# The session hash (sha1 from ${SESSION_NAME}).
SESSION_HASH=

#*/


# MANAGE SESSION VARIABLES

#/** 
# Does the session variable exist?
# 
# @param    String  $1          Variable name.
# @return   Number              Operation status.
#*/
function session_exists() {
    { debug_off; } 2> /dev/null

#    eval $_SESSION
    if test -z "${1}"; then
        { debug_on; return 1; } 2> /dev/null
#        return 1
    else
        local path=$(_session_var_convert_path ${1})

        if test -f "${SESSION_DIR}/${path}"; then
            { debug_on; return 0; } 2> /dev/null
#            return 0
        else
            { debug_on; return 1; } 2> /dev/null
#                return 1
        fi
    fi
}

#/**
# Set the session variable. 
#
# The content is store in the one file without special characters like new line.
# 
# @param    String  $1          Variable name.
# @param    String  $2          Variable value.
#*/
function session_set() {
    { debug_off; } 2> /dev/null

    _session_var_save 'set' $*
    local ret=$?
    { debug_on; return ${ret}; } 2> /dev/null
}

#/**
# Set the session variable. 
#
# It allows special character like new line, so that allow store multiline data.
# 
# @param    String  $1          Variable name.
# @param    String  $2          Variable value.
#*/
function session_put() {
    { debug_off; } 2> /dev/null

    _session_var_save 'put' $*
    local ret=$?
    { debug_on; return ${ret}; } 2> /dev/null
#    debug_on
#    return $?
}

#/**
# Add another data content to the existing session variable.
#
# If the session variable doesn't exist it will be create.
# 
# @param    String  $1          Variable name.
# @param    String  $2          The content to add.
#*/
function session_push() {
    { debug_off; } 2> /dev/null

    _session_var_save 'push' $*
    local ret=$?
    { debug_on; return ${ret}; } 2> /dev/null
#    debug_on
#    return $?
}

#/**
# Print the session variable content.
# 
# @param    String  $1          Variable name.
# @param    String  $2          Default value. If the variable does not exist, it will be create using default value.
#*/
function session_get() {
    { debug_off; } 2> /dev/null

#    eval $_SESSION
    if test -z "${1}"; then
        { debug_on; return 1; } 2> /dev/null
#        debug_on
#        return 1
    fi

    local path=$(_session_var_convert_path ${1})
    if test ! -e ${SESSION_DIR}/${path}; then
        if test "${2}" != ''; then
            if [[ ${2} =~ ^[0-9a-zA-Z\._-]+$ ]]; then
                session_set "${1}" "${2}"
                err=$?
            else
                val=$(eval ${2})
                session_set ${1} "${val}"
                err=$?
            fi
        else
            { debug_on; return 1; } 2> /dev/null
#            debug_on
#            return 1
        fi
    fi

    if test -f ${SESSION_DIR}/${path}; then
        content="$(cat ${SESSION_DIR}/${path})"
        if test -z "${content}"; then
            echo -en "${2}"
        else
            echo -en "${content}"
        fi

        { debug_on; return 0; } 2> /dev/null
#        debug_on
#        return 0
    else
        echo -n ${2}
        { debug_on; return 1; } 2> /dev/null
#        debug_on
#        return 1
    fi
}

#/**
# Print the session variables list.
# 
# @param    String  $1          Session group name.
#*/
function session_list() {
    { debug_off; } 2> /dev/null

    local path=$(_session_var_convert_path ${1})
    ls ${SESSION_DIR}/${path} 2> /dev/null
    
    { debug_on; return 1; } 2> /dev/null
}

#/**
# Delete the session variable.
# 
# @param    String  $1          Variable name.
#*/
function session_delete() {
    { debug_off; } 2> /dev/null

#    eval $_SESSION
    if test -z "${1}"; then
        { debug_on; return 1; } 2> /dev/null
#        debug_on
#        return 1
    fi

    local path=$(_session_var_convert_path ${1})

    if test -f ${SESSION_DIR}/${path}; then
        # call rm -fr <variable> is too risky.
        # rm -fr ${SESSION_DIR}/${path}
    
        # Let's check first if we are in the right directory?
        cd ${SESSION_DIR}
        local pp=$(pwd)

        # In the worst of case we will delete files from /tmp directory.
        if [[ $pp =~ ^/tmp ]] && [[ $pp =~ ^$(_session_rootdir) ]]; then
            rm -fr ./${path}
            local ret=$?
        else
            echo invalid sessdir
            local ret=$?
        fi

        cd - > /dev/null
        { debug_on; return ${ret}; } 2> /dev/null

#        debug_on
#        return $ret
    else
        { debug_on; return 1; } 2> /dev/null
#        debug_on
#        return 1
    fi
}


# MANAGE SESSIONS

#/**
# Initialize session.
# 
# It is invoked automatically.
#*/
function session_init() {
    { debug_off; } 2> /dev/null

    # The root directory for all sessions.
    local sessdir=$(_session_rootdir)
    if ! test -e ${sessdir}; then
        mkdir ${sessdir} && chmod 777 ${sessdir}
    fi

    chmod 700 ${sessdir}

    SESSION_NAME=${USER}_$(/usr/bin/basename ${1:-$0})
    SESSION_HASH=$(echo ${SESSION_NAME} | sha1sum | cut -d' ' -f 1)
    SESSION_DIR=$(_session_rootdir)/${SESSION_HASH}
 
    # The current session root directory.
    if ! test -e "${SESSION_DIR}"; then
        mkdir ${SESSION_DIR} && chmod 700 ${SESSION_DIR}

        # store script name and time to the logfile.
        echo "[++] $(date +%Y-%m-%d\ %H:%M:%S):${SESSION_NAME}:${SESSION_HASH}" >> $(_session_list_path)
    fi

    { debug_on; } 2> /dev/null
}

#/** 
# Print the session root directory.
#*/
function session_rootdir() {
#    eval $_SESSION
    echo ${SESSION_DIR}
}

#/** 
# Print the session name.
#*/
function session_name() {
#    eval $_SESSION
    echo ${SESSION_NAME}
}

#/** 
# Print the session hash.
#*/
function session_hash() {
#    eval $_SESSION
    echo ${SESSION_HASH}
}

#/** 
# Delete the entire session directory.
#*/
function session_clear() {
    { debug_off; } 2> /dev/null

    if test -e ${SESSION_DIR}; then
        echo "[--] $(date +%Y-%m-%d\ %H:%M:%S):${SESSION_NAME}:${SESSION_HASH}" >> $(_session_list_path)

        # call rm -fr <variable> is too risky.
        # rm -fr ${SESSION[dir]}

        # Let's check first if we are in the right directory?
        cd ${SESSION_DIR}
        local pp=$(pwd)
        
        # In the worst of case we will delete files from /tmp directory.
        if [[ $pp =~ ^/tmp ]] && [[ $pp =~ ^$(_session_rootdir) ]]; then
            local scripthash=$(basename ${pp})

            if [[ ${scripthash} =~ ^[0-9a-fA-F]{40}$ ]]; then
                rm -fr ./*
                rmdir ../${scripthash}
                cd - > /dev/null
                { debug_on; } 2> /dev/null
                return $?
            else
                cd - > /dev/null
            fi
        else
            cd - > /dev/null
        fi

        echo "invalid sessdir: ${pp}" > /dev/stderr
    fi

    { debug_on; } 2> /dev/null
    return 2
}


# HELPER FUNCTIONS.

#/**
# Get the session rootdir.
#*/
function _session_rootdir() {
    { echo "${_TMP}/$(/usr/bin/whoami)/sessions"; } 2> /dev/null
}

#/**
# Get the session list file path.
#*/
function _session_list_path() {
    { echo $(_session_rootdir)/.list; } 2> /dev/null
}

#/**
# Prepare the directory for the variabls.
# 
# @param    String  $1          Variable name.
#*/
function _session_var_init() {
#    eval $_SESSION
    {
    test -z "${1}" && return 1

    local path=$(_session_var_get_path ${1})
    local var=$(_session_var_get_name ${1})

    if test "${path}" == '.'; then
        test -d ${SESSION_DIR}/${var} \
            && return 2 \
            || return 0
    elif test -d ${SESSION_DIR}/${path}/${var}; then
        return 2
    elif test -f ${SESSION_DIR}/${path}; then
        return 3
    else
        mkdir -p ${SESSION_DIR}/${path}
        chmod 700 ${SESSION_DIR}/${path}
        return $?
    fi; } 2> /dev/null
}

#/**
# Store the variable content.
# 
# @param    String  $1          Store method:: 
#                       set         Override the current value. It skips a special characters like \t or \n.
#                       put         Override the current value. It allows a specail characters like \t or \n, so that you can use a multiline contents.
#                       push        Add the content to existing.
# @param    String  $2          Variable name.
# @param    String  $3          Data content.
#*/
function _session_var_save() {
#    eval $_SESSION
    {
    test -z "${2}" \
        && return 1 \
        || local method=$1

    local path=$(_session_var_convert_path ${2})
    _session_var_init ${path}
    local err=$?
    test ${err} -ne 0 && return ${err}

    local data="$3"
    shift
    while test -n "$3"; do
        data+=" $3"
        shift
    done

    case ${method} in
        set) echo -e "${data}" | tr -d '\n'  > ${SESSION_DIR}/${path} 
             ;;

        put) echo -e "${data}" > ${SESSION_DIR}/${path}
             ;;

        push) echo -en "${data}" >> ${SESSION_DIR}/${path}
              ;;

        *) return 2
           ;;
   esac

   return 0; } 2> /dev/null
}

#/**
# Convert a variable name to the file path.
# 
# @param    String  $1          Variable name.
#*/
function _session_var_convert_path() {
    {
    test -z "${1}" \
        && return 1 \
        || echo "${1}" | tr '\t;!? ' '____'

    return 0; } 2> /dev/null
}

#/**
# Get the variable path.
# 
# @param    String  $1          Variable name.
#*/
function _session_var_get_path() {
    {
    test -z "${1}" && return 1
    
    local path=$(_session_var_convert_path ${1})
    dirname ${path}
    return $?; } 2> /dev/null
}

#/**
# Get the variable name from the path.
# 
# @param    String  $1          Variable path.
#*/
function _session_var_get_name() {
    {
    test -z "${1}" && return 1

    local path=$(_session_var_convert_path ${1})
    basename ${path}
    return $?; } 2> /dev/null
}

#session_init "$@"

