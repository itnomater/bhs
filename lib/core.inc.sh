{ 
    # Include this script only once.
    test -n "${_CORE_IS_INIT}" && return 0 || _CORE_IS_INIT=1

    # Make sure that the environment variables are set.
    source ~/.config/shell/variables.inc.sh

    # Save the current directory path in heper variable. 
    # If you use the `cd` command in your script, $_CWD is always indicates to the start work directory.
    declare -r _CWD=$(pwd)

    # Prepare to debug mode.
    echo $- | /bin/grep 'x' > /dev/null
    if test $? -eq 0; then
        set +x
        _DEBUG=0 
    else
        _DEBUG=; 
    fi

    # Set the aliasses for convenient switching between normal and debug mode.
    #    shopt -s expand_aliases
    #    alias _debug_off='{ [[ ${_DEBUG} =~ ^[0-9]+$ ]] || return 0; test "${_DEBUG}" -eq 0 && set +x || _DEBUG=$((_DEBUG + 1)); } 2> /dev/null'
    #    alias _debug_on='{ [[ ${_DEBUG} =~ ^[0-9]+$ ]] || return 0;  test "${_DEBUG}" -eq 0 && set -x || _DEBUG=$((_DEBUG - 1)); } 2> /dev/null'

    # Above code doesn't work properly. It uses inside function generate an error "command not found". But why?!
    # At this moment switching between debug and normal mode is handled manually by the code:
    # { debug_off; } 2> /dev/null  # this code as an alias produced the error ^^
    # That is curious. When remove `2> /dev/null` above error doesn't appear. It is bug? Or I miss something..

    # Set the debug prompt.
    test -t 1 \
        && export PS4=$(echo -e '\x1b[34m[$? $(basename ${BASH_SOURCE}):${LINENO}] $\x1b[0m ') \
        || export PS4='[$? $(basename ${BASH_SOURCE}):${LINENO}] $ '

#   It is too slow!
#    test -t 1 \
#        && export PS4=$(echo -e '\x1b[34m[$? $(_bt) ]\x1b[0m ') \
#        || export PS4='[$? $(_bt) ] $ '

#    export PS4='(${BASH_SOURCE}:${LINENO}): - [${SHLVL},${BASH_SUBSHELL},$?] $ '
#    test -n "${VIMRUNTIME}" \
#        && export PS4='[ $? $(basename ${BASH_SOURCE}):${LINENO}] $ ' \
#        || export PS4=$(echo -e '\x1b[34m[$? $(basename ${BASH_SOURCE}):${LINENO}] $\x1b[0m ')

#    export PS4=$(echo -en "\x1b[34m" > /dev/stderr; echo -n "> [$? ${BASH_SOURCE}:${LINENO}] $"; echo -e "\x1b[0m " > /dev/stderr)
#    export PS4="> [$? ${BASH_SOURCE}:${LINENO}] $ "

    # Global variables do not use them directly!
    # Some of them are using in libraries. They must be declared here because of variables scope.

    # Libraries list [core library].
    declare -A _LIBS

    # Command line arguments and options. [cmdline library]. 
    declare -A _OPTS
    _ARGS=()

    # Temporary rootdirectory. [tmp library].
    # ram00 is mapped memory.
    _TMP=/tmp/ram00
} 2> /dev/null


# GENERAL HELPERS

#/**
# Print the current script name.
# 
# @param    $1                      Replace spaces with underscores?
#*/
scr() {
    {
    test "${1}" != '' \
        && basename "$0" | tr ' ' '_' \
        || basename "$0"; } 2> /dev/null
}

#/**
# Print the current script name without `.sh` extension.
# 
# @param    $1                      Replace spaces with underscores?
#*/
scrname() {
    {
    test "${1}" != '' \
        && scr "$1" | tr ' ' '_' | sed 's@.sh$@@' \
        || scr "$1" | sed 's@.sh$@@'; } 2> /dev/null
}

#/**
# Print method of execute the script. It shows:
#   user - it is run by user in interactive mode.
#   system - it is run by system (script, shortcut key, etc.).
#   cron - it is run by cron.
# 
#*/
scrmethod() {
    local p=$$
    local path=$(realpath /proc/${p}/fd/0)

    test "${path}" = '/dev/null' && echo 'system' && return 0
    [[ ${path} =~ ^/dev/(pts/)|(tty)[0-9]+ ]] && echo 'user' && return 0
    [[ ${path} =~ ^/proc/[0-9]+/fd/pipe:\[[0-9]+\] ]] && echo 'cron' && return 0
    echo '??' && return 1
}

#/**
# Print the real script name. It resolves symlinks.
# 
# @param    $1                      Replace spaces with underscores?
#*/
realscr() {
    {
    local path=$0
    test "${path:0:1}" != '/' && path=$(which $0)
    local rpath=$(realpath "${path}")

    test "${1}" != '' \
        && basename "${rpath}" | tr ' ' '_' \
        || basename "${rpath}"; } 2> /dev/null
}


