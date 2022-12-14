{ 
    # Include this script inly once.
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

} 2> /dev/null

#/**
# Print a message to stdout. It depends on the '@' function (lang module is loaded).
# 
# @param    String  $1  Alternatative text if lang module is not present.
# @param    String  $2  The lang variable ID if lang module is loaded.
# @param    String  $3+ Extra arguments for the lang variable.
#*/
_msg() {
    ! is_function '@' && echo "${1}" && return 0

    shift
    @ $@
}

checkpoint() {
    _bt "$@"
}

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
# 2> /dev/null
    { debug_on; } 2> /dev/null
}



# DEBUG MODE.

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
# [DEPRECATED] Prepare the PATH environment variable.
# 
# @param    String  $1              How to perpare?
#                       usr             User scripts, e.g: /usr/bin/, /usr/local/bin, ${SHELL_BINDIR}/term 
#                       usrx            As above + ${SHELL_BINDIR}/x
#                       adm             Admin scripts, e.g: <usr> + /usr/sbin, /usr/local/sbin
#                       admx            As above + ${SHELL_BINDIR}/x
#                       <null>          -> usr
#*/
path() {
    local path_usr="${SHELL_BINDIR}/term:/bin:/usr/bin:/usr/local/bin:."
    local path_adm="/sbin:/usr/sbin:/usr/local/sbin"
    local path_x="${SHELL_BINDIR}/x"

    if test "${1}" = '' -o "${1}" = 'usr'; then
        echo "${path_usr}"
    elif test "${1}" == 'usrx'; then
        echo "${path_x}:${path_usr}"
    elif test "${1}" == 'adm'; then
        echo "${path_usr}:${path_adm}"
    elif test "${1}" == 'admx'; then
        echo "${path_x}:${path_adm}:${path_usr}"
    fi
}

#/**
# Print the path of the current script.
# 
# @param    $1                      Replace spaces with underscores?
#*/
rootdir() {
    {
    test "${1}" != '' \
        && dirname "$0" | tr ' ' '_' \
        || dirname "$0"; } 2> /dev/null
}

#/**
# Print the path with of the script data directory.
#*/
datadir() {
    {
    local dir=$(dirname "$0")
    dir=$(dirname "${dir}")
    echo -n "${dir}/data" | tr ' ' '_'; } 2> /dev/null
#    $(dirname $(dirname $0))/data | tr ' ' '_'
}

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
# Print the current script name (without .sh extension).
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
# Print the real script name. It resolves symlinks.
# 
# @param    $1                      Replace spaces with underscores?
#*/
realscr() {
    local path=$0
    test "${path:0:1}" != '/' && path=$(which $0)

    {
    test "${1}" != '' \
        && basename "$(realpath ${path})" | tr ' ' '_' \
        || basename "$(realpath ${path})"; } 2> /dev/null
}

#/**
# Print the current script ID.
#*/
pid() {
    { echo $$; } 2> /dev/null
}

#/**
# Print the startup directory.
#*/
cwd() {
    { echo ${_CWD}; } 2> /dev/null
}

#/**
# Show method of execute the script. It shows:
#   user - it runs by user in interactive mode.
#   system - it runs by system (script, shortcut key, etc.).
#   cron - it runs by cron.
#*/
scrmethod() {
    local p=$(pid)
    local path=$(realpath /proc/${p}/fd/0)

    test ${path} = '/dev/null' && echo 'system' && return 0
    [[ ${path} =~ ^/dev/(pts/)|(tty)[0-9]+ ]] && echo 'user' && return 0
    [[ ${path} =~ ^/proc/[0-9]+/fd/pipe:\[[0-9]+\] ]] && echo 'cron' && return 0
    echo '??' && return 1
}

#/**
# Load the module from ${SHELL_LIBDIR} directory.
# 
# @param    String  $1              A module name.
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

    # The module is already loaded.
    if is_lib ${lib}; then
#        echo "Module ${lib} already loaded" > /dev/stderr
        echo > /dev/null

    # There is no module.
    elif test ! -f ${SHELL_LIBDIR}/${lib}.inc.sh; then
        local msg=$(_msg "Module ${lib} not found" 'module:notfound' ${lib})
        logger -t $(scr):${BASH_LINENO[0]} ${msg}
        { debug_on; } 2> /dev/null
        echo ${msg} > /dev/stderr
        exit 1

    # Load the module..
    else
        shift

        source ${SHELL_LIBDIR}/${lib}.inc.sh 

#        shopt -s expand_aliases

        # There is a module initial function.
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
#} 2> /dev/null 

    { debug_on; return ${ret}; } 2> /dev/null
}

