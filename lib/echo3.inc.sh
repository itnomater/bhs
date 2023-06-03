#/**
# Helper functions for input data from user, printing messages and cursor management.
# 
# These functions can be divided into several categories.

##### Basic text printing
# 
# text  - Print text (also with color options) in a specified position. No break line at the end.
# textln  - Works as above but adds a newline character at the end.
# line  - Print the full-width separator line.
# header  - Print the header.

##### Print an action status message
# 
# success  - Print success message (green color).
# info  - Print information message (blue color).
# warning  - Print warning message (yellow color).
# error  - Print error message (red color).
# fatal  - Print fatal error message (red color).

##### Print the progress and results of the actions
# 
# progress  - Print the progress (step) of the action.
# result  - Print the result of the action.

##### Getting information from the user
# 
# confirm  - Confirm the action execution. 
# input  - Get information from the user.
# password  - Get the password from the user.

##### Cursor management
# 
# cursor\_move  - Move the cursor to the specified coordinates.
# cursor\_up  - Move the cursor to the previous line(s).
# cursor\_down  - Move the cursor to the next line(s).
# cursor\_left  - Move the cursor to the previous column(s).
# cursor\_right  - Move the cursor to the next column(s).

##### Extra functions
# echof  - Print formatted text.
# verbose\_mode  - Set verbose mode.
# ansi\_state  - Set the output file descriptor for the ANSI control sequences.

#### Colors
# 
# Defined colors for printing functions.

##### Dark variants of the colors
# 
# - black
# - red
# - green
# - yellow
# - blue
# - purple
# - cyan
# - white

##### Light variants of the colors
# 
# - BLACK
# - RED
# - GREEN
# - YELLOW
# - BLUE
# - PURPLE
# - CYAN
# - WHITE

##### ANSI Sequences
# 
# ANSI sequences are used by [echof](/bhs/lib/echo3/echof) function:
# 
# |  sequence             | meaning                                                       |
# | :-                    | --                                                            |
# | %~                    | Work directory.                                               |
# | %{nl}                 | New line.                                                     |
# | **_Clear the line_**  |                                                               |
# | %{clb}                | Clear the line from the cursor to the beginning.              |
# | %{cle}                | Clear the line from the cursor to the end.                    |
# | %{cl}                 | Clear the whole line.                                         |
# | %{csb}                | Clear the screen from the cursor to the beginning.            |
# | %{cse}                | Clear the screen from the cursor to the end.                  |
# | %{cs}                 | Clear the whole screen.                                       |
# | **_Navigate_**        |                                                               |
# | %{home}               | Move the cursor to the 1:1 coordinates.                       |
# | %{moveC}              | Move the cursor to the specified column in the current row.   |
# | %{gotoL:C}            | Move the cursor to the specified coordinates.                 |
# | %{upN}                | Move the cursor to the previous line.                         |
# | %{downN}              | Move the cursor to the next line.                             |
# | %{leftN}              | Move the cursor to the previous column.                       |
# | %{rightN}             | Move the cursor to the next column.                           |
# | **_Attributes_**      |                                                               |
# | %{reset}              | Reset all attributes.                                         |
# | %{fgNNN}              | Set font color from [256-color palette](https://www.ditig.com/256-colors-cheat-sheet).                    |
# | %{nofg}               | Set font color to default.                                    |
# | %{bgNNN}              | Set background color from [256-color palette](https://www.ditig.com/256-colors-cheat-sheet).              |
# | %{nobg}               | Set default background color.                                 |
# | %{bold}               | Enable text-bold.                                             |
# | %{nobold}             | Disable text-bold.                                            |
# | %{underline}          | Enable text-underline.                                        |
# | %{nounderline}        | Disable text-underline.                                       |
# | %{blink}              | Enable text-blinking.                                         |
# | %{noblink}            | Disable text-blinking.                                        |
# | %{inverse}            | Enable reverse colors.                                        |
# | %{noinverse}          | Disable reverse colors.                                       |
#*/

# MESSAGES

#/**
# Print text in a specified position. No break line at the end.
# 
# By default text is printed at the current cursor position.
# 
# Examples:
# text -f white -b red -c 10 -m 'Red alert' -p '> '             # It prints text '> Red alert' in white text and red background.
# text -f GREEN -t 'OK' -m 'The missile launch is complete'     # It prints text '[ OK ] The missile launch is complete. The tag 'OK' is in the bright green color.
#
# @param    String  -m $1       Text to print.
# @param    String  -f $2       Text color.
# @param    String  -b $3       Background color.
# @param    Number  -c $4       Column number where text printing begins.
# @param    String  -t $5       Extra tag to print.
# @param    String  -p          Extra prefix for printing text. Only use if tag is not present.
# @param    String  -C          Do not clear the rest of the line.
#*/
text() {
    { debug_off; } 2> /dev/null

    test $# -eq 0 && return 1

    local msg fcol bcol col tag prefix save_eol
    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -f|--fg|--foreground) 
                    fcol=${2} 
                    shift 2 ;;

                -b|--bg|--background) 
                    bcol=${2} 
                    shift 2 ;;

                -c|--col) 
                    col=${2} 
                    shift 2 ;;

                -m|--msg|--message) 
                    msg=${2} 
                    shift 2 ;;

                -t|--tag) 
                    tag=${2} 
                    shift 2 ;;

                -p|--prefix) 
                    prefix=${2} 
                    shift 2 ;;
                    
                -C|--clear)
                    save_eol=1
                    shift 1 ;;

                *) shift
            esac
        done
    else
        msg=$*