#/**
# Print the startup directory. 
#
# The function always returns the start working directory even you change it by `cd` command.
#*/
cwd() {
    { echo ${_CWD}; } 2> /dev/null
}

#/**
# Print the current script PID.
#
# It is more readable version of $$ global variable.
#*/
pid() {
    { echo $$; } 2> /dev/null
}


#/**
# Load the library from ${SHELL_LIBDIR} directory.
#
# When loading fails it generates a fatal error and script stops immediately with the error message. Additionally, it generates a syslog entry using the `logger` command.
#
# @param    String  $1              Library name.
# @return   Number                  Operation status.
#*/
lib() {
    { debug_off; } 2> /dev/null
#   {
#    { set +x; } 2> /dev/null
#    test "${_DEBUG}" == 'on' && set +x
    local lib=${1}
    local lib=${lib/\.sh/}
    local lib=${lib/\.inc/}
    local ret=0

    # The library is already loaded.
    if is_lib ${lib}; then
#        echo "Module ${lib} already loaded" > /dev/stderr
        echo > /dev/null

    # There is no library.
    elif test ! -f ${SHELL_LIBDIR}/${lib}.inc.sh; then
        local msg=$(_msg "Module ${lib} not found" 'module:notfound' ${lib})
        logger -t $(scr):${BASH_LINENO[0]} ${msg}
        { debug_on; } 2> /dev/null
        echo ${msg} > /dev/stderr
        exit 1

    # Load the library..
    else
        shift

        source ${SHELL_LIBDIR}/${lib}.inc.sh 

#        shopt -s expand_aliases

        # There is a library initial function.
        if is_function ${lib}_init; then
            { ${lib}_init "$@"; } 2> /dev/null
            local ret=$?
            if test ${ret} -ne 0; then
                local msg=$(_msg "Module ${lib} init failed" 'module:initfailed' ${lib})
                logger -t $(scr):${BASH_LINENO[0]} ${msg}
                { debug_on; } 2> /dev/null
                echo ${msg} > /dev/stderr
                exit ${ret} 
            fi
        fi

        # There are extra shell command that needed.
        if is_function ${lib}_user_commands; then
            local user_commands=( $(${lib}_user_commands) )

            for cmd in ${user_commands[@]}; do
                if ! is_command ${cmd}; then
                    local msg=$(_msg "Command ${cmd} not found" "cmd:notfound" ${cmd})
#                    alias ${cmd}="echo ${msg} > /dev/stderr; logger -t $(scr):\${LINENO} ${msg}; exit 1"
                    eval "${cmd}(){
                        echo ${msg} > /dev/stderr
                        logger -t \${BASH_SOURCE[1]}:\${BASH_LINENO[0]} ${msg}
                        exit 1
                    }"
                fi
            done
        fi

        # There are extra shell command that needed root permissions.
        if is_function ${lib}_root_commands; then
            local root_commands=( $(${lib}_root_commands) )

            for cmd in ${root_commands[@]}; do
                if ! is_command ${cmd}; then
                    local msg=$(_msg "Command ${cmd} not found" "cmd:notfound" ${cmd})
#                    alias ${cmd}="echo ${msg} > /dev/stderr; logger -t $(scr):\${LINENO} ${msg}; exit 1"
                    eval "${cmd}(){
                        echo ${msg} > /dev/stderr
                        logger -t \${BASH_SOURCE[1]}:\${BASH_LINENO[0]} ${msg}
                        exit 1
                    }"
                elif ! is_sudo ${cmd}; then
                    local msg=$(_msg "No permission to run ${cmd}" "cmd:nopermissions" ${cmd})
#                    alias ${cmd}="echo ${msg} > /dev/stderr; logger -t $(scr):\${LINENO} ${msg}; exit 1"
                    eval "${cmd}() {
                        echo ${msg} > /dev/stderr 
                        logger -t \${BASH_SOURCE[1]}:\${BASH_LINENO[0]} ${msg}
                        exit 1
                    }"
                        
                        

                else
#                    alias ${cmd}="sudo ${cmd}"
                    eval "${cmd}() {
                        sudo $(which ${cmd}) \$@ 
                    }"
                fi
            done
        fi


        test "$(cwd)" != "$(pwd)" && cd "$(cwd)"

    fi;
    
    _LIBS[${lib}]=1

#} 2> /dev/null 

    { debug_on; return ${ret}; } 2> /dev/null
}

#/**
# Check if the library is loaded.
# 
# @param    String  $1              Library name.
# @return   Number                  Operation status.
#*/
is_lib() {
    { 
    local lib=${1}
    local lib=${lib/\.sh/}
    local lib=${lib/\.inc/}

#    is_function ${lib}_init;  2> /dev/null
    test -n "${_LIBS[${lib}]}"; }  2> /dev/null
}