#/**
# Is the module loaded?
# 
# @param    String  $1              A module name.
# @return   Number                  Operation status.
#*/
is_lib() {
    { 
    local lib=${1}
    local lib=${lib/\.sh/}
    local lib=${lib/\.inc/}

    is_function ${lib}_init; } 2> /dev/null
}

#/**
# Read data from /dev/stdin using syntax completion.
# 
# @param    string  $1              The prompt for the `read` command.
# @param    array   $2+             List of complete words.
#*/
reada() {
#    {
    local prompt=$1
    local id=$(realscr)-$(pid)-completion
    shift
    for c in "$@" ; do
        tmp_file "${c}" "${id}" > /dev/null
    done
    
    cd "$(tmp_rootdir)/${id}" 
    read -re -p "${prompt}: " usertags 
    printf "%s" "${usertags}"
    cd - > /dev/null
    tmp_clean "${id}"; 
#} 2> /dev/null
}

#/**
# Is the function exist?
# 
# @param    String  $1              Function name.
# @return   Number                  Operation status.
#*/
is_function() {
    { declare -f ${1} > /dev/null 2> /dev/null; } 2> /dev/null
}

#/**
# Is shell command exist?
# 
# @param    String  $1              Command name.
# @return   Number                  Operation status.
#*/
is_command() {
    { which "$1" > /dev/null > /dev/null 2>&1 && whereis "$1" > /dev/null 2>&1; } 2> /dev/null
}

#/**
# Is there exist the user in the group?
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
# Is the group exist?
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
# Is the user can execute the sudo command?
# 
# @param    String  $1              Command to execute.
# @param    String  $2              Sudoer user name [root].
# @return   Number                  Status operacji.
#*/
is_sudo() {
    {
    local cmd=$1
    local asuser=${2:-root}

#    echo sudo -l -U ${USER} -u ${asuser} ${cmd} 
    sudo -l -U ${USER} -u ${asuser} ${cmd} > /dev/null 2>&1; } 2> /dev/null
}

#/**
# Is the script running as root user?
# 
# @return   Number                  Operation status.
#               0                       As root user.
#               1                       Non-root user.
#*/
as_root() {
    { test "$(/usr/bin/whoami)" == 'root'; } 2> /dev/null
}


#/**
# COMMAND LINE.
#
# Manage of the command line arguments and options. 
# None fun with poor `getopt`..
#
# For options (-f --foo) you can use:
#   opt_is      - Is the opt set?
#   opt_get     - Get option variable.
#   opt_size    - Get number of all options.
#
# For arguments you can use:
#   arg_is      - Is an argument by index exist?
#   arg_get     - Get an argument value by its index.
#   arg_size    - Get number of all arguments.

# Options from command line.
declare -A _OPTS

# Arguments from command line.
_ARGS=()

#*/