#        msg=${1}
#        fcol=${2}
#        bcol=${3}
#        col=${4}
#        tag=${5}
        prefix=''
    fi

    # Column.
    test -n "${col}" && cursor_move ${col}

    # Only content.
#    if [ "${fcol}${bcol}" == '' ]; then
#        echo -n "${prefix}${msg}"

    # Colored content.
#    else
        # [ <tag> ] <msg>
        if test -n "${tag}"; then
            echo -n "$(_dt)[ "
            test -n "${bcol}" && _set_color -b "${bcol}"
            test -n "${fcol}" && _set_color -f "${fcol}"

            echo -n ${tag}
            _set_color
            echo -n " ] ${msg}"

        # Content
        else
            test -n "${fcol}" && _set_color -f "${fcol}"
            test -n "${bcol}" && _set_color -b "${bcol}"
            echo -n "$(_dt)${prefix}${msg}"
            _set_color
        fi
#    fi

    test -z "${save_eol}" && _ansi_sequence '0K'
    { debug_on; } 2> /dev/null
}

#/**
# Print text in a specified position and with line break.
# 
# It is a wrapper to `text()` function + line break at the end.
#
# @param    String  -m $1       Text to print.
# @param    String  -f $2       Text color.
# @param    String  -b $3       Background color.
# @param    Number  -c $4       Column number where text printing begins.
# @param    String  -t $5       Extra tag to print.
# @param    String  -p $6       Extra prefix for printing text. Only use if tag is not present.
# @param    Boolean -C          Do not clear the rest of the line."
#*/
textln() {
    { debug_off; } 2> /dev/null
    text "$@" 
    { echo; } 2> /dev/null
    { debug_on; } 2> /dev/null
}

#/**
# Print the full-width separator line.
#
# @param    Char    -c $1       Separator character. [-]
# @param    String  -f $2       Text color.
# @param    String  -b $3       Background color.
#*/
line() {
    { debug_off; } 2> /dev/null
    local char fcol bcol max content

    if test "${1:0:1}" == '-'; then
        char='-'
        while test -n "${1}"; do
            case ${1} in
                -c|--char)  char="${2:0:1}" 
                            shift 2 ;;

                -f|--fg)    fcol="${2}" 
                            shift 2 ;;

                -b|--bg)    bcol="${2}" 
                            shift 2 ;;

                *) shift
            esac
        done
    else
        char="${1:--}"
        fcol="${2}"
        bcol="${3}"
    fi

    max=$(tput cols)
    test -z "${max}" && max=80

    while test ${max} -gt 0; do
        content+=${char}
        let max-=1
    done

    # Colored line.
    if test -n "${fcol}${bcol}"; then
        test -n "${fcol}" && _set_color -f "${fcol}"
        test -n "${bcol}" && _set_color -b "${bcol}"
        echo "${content}"
        _set_color

    # Line in the default color.
    else
        echo "${content}"
    fi
    
    { debug_on; } 2> /dev/null
}