#/**
# Check if the function exists.
# 
# @param    String  $1              Function name.
# @return   Number                  Operation status.
#*/
is_function() {
    { declare -f ${1} > /dev/null 2> /dev/null; } 2> /dev/null
}

#/**
# Check if the shell command exists.
# 
# @param    String  $1              Command name.
# @return   Number                  Operation status.
#*/
is_command() {
    { which "$1" > /dev/null > /dev/null 2>&1 && whereis "$1" > /dev/null 2>&1; } 2> /dev/null
}

#/**
# Check if the user exists. 
# And, optionaly, if they are in the group (if you provide the second argument - a group name).
# 
# @param    String  $1              User name.
# @param    String  $2              [Group name].
# @return   Number                  Operation status.
#*/
is_user() {
    {
    local user=$1
    local grp=$2

    ! grep -q "^${user}:" /etc/passwd > /dev/null 2>&1 && return 1
    
    if test "${grp}" != ''; then
        ! grep -q "^${grp}:" /etc/group > /dev/null 2>&1 && return 1
        ! grep "^${grp}:" /etc/group | grep -q "[:,]${user}" > /dev/null 2>&1 && return 1
    fi

    return 0; } 2> /dev/null
}

#/**
# Check if the group exists.
# 
# @param    String  $1              Group name.
# @return   Number                  Operation status.
#*/
is_group() {
    {
    local group=$1

    test "${group}" != '' \
        || return 1 \
        && grep -q -E "^${group}:" /etc/group > /dev/null 2>&1; } 2> /dev/null
}

#/**
# Check if the user can execute a command using the `sudo` command.
# 
# @param    String  $1              Command to check.
# @param    String  $2              Sudo user name [root].
# @return   Number                  Operation status.
#*/
is_sudo() {
    {
    local cmd=$1
    local asuser=${2:-root}

#    echo sudo -l -U ${USER} -u ${asuser} ${cmd} 
    sudo -l -U ${USER} -u ${asuser} ${cmd} > /dev/null 2>&1; } 2> /dev/null
}

#/**
# Check if the script is running as root.
# 
# @return   Number                  Operation status.
#               0                       As root user.
#               1                       Non-root user.
#*/
as_root() {
    { test "$(/usr/bin/whoami)" == 'root'; } 2> /dev/null
}


# DEBUG

#/**
# Activate debug mode.
# 
# To hide execution of the function in debug mode redirect output to /dev/null by:
# { debug_on; } 2> /dev/null
#*/
debug_on() {
    { 
#    echo activate ${_DEBUG}
    [[ ${_DEBUG} =~ ^[0-9]+$ ]] || return 0

    let _DEBUG++
    set -x

    } 2> /dev/null
}

#/**
# Deactivate debug mode.
#
# To show execution of the function in debug mode redirect output to /dev/null by:
# { debug_off; } 2> /dev/null
#*/
debug_off() {
    {
#    echo deactivate ${_DEBUG}
    [[ ${_DEBUG} =~ ^[0-9]+$ ]] || return 0

    test ${_DEBUG} -gt 0 && let _DEBUG--
    set +x

    } 2> /dev/null
}

#/**
# Print a message to stdout. It depends on the '@' function (lang library is loaded). 
#
# @param    String  $1  Alternatative text if lang library is not present.
# @param    String  $2  The lang variable ID if lang library is loaded.
# @param    String  $3+ Extra arguments for the lang variable.
#*/
_msg() {
    ! is_function '@' && echo "${1}" && return 0

    shift
    @ $@
}

_log() {
    printf '%s: %s\n' $(date '+%H:%M:%S.%N') "$*" > /dev/stderr
}

#/**
# Print the current call stack with an optional argument.
#
# @param    String  $1      Additional argument(s) to print.
#*/
checkpoint() {
    _bt "$@"
}

#/**
# Print the current call stack.
#*/
_bt() {
    { debug_off; } 2> /dev/null
    let max=${#FUNCNAME[@]}
    let max--                                   # << skip main script

    _BT_LAST_FUN=

    test -t 0 || echo -n '->'            
    while test ${max} -ge 1; do                 # << skip _bt() call
#        if test "${FUNCNAME[$max]}" != 'checkpoint'; then       # << skip call from checkpoint function.
            if test "${_BT_LAST_FUN}" != "$(basename ${BASH_SOURCE[$max]})"; then
                _BT_LAST_FUN="$(basename ${BASH_SOURCE[$max]})"
                echo -n "${_BT_LAST_FUN}[${BASH_LINENO[$max-1]}]:${FUNCNAME[$max]}()"
            else
                echo -n "${FUNCNAME[$max]}()[${BASH_LINENO[$max-1]}]"
            fi
#        fi

        if test ${max} -gt 1; then
            echo -n ' > '
        else
            echo " = $*"
        fi

        let max--
    done 
    { debug_on; } 2> /dev/null
}

{ test "${_DEBUG}" == '0' && set -x; } 2> /dev/null