#/**
# Is the option exist?
#
# @param    String  $1      Option to check. If empty checks any option.
# @return   Number          Operation status.
#*/
opt_is() {
    { test "${1}" != '' && test "${_OPTS[$1]}" != '' \
        || test "${1}" = '' && test ${#_OPTS[@]} -ne 0; } 2> /dev/null 
}

#/**
# Print the option value.
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
# Is the option exist and it is greater than $2.
#
# @param    String  $1      Option to check.
# @param    String  $2      Value to compare.
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
# Is the option exist and it is greater than or equal to $2.
#
# @param    String  $1      Option to check.
# @param    String  $2      Value to compare.
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
# Is the option exist and it is less than $2.
#
# @param    String  $1      Option to check.
# @param    String  $2      Value to compare.
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
# Is the option exist and it is less than or equal to $2.
#
# @param    String  $1      Option to check.
# @param    String  $2      Value to compare.
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
# Print the number of options.
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
# Print the number of arguments.
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
# Print the argument by its index.
# 
# @param    Number  $1      Index of the argument to print.
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

#/**
# Parse command line. The convenient version of getopt.
#
# The function starts automatically after loading the module.
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


#/**
# TEMPORARY FILES.
# 
# The temporary files are stored in the current user directory. Only user have access to them.
#
#   _tmp_init   - prepare the temporary root directory (autoamatic call).
#   tmp_dir     - print the path to the temporary root directory.
#   tmp_file    - print the path to the temporary file. Each call generates new temporary file.
#   tmp_clean   - delete all temporary files (manually call).
#*/

#/**
# Print the temporary root directory path.
#*/
tmp_rootdir() {
    { echo /tmp/ram00/$(whoami); } 2> /dev/null
}

#/**
# Print the custom temporary directory.
# 
# @param    String  $1      Name of the temporary directory (subdir relative temporary root directory).
#*/
tmp_dir() {
    {
    local rootdir=$(tmp_rootdir)
    local subdir=${1:-$(realscr)-$(pid)}

    if test -z "${subdir}"; then
        echo ${rootdir}
    else 
        test ! -e "${rootdir}/${subdir}" && mkdir "${rootdir}/${subdir}"

        echo ${rootdir}/${subdir}
    fi; } 2> /dev/null
}

#/**
# Print the temporary file path.
#
# As default the temporary files are storead in $(tmp_dir). 
# To keep order, it is possible to separete the temporary files to many subdirectories using prefix.
# 
# @param    String  $1      File prefix.
# @param    String  $2      Subdirectory name.
#*/
tmp_file() {
    {
#    local subdir=${2:-$(realscr)-$(pid)}
#    local fpath="$(tmp_rootdir)/${subdir}/" prefix=${1}
    local fpath="$(tmp_dir ${2})/" prefix=${1}

    ! -e ${fpath} && mkdir ${fpath}

    if test "${prefix}" == '' -o "${prefix}" == '#'; then
        fpath+=$(cat /dev/urandom | head -n1 | md5sum | cut -c 1-8)
    else
        [[ ${prefix} =~ .*/.* ]] && prefix=$(basename "${prefix}")

        local hash_pattern='.*#.*'

        while [[ ${prefix} =~ ${hash_pattern} ]]; do
            prefix=${prefix/\#/$(cat /dev/urandom | head -n1 | md5sum | cut -c 1-8)}
        done

        fpath+=${prefix}
    fi

    touch "${fpath}"
    echo "${fpath}"; } 2> /dev/null
}

#/**
# Delete the temporary files/directories.
# 
# @param    String  $1      Subdirectory name. Domyślnie $(realscr)-$(pid).
#*/
tmp_clean() {
    {
    local tmp=$(tmp_dir ${1})
    # call rm -fr ${tmp} is too risky.
    # rm -fr ${tmp}

    # Let's check first if we are in the right directory?
    if test -d "${tmp}" && [[ ${tmp} =~ ^/tmp ]]; then
        rm -f ${tmp}/*
        rmdir ${tmp}
    fi; } 2> /dev/null

#    if [ -d "${tmp}/$(realscr)-$(pid)" ]; then
#        rm -f ${tmp}/$(realscr)-$(pid)/*
#        rmdir ${tmp}/$(realscr)-$(pid)/
#    fi
}

#/**
# Prepare the temporary subdirectory.
#
# @param    String  $1      Subdirectory name.
#*/
tmp_mkdir() {
    {
    local t=${1}
    test -z ${t} && return 1
    test -d $(tmp_rootdir)/${t} && return 0
    mkdir -p $(tmp_rootdir)/${t} 2> /dev/null; } 2> /dev/null
}

#/**
# Create the temporary directory.
# 
# The function is unset after call.
#*/
_tmp_init() {
    local tmp_dir=$(tmp_rootdir)

    test ! -d ${tmp_dir} && mkdir -p ${tmp_dir}

    chmod 700 ${tmp_dir}
}


# ERRORS HANDLING.

#/**
# Set the last error message.
#
# @param    String  $*      Error message.
#*/
err_set() {
    { _LAST_ERROR="$*"; } 2> /dev/null
}

#/**
# Print the last error message.
#*/
err_get() {
    { echo $_LAST_ERROR; } 2> /dev/null
}

#/**
# Print the error message to /dev/stderr and continue.
#
# @param    String  $*      Error message. błędu. If empty it is try use last error message.
#*/
err_dump() {
    { debug_off; } 2> /dev/null
    if [ "$1" == '' ]; then
        local msg=$(err_get) 
    else
        local msg=$*
    fi

    if test -n "${msg}"; then
        if is_function textln; then
            textln -m "${msg}" -f WHITE -b RED > /dev/stderr
        else
            echo -en "\x1b[41;37;5m" > /dev/stderr
            echo -n ${msg}
            echo -e "\x1b[0m" > /dev/stderr
        fi
    fi
    { debug_on; } 2> /dev/null
}

#/**
# Print the error message to  /dev/stderr and exit with code 1.
#
# @param    String  $*      Error message. błędu. If empty it is try use last error message.
#*/
err_fatal() {
    { debug_off; } 2> /dev/null
    if test "$1" != ''; then
        test "$(err_get)" != '' && err_dump "$(err_get)" 
        err_dump "$@"
    else
        err_dump "$@"
    fi
    { debug_on; } 2> /dev/null
    exit 1
}


# UNSET HELPER FUNCTIONS

# Parse the command line arguments and unset the _parseline() function.
_parseline "$@"; unset _parseline

# Prepare the temporary directories and unset the _tmp_init() function.
_tmp_init; unset _tmp_init


{ test "${_DEBUG}" == '0' && set -x; } 2> /dev/null