#/**
# Print the header.
# Output format is: {prefix} {header}\n.
# 
# Examples:
#   header -m 'Header 1'                  # > Header 1
#   header -m 'Header 2' -l 2             # >> Header 2
#   header -m 'Header 3' -l 2 -p '*'      # ** Header 3
#   header -m 'Header 4' -f 'Red header'  # >> Red hader
# 
# @param    String  -m $1       Header content.
# @param    Number  -l $2       Header level (indent level).
# @param    String  -p $3       Header prefix. [>]
# @param    String  -f $4       Text color.
# @param    String  -b $5       Background color.
#*/
header() {
    { debug_off; } 2> /dev/null
    test $# -eq 0 && return 1

    local msg level prefix fcol bcol content
    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -m|-h|--msg|--message|--header)   
                    msg="${2}" 
                    shift 2 ;;

                -l|--level|--lev) 
                    level="${2}" 
                    shift 2 ;;

                -f|--fg|--foreground)    
                    fcol="${2}" 
                    shift 2 ;;

                -b|--bg|--background)    
                    bcol="${2}" 
                    shift 2 ;;

                -p|--prefix)    
                    prefix="${2}" 
                    shift 2 ;;

                *) shift
            esac
        done
    else
        msg="${1}"
        level="${2}"
        prefix="${3}"
        fcol="${4}"
        bcol="${5}"
    fi
  
    test -z "${prefix}" && prefix='>'

    if [[ ${level} =~ ^[1-9][0-9]*$ ]]; then
        while test ${level} -gt 0; do
            content+="${prefix}"
            let level-=1
        done
    else
        content="${prefix}"
    fi

    content+=" ${msg}"

    # Background color.
    if test -n "${bcol}"; then
        _set_color -b "${bcol}"
        declare -i length=$(($(tput cols) - ${#content}))

        # Text color.
        test -n "${fcol}" && _set_color -f "${fcol}"

        while test ${length} -gt 0; do
            content+=' '
            let length-=1
        done

        echo "${content}"
        _set_color

    # Text color.
    elif test -n "${fcol}"; then
        _set_color -f "${fcol}"
        echo "${content}"
        _set_color

    # Text in the default color.
    else
        echo "${content}"
    fi

    { debug_on; } 2> /dev/null
}


# STATUS MESSAGES

#/**
# Print the success message in green.
#
# @param    String  -m $1       Message to print.
# @param    String  -t $2       The tag.
#*/
success() {
    { debug_off; } 2> /dev/null

    test -z "$1" && return 1

    local tag= msg=

    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -t|--tag)
                    if test -z "${2}" || test "${2:0:1}" = '-'; then
                        tag='OK'
                    else
                        tag=${2} 
                        shift
                    fi
                    ;;

                -m|--msg)
                    msg=${2} 
                    shift ;;
            esac
            
            shift 
        done

        result -m "${msg}" -t "${tag}" -f green
    elif test $# -eq 2; then
        result -m "${1}" -t "${2}" -f green 
    else
        result -m "$*" -f green
    fi

    { debug_on; } 2> /dev/null
}

#/**
# Print the information message in blue.
#
# @param    String  -m $1       Message to print.
# @param    String  -t $2       The tag.
#*/
info() {
    { debug_off; } 2> /dev/null

    test -z "$1" && return 1

    local tag= msg=

    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -t|--tag)
                    if test -z "${2}" || test "${2:0:1}" = '-'; then
                        tag='II'
                    else
                        tag=${2} 
                        shift
                    fi
                    ;;

                -m|--msg)
                    msg=${2} 
                    shift ;;
            esac
            
            shift 
        done

        result -m "${msg}" -t "${tag}" -f blue
    elif test $# -eq 2; then
        result -m "${1}" -t "${2}" -f blue 
    else
        result -m "$*" -f blue
    fi

    { debug_on; } 2> /dev/null
}

#/**
# Print the warning message in yellow.
#
# @param    String  -m $1       Message to print.
# @param    String  -t $2       The tag.
#*/
warning() {
    { debug_off; } 2> /dev/null

    test -z "$1" && return 1

    local tag= msg=

    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -t|--tag)
                    if test -z "${2}" || test "${2:0:1}" = '-'; then
                        tag='WW'
                    else
                        tag=${2} 
                        shift
                    fi
                    ;;

                -m|--msg)
                    msg=${2} 
                    shift ;;
            esac
            
            shift 
        done

        result -m "${msg}" -t "${tag}" -f yellow
    elif test $# -eq 2; then
        result -m "${1}" -t "${2}" -f yellow 
    else
        result -m "$*" -f yellow
    fi

    { debug_on; } 2> /dev/null
}

#/**
# Print the error message in red.
#
# @param    String  -m $1       Message to print.
# @param    String  -t $2       The tag.
#*/
error() {
    { debug_off; } 2> /dev/null

    local tag= msg=

    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -t|--tag)
                    if test -z "${2}" || test "${2:0:1}" = '-'; then
                        tag='!!'
                    else
                        tag=${2} 
                        shift
                    fi
                    ;;

                -m|--msg)
                    msg=${2} 
                    shift ;;
            esac
            
            shift 
        done

        result -m "${msg}" -t "${tag}" -f red
    elif test $# -eq 2; then
        result -m "${1}" -t "${2}" -f red 
    else
        result -m "$*" -f red
    fi

    { debug_on; } 2> /dev/null
}

#/**
# Print the fatal error message in red.
# 
# It terminates the script immediately.
#
# @param    String  -m $1       Message to print.
# @param    String  -t $2       The tag.
#*/
fatal() {
    { debug_off; } 2> /dev/null

    if test -z "${1}"; then
        if is_function 'err_get'; then
            local msg=$(err_get) 
            test -n "${msg}" \
                && textln -m "${msg}" -b RED -f white \
                || return 1
        fi
    fi

    local tag= msg=

    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -t|--tag)
                    if test -z "${2}" || test "${2:0:1}" = '-'; then
                        tag='!!'
                    else
                        tag=${2} 
                        shift
                    fi
                    ;;

                -m|--msg)
                    msg=${2} 
                    shift ;;
            esac
            
            shift 
        done

        result -m "${msg}" -t "${tag}" -f white -b RED
    elif test $# -eq 2; then
        result -m "${1}" -t "${2}" -f white -b RED 
    else
        result -m "$*" -f white -b RED
    fi

    exit 1
    { debug_on; } 2> /dev/null
}


# TASK PROGRESS & RESULT

#/**
# Print a progress (step) of the task.
#
# It starts printing at the beginning of the line. The cursor returns to the starting position.
# When the task is finished you should move to the next line using one of the functions: `result()`, `textln()` or just `echo` command.
#
# Examples:
#   progress -m 'First step' -i 1 -n 10 -t      # [ 1/10 ] First step
#   progress -m 'Second step' -i 2 -n 10 -s     # > 2/10: Second step
#   progress -m 'Third step' -i 3 -n 10 -p      # > 30%: Third step
#   progress -m 'Fourth step' -i 4 -n 10 -b     # [################                        ] Fourth step
#   progress -m 'Fifth step' -i 5 -n 10 -S      # [ - ] Fifth step
# 
# @param    String  -m $1       Message content.
# @param    String     $2       The output format:
#                   -t  i:N         Tag:            [ i/N ] <msg>
#                   -s  i/N         Step:           > i / N: <msg>
#                   -p  i%N         Percent:        > i%: <msg>
#                   -b  i#N         Progress bar:   [####      ] <msg>
#                   -S  /           Spinner:        [ / ] <msg>
# @param    String  -f $3       Text color.
# @param    Number  -n          Maximum of steps.
# @param    Number  -i          The current step.
#*/
progress() {
    { debug_off; } 2> /dev/null

    test -z "${1}" && return 1

    local content msg val max=100 kind fcol
    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -m|--msg|--message)       
                    msg="${2}" 
                    shift 2 ;;

                -f|--fg|--foreground)        
                    fcol="${2}" 
                    shift 2 ;;

                -i|--index|--value|--val)   
                    val="${2}" 
                    shift 2 ;;

                -n|--max)           
                    max="${2}" 
                    shift 2 ;;

                -s) kind=step 
                    shift ;;

                -t) kind=tag 
                    shift ;;

                -p) kind=perc 
                    shift ;;

                -b) kind=bar 
                    shift ;;

                -S) kind=spinner
                    shift ;;

                *) shift
            esac
        done
    elif test -n "${2}"; then
        msg="${1}"
        local _format_step='^[0-9]+/[0-9]+$'
        local _format_tag='^[0-9]+:[0-9]+$'
        local _format_perc='^[0-9]+%[0-9]+$'
        local _format_perc2='^[0-9]+%$'
        local _format_bar='^[0-9]+#[0-9]+$'
        local _format_bar2='^[0-9]+#$'

        # i/N (step)
        #   > i/N: <msg>
        if [[ $2 =~ ${_format_step} ]]; then
            kind=step
            val=${2%%/*}
            max=${2##*/}

        # i:N (tag)
        #   [ i:N ] <msg>
        elif [[ $2 =~ ${_format_tag} ]]; then
            kind=tag
            val=${2%%:*}
            max=${2##*:}

        # i%N (perc)
        #   > i%: <msg>
        elif [[ $2 =~ ${_format_perc} ]]; then
            kind=perc
            val=${2/\%*/}
            max=${2/*\%/}

        # i% (perc)
        #   > i%: <msg>
        elif [[ $2 =~ ${_format_perc2} ]]; then
            kind=perc
            val=${2/\%/}
            max=100

        # i#N (bar)
        #   [#####       ] <msg>
        elif [[ $2 =~ ${_format_bar} ]]; then
            kind=bar
            val=${2/\#*/}
            max=${2/*\#/}

        # i# (bar)
        #   [#####       ] <msg>
        elif [[ $2 =~ ${_format_bar2} ]]; then
            kind=bar
            val=${2/\#/}
            max=100

        # / (spinner)
        #   [ / ] <msg>
        elif [ "${2}" == '/' ]; then
            kind=spinner

        # * (text)
        #   <msg>
        else
            kind=text
            val="${2}"
        fi
    else
        msg="${1}"
    fi


    case ${kind} in
        step)   content="> ${val}/${max}: ${msg}" ;;
        tag)    content="[ ${val}/${max} ] ${msg}" ;;
        perc)   val=$((${val} * 100 / ${max}))
                test ${val} -gt 100 && val=100

                content="> ${val}%: ${msg}"
                ;;

        bar)    test ${max} -eq 0 && max=100
                test ${val} -gt ${max} && val=100

                content='['
                local num=$((${val} * 40 / ${max}))
                test ${num} -gt 40 && num=40

                declare -i i=0
                while test ${i} -lt ${num}; do
                    content+='#'
                    let i=$((i + 1))
                done

                i=${num}
                while test ${i} -lt 40; do
                    content+=' '
                    let i=$((i + 1))
                done

                content+="] ${msg}"
                ;;

        spinner) 
            if test -z "${_SPINNER_}"; then
                _SPINNER_='-'
            elif test "${_SPINNER_}" == '-'; then
                _SPINNER_='\'
            elif test "${_SPINNER_}" == '\'; then
                _SPINNER_='|'
            elif test "${_SPINNER_}" == '|'; then
                _SPINNER_='/'
            elif test "${_SPINNER_}" == '/'; then
                _SPINNER_='-'
            fi

            content="[ ${_SPINNER_} ] ${msg}"
            ;;

        text)   
            test -n "${val}" \
                && content="> ${val}: ${msg}" \
                || content="> ${msg}" 
            ;;

        *)   
            content="> ${msg}" ;;
    esac

    _ansi_sequence '0G' '2K'

    if test -n "${fcol}"; then
        _set_color -f "${fcol}"
        echo -n "${content}"
        _set_color
    else
        echo -n "${content}"
    fi

    _ansi_sequence '0G' 
    
    { debug_on; } 2> /dev/null
}

#/**
# Print the result of the task.
# 
# Result format: [ {tag} ] {msg}
#                > {msg}
#
# @param    String  -m $1       The result message content.
# @param    String  -f $2       Tag/message color.
# @param    String  -b $3       Background color.
# @param    String  -t $4       The tag. If empty, the tag will be omitted.
#*/
result() {
    { debug_off; } 2> /dev/null

    test -z "${1}" && return 0

    local type=$(scrmethod)
    
    # The script is running by user - print information to the standard output.
    if test "${type}" = 'user'; then
        _ansi_sequence '0G' '2K'
        if test "${1:0:1}" = '-'; then
            textln "$@" -p '> '
        elif test $# -ge 4; then
            textln "${1}" "${2}" "${3}" '' "${4}"
        else
            textln "$@"
        fi

    # The script is running by system/cron - print information to the logfile and XMessageBox.
    else
        # The script is running by system - print information to the logfile and XMessageBox.
        if test "${type}" = 'system'; then
            ansi_state 0
            _ansi_sequence '0G' '2K'
            if test "${1:0:1}" = '-'; then
                textln "$@" -p '> '
            elif test $# -ge 4; then
                textln "${1}" "${2}" "${3}" '' "${4}"
            else
                textln "$@"
            fi
        fi

        local msg= fcol= tag= icon=

        if test "${1:0:1}" == '-'; then
            while test -n "${1}"; do
                case ${1} in
                    -f|--fg|--foreground) 
                        fcol=${2} 
                        shift 2 ;;

                    -m|--msg|--message) 
                        msg=${2} 
                        shift 2 ;;

                    -t|--tag) 
                        tag=${2} 
                        shift 2 ;;

                    *) shift
                esac
            done
        else
            msg="${1}" 
            fcol="${2}" 
            tag="${4}"
        fi
        
        # [FIXIT]
        # Find icon name.
#        if test -n "${tag}"; then
#            case ${tag^^} in
#                ERR|ERROR|EE|'!!')          icon='dialog-error' ;;
#                WARN|WARNING|WW|'##')       icon='dialog-warning' ;; 
#                INFO|INFORMATION|II|'ii')   icon='dialog-information' ;;
#                SUCC|SUCCESS|OK|'++')       icon='gtk-apply' ;;
#            esac
#        elif test -n "${fcol}"; then
#            case ${fcol} in
#                red|RED)        icon='dialog-error'; tag='EE' ;;
#                yellow|YELLOW)  icon='dialog-warning'; tag='WW' ;;
#                blue|BLUE)      icon='dialog-information'; tag='II' ;;
#                green|GREEN)    icon='gtk-apply'; tag='OK' ;;
#            esac
#        fi

        # [FIXIT]
        # Find the parent processes.
#        local pstree=()
#        local ppid=${PPID}
#        local pspath=

#        while test ${ppid} != 0 -a -r /proc/${ppid}/status; do
#            pstree+=(${ppid})
#            ppid=$(grep PPid /proc/${ppid}/status | cut -d ':' -f 2 | tr -d '\t ')
#        done

#        for p in $(printf '%s\n' "${pstree[@]}" | tac | tr '\n' ' '); do
#            pspath+="$(cat /proc/${p}/comm)[${p}]->"
#        done
        
#        pspath+="$(scr)"
#        pspath+=":${BASH_LINENO[1]}"

        pspath="$(scr):${BASH_LINENO[1]}"
        test -n "${tag}" && tag="${pspath} [ ${tag} ]" || tag="${pspath}"
        
        logger -t "${tag}" "${msg}"
    fi

    { debug_on; } 2> /dev/null
}


# INPUT DATA

#/**
# Confirm the task execution. 
#
# If it is run in the terminal (interactive mode) the confirmation message is printed to `stdout`. 
# To confirm the action, press the 'y' key. Only then the function returns true.
# For non-interactive mode (e.g: keybinding in X session, running from cron) it tries to use the external shell script named `confirmbox.sh` 
# that should bring up a GUI confirmation dialog.
#
# @param    String     $1       Confirmation question.
# @return                       Operation status.
#*/
confirm() {
    { debug_off; } 2> /dev/null
    
    local type=$(scrmethod) answer=
    test $# -gt 0 && local msg="$*" || local msg='execute?'

    case ${type} in
        user)   
            text -m "${msg} [y/n]: "
            { read -s -n 1 answer; } 2> /dev/null
            { debug_on; } 2> /dev/null
            { [[ ${answer} =~ [yt] ]]; } 2> /dev/null
            ;;
            
        system)
            is_command confirmbox.sh || return 1

            confirmbox.sh -m "${msg}" 2> /dev/null
            answer=$?
            
            { debug_on; } 2> /dev/null
            { test ${answer} -eq 0; } 2> /dev/null
            ;;

        *)
            { debug_on; } 2> /dev/null
            ;;
    esac
}

#/**
# Gets information from the user. 
#
# If it is run in the terminal (interactive mode) data is read from `stdin`.
# Otherwise (e.g: keybinding in X session, running from cron) it tries to use the external shell script named `inputbox.sh` 
# that should bring up a GUI input dialog.
#
# @param    String     $1       Message content.
#*/
input() {
    { debug_off; } 2> /dev/null
    
    local type=$(scrmethod) answer=
    local msg="$*"

    case ${type} in
        user)   
            read -p "${msg}: " answer
            { debug_on; } 2> /dev/null
            echo ${answer}
            ;;
            
        system)
            is_command inputbox.sh || return 1

            inputbox.sh -m "${msg}"
            
            { debug_on; } 2> /dev/null
            ;;
            
        *)
            { debug_on; } 2> /dev/null
            ;;
    esac
}

#/**
# Get the password for the user. 
#
# If it is run in the terminal (interactive mode) password is read from `stdin`.
# Otherwise (e.g: keybinding in X session, running from cron) it tries to use the external shell script named `passwordbox.sh` 
# that should bring up a GUI input dialog.
#
# @param    String  -m $1       Message content.
#*/
password() {
    { debug_off; } 2> /dev/null
    
    local type=$(scrmethod) answer=
    local msg="$*"

    case ${type} in
        user)   
            read -s -p "${msg}: " answer
            { debug_on; } 2> /dev/null
            echo ${answer}
            ;;
            
        system)
            is_command inputbox.sh || return 1

            inputbox.sh -p -m "${msg}" 
            
            { debug_on; } 2> /dev/null
            ;;
            
        *)
            { debug_on; } 2> /dev/null
            ;;
    esac
    
    # Add new line after reading the password.
    echo > /dev/stderr
}

# CURSOR

#/**
# Move the cursor to the specified coordinates.
# 
# @param    Number  $1      Column number. Negative value means column from the right side of the terminal.
# @param    Number  $2      Row number. If empty means current row.
#*/
cursor_move() {
    { debug_off; } 2> /dev/null

    test -z "${1}" && { debug_on; return 1; } 2> /dev/null

    local col=${1}
    local row=${2}

    if [[ ${col} =~ ^-?[1-9][0-9]*$ ]]; then
        if test ${col} -lt 0; then
            local term_cols=$(tput cols)
            col=$(($term_cols - ${col/-/}))
        fi
    else
        col=0
    fi


    if [[ ${row} =~ ^[1-9][0-9]*$ ]]; then
        _ansi_sequence "${row};${col}H"
    else
        _ansi_sequence "${col}G"
    fi;
    
    { debug_on; } 2> /dev/null
}

#/**
# Move the cursor to the previous line(s).
# 
# @param    Number  $1      Number of lines to jump [1].
#*/
cursor_up() {
    { debug_off; } 2> /dev/null
    _ansi_sequence "${1:-1}A"
    { debug_on; } 2> /dev/null
}

#/**
# Move the cursor to the next line(s).
# 
# @param    Number  $1      Number of lines to jump [1].
#*/
cursor_down() {
    { debug_off; } 2> /dev/null
    _ansi_sequence "${1:-1}B"
    { debug_on; } 2> /dev/null
}

#/**
# Move the cursor to the previous column(s).
# 
# @param    Number  $1      Number of columns to jump [1].
#*/
cursor_left() {
    { debug_off; } 2> /dev/null
    _ansi_sequence "${1:-1}D"
    { debug_on; } 2> /dev/null
}

#/**
# Move the cursor to the next column(s).
# 
# @param    Number  $1      Number of columns to jump [1].
#*/
cursor_right() {
    { debug_off; } 2> /dev/null
    _ansi_sequence "${1:-1}C"
    { debug_on; } 2> /dev/null
}


# EXTRA FUNCTIONS

#/**
# Print formatted text.
#
# It converts convenient-to-use sequences into the raw ANSI control sequences.
# 
# Supported sequences:
#           %~              Work directory.
#           %{nl}           New line.
#
#       Clear the line
#           %{clb}          Clear the line from the cursor to the beginning.
#           %{cle}          Clear the line from the cursor to the end.
#           %{cl}           Clear the whole line.

#           %{csb}          Clear the screen from the cursor to the beginning.
#           %{cse}          Clear the screen from the cursor to the end. 
#           %{cs}           Clear the whole screen.
#
#       Navigate
#           %{home}         Move the cursor to the 1:1 coordinates.
#           %{moveC}        Move the cursor to the specified column in the current row.
#           %{gotoL:C}      Move the cursor to the specified coordinates.
#           %{upN}          Move the cursor to the previous line.
#           %{downN}        Move the cursor to the next lien.
#           %{leftN}        Move the cursor to the previous column.
#           %{rightN}       Move the cursor to the next column.
#
#       Attributes
#           %{reset}        Reset all attributes.
#           %{fgNNN}        Set font color from 256-color palette.
#           %{nofg}         Set font color to default.
#
#           %{bgNNN}        Set background color from 256-color palette.
#           %{nobg}         Set default background color.
#
#           %{bold}         Enable text-bold.
#           %{nobold}       Disable text-bold.
#
#           %{underline}    Enable text-underline.
#           %{nounderline}  Disable text-underline.
#
#           %{blink}        Enable text-blinking.
#           %{noblink}      Disable text-blinking.
#
#           %{inverse}      Enable reverse colors.
#           %{noinverse}    Disable reverse colors.
#
# @param    String  $1      Text to convert.
# @return   Number          Operation status.
#*/
echof() {
    {
    test -z "${1}" && return 1

    local cwd=$(pwd)
    [[ ${cwd} == ${HOME} ]] && cwd=\~

    local line="$(echo "$*" | sed -r 's@%~@'${cwd}'@g;
                                  s@%\{nl\}@\\n@g;
                                  s@%\{home\}@\\e[H@g;
                                  s@%\{move([0-9]*)\}@\\e[\1G@g;
                                  s@%\{goto([0-9]*):([0-9]*)\}@\\e[\1;\2H@g;
                                  s@%\{up([0-9]*)\}@\\e[\1A@g;
                                  s@%\{down([0-9]*)\}@\\e[\1B@g;
                                  s@%\{right([0-9]*)\}@\\e[\1C@g;
                                  s@%\{left([0-9]*)\}@\\e[\1D@g;
                                  s@%\{tab\}@\t@g;

                                  s@%\{cle\}@\\e[0K@g;
                                  s@%\{clb\}@\\e[1K@g;
                                  s@%\{cl\}@\\e[2K@g;

                                  s@%\{cse\}@\\e[0J@g;
                                  s@%\{csb\}@\\e[1J@g;
                                  s@%\{cs\}@\\e[2J@g;

                                  s@%\{reset\}@\\e[0m@g;
                                  s@%\{fg([^\}]*)\}@\\e[3\1m@g; 
                                  s@%\{bfg([^\}]*)\}@\\e[9\1m@g; 
                                  s@%\{xfg([^\}]*)\}@\\e[38;5;\1m@g; 
                                  s@%\{(no)?fg\}@\\e[39m@g; 

                                  s@%\{bg([^\}]*)\}@\\e[4\1m@g;
                                  s@%\{bbg([^\}]*)\}@\\e[10\1m@g;
                                  s@%\{xbg([^\}]*)\}@\\e[48;5;\1m@g;
                                  s@%\{(no)?bg\}@\\e[49m@g;

                                  s@%\{bold\}@\\e[1m@g;
                                  s@%\{nobold\}@\\e[21m@g;

                                  s@%\{underline\}@\\e[4m@g;
                                  s@%\{nounderline\}@\\e[24m@g;

                                  s@%\{blink\}@\\e[5m@g;
                                  s@%\{noblink\}@\\e[25m@g;

                                  s@%\{inverse\}@\\e[7m@g;
                                  s@%\{noinverse\}@\\e[27m@g;')"

    echo -en "${line}"; } 2> /dev/null
}

#/**
# Set verbose mode for all printing functions like `text()`, `success()`, etc.
#
# If verbose mode is active, printing functions add extra information before the proper message.
#
# @param    $1              Verbose level:
#               0|-             Disable verbose mode.
#               t|time          Show time & message.
#               d|date          Show date & message.
#               dt|datetime     Show date, time & message.
#               td|timedate     Show time, date & message.
#*/
verbose_mode() {
    _VERBOSE_MODE=$1
}

#/**
# Set the output file descriptor fot the ANSI control sequences.
#
# In non-interactive mode, all ANSI sequences are removed automatically. 
# If you want to do the same in interactive mode you can use this function.
# 
# @param    Boolean $1      The file descriptor for the ANSI control sequences.
#                       1       Redirect to the /dev/stdout (use ANSI sequences).
#                       !1      Redirect to the /dev/null (skip ANSI sequences).
#*/
ansi_state() {
    {
    if test -n "$1" -a "${1}" == "1"; then
        _TERM_COLORS=stdout
    else
        _TERM_COLORS=null
    fi; } 2> /dev/null
}


# PRIVATE HELPERS.

#/**
# Print an raw ANSI control sequence.
#
# @param    String  $1      ANSI control sequence.
#*/
_ansi_sequence() {
    while test -n "${1}"; do
#        echo -en "\x1b[${1}" >/dev/${_TERM_COLORS}
        echo -en "\e[${1}" >/dev/${_TERM_COLORS}
        shift 1
    done
}

#/**
# Change the font/background color.
# 
# You can change the colors by their names or numbers.
# The lowercase name indicates the standard color, uppercase name - bright color. 
# 
# @param    String  -f $1   Font color.
# @param    String  -b $2   Background color.
#*/
_set_color() {
    test $# -eq 0 && _ansi_sequence '0m' && return 0

    local fcol bcol
    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -f|--fg|--foreground) 
                    fcol="${2}" 
                    shift 2 ;;

                -b|--bg|--background) 
                    bcol="${2}" 
                    shift 2 ;;

                *) shift
            esac
        done
    else
        fcol=${1}
        bcol=${2}
    fi

    if test -n "${fcol}"; then
        case ${fcol} in
            black)      fcol=0 ;;

            red)        fcol=1 ;;
            green)      fcol=2 ;;
            yellow)     fcol=3 ;;
            blue)       fcol=4 ;;
            purple)     fcol=5 ;;
            cyan)       fcol=6 ;;
            white)      fcol=7 ;;
            reset)      fcol=0 ;;

            BLACK)      fcol=8 ;;
            RED)        fcol=9 ;;
            GREEN)      fcol=10 ;;
            YELLOW)     fcol=11 ;;
            BLUE)       fcol=12 ;;
            PURPLE)     fcol=13 ;;
            CYAN)       fcol=14 ;;
            WHITE)      fcol=15 ;;
            RESET)      fcol=0 ;;
            *)          [[ ${fcol} =~ ^[0-9]+$ ]] || fcol=0 ;;
        esac

        _ansi_sequence "38;5;${fcol}m"
    fi

    if test -n "${bcol}"; then
        case ${bcol} in
            black)      bcol=0 ;;

            red)        bcol=1 ;;
            green)      bcol=2 ;;
            yellow)     bcol=3 ;;
            blue)       bcol=4 ;;
            purple)     bcol=5 ;;
            cyan)       bcol=6 ;;
            white)      bcol=7 ;;

            BLACK)      bcol=8 ;;
            RED)        bcol=9 ;;
            GREEN)      bcol=10 ;;
            YELLOW)     bcol=11 ;;
            BLUE)       bcol=12 ;;
            PURPLE)     bcol=13 ;;
            CYAN)       bcol=14 ;;
            WHITE)      bcol=15 ;;
            *)          [[ ${bcol} =~ ^[0-9]+$ ]] || bcol=0 ;;
        esac

        _ansi_sequence "48;5;${bcol}m"
    fi
}

#/**
# Generate the date/time marker.
# It depends on verbose mode.
#
# @return                   Generated date/time marker.
#*/
_dt() {
    case ${_VERBOSE_MODE} in
        t|time)         echo -n "$(date +'%H:%M:%S') " ;;
        d|date)         echo -n "$(date +'%Y-%m-%d') " ;;
        dt|datetime)    echo -n "$(date +'%Y-%m-%d %H:%M:%S') " ;;
        td|timedate)    echo -n "$(date +'%H:%M:%S %Y-%m-%d') " ;;
    esac
}


# INITIALIZE

echo3_init() {
    # Output to the control sequences.
    # In the interactive mode use /dev/stdout otherwise use /dev/null.
    test -t 1 \
        && _TERM_COLORS=stdout \
        || _TERM_COLORS=null

    return 0
}

