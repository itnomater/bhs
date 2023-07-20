#/**
# The helper functions to printing date and time.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

#/**
# Print the current UNIX timestamp with microseconds (four digits).
#*/
dt_microtime() {
    date +%s.%4N
}

#/**
# Print the current UNIX timestamp.
# 
# @return   Number          Operation status.
#*/
dt_timestamp() {
#    [[ "${1}" =~ ^[0-9]+$ ]] \
#        && echo $(($(printf '%(%s)T') - ${1} - 3600)) \
#        || printf '%(%s)T\n'

    printf '%(%s)T'
}

#/**
# Print the date in the specified format:
# 1.        YYYY{separator}MM{separator}DD
# 2.        YYYYMMDD
#
# @param    Number  -t  $1      The UNIX timestamp for the date. If empty it use the current timestamp.
# @param    String  -s  $2      The separator for the date fields [-].
#                   -n          Do not use the separator.
#*/
dt_date() {
    local tm sep

    if test "${1:0:1}" == '-'; then
        while test "${1}" != ''; do
            case ${1} in
                -t|--tm) 
                    tm=${2} 
                    shift ;;

                -s|--separator) 
                    sep=${2} 
                    shift ;;
                    
                -n|--noseparator) 
                    sep=
                    ;;

                *) shift
            esac
            
            shift
        done
    else
        tm=${1}
        sep=${2:--}
    fi

    ! [[ $tm =~ ^[0-9]+$ ]] && tm=

    printf "%(%Y${sep}%m${sep}%d)T\n" ${tm}
}

#/**
# Print the time in the specified format:
# 
# 1.        HH{separator}MM{separator}SS
# 2.        HHMMSS
#
# @param    Number  -t  $1      The UNIX timestamp for the date. If empty it use the current timestamp.
# @param    String  -s  $2      The separator for the time fields [:].
#                   -n          Do not use the separator.
#*/
dt_time() {
    local tm sep

    if test "${1:0:1}" == '-'; then
        while test "${1}" != ''; do
            case ${1} in
                -t|--tm) 
                    tm=${2} 
                    shift ;;

                -s|--separator) 
                    sep=${2} 
                    shift ;;
                    
                -n|--noseparator) 
                    sep=
                    ;;

                *) shift
            esac
            
            shift
        done
    else
        tm=${1}
        sep=${2:-:}
    fi

    ! [[ $tm =~ ^[0-9]+$ ]] && tm=

    printf "%(%H${sep}%M${sep}%S)T\n" ${tm}
}

#/**
# Print the date and time in specified format:
# 
# 1.        YYYY{separator1}MM{separator1}DD{separator0}HH{separator2}MM{separator2}SS
# 2.        YYYYMMDDHHMMSS
# 
# @param    Number  -t  $1      The UNIX timestamp for the date. If empty it use the current timestamp.
# @param    String  -s  $2      The separators for the fields [ -:]:
#               0                   The separator for the date and time [ ].
#               1                   The separator for the date fields [-].
#               2                   The separator for the time fields [:].
#                   -n          Do not use the separator.
#*/
dt_datetime() {
    local tm sep

    if test "${1:0:1}" == '-'; then
        while test "${1}" != ''; do
            case ${1} in
                -t|--tm) 
                    tm=${2} 
                    shift ;;

                -s|--separator) 
                    sep=${2} 
                    shift ;;
                    
                -n|--noseparator) 
                    sep=
                    ;;

                *) shift
            esac
            
            shift
        done
    else
        tm=${1}
        sep=${2:- -:}
    fi

    ! [[ $tm =~ ^[0-9]+$ ]] && tm=

    printf "%(%Y${sep:1:1}%m${sep:1:1}%d${sep:0:1}%H${sep:2:1}%M${sep:2:1}%S)T\n" ${tm}
}

#/** [DEPRECATED]
# Print the date/hour in the predefined: YYYYMMDD_HHMMSS.
#
# @param    Number  $1          The UNIX timestamp for the date. If empty it use the current timestamp.
#*/
dt_date_string() {
    [[ $1 =~ ^[0-9]+$ ]] \
        && printf '%(%Y%m%d_%H%M%S)T\n' ${1} \
        || printf '%(%Y%m%d_%H%M%S)T\n'
}

#/**
# Print the elapsed days between two dates.
# 
# @param    Number  $1          The UNIX timestamp for the first date.
# @param    Number  $2          The UNIX timestamp for the second date.    
#*/
dt_elapsed() {
    local tmbegin=${1} tmend=${2:-$(printf '%(%s)T')} 

    if [[ ${tmbegin} =~ ^[1-9][0-9]+$ ]] && [[ ${tmend} =~ ^[1-9][0-9]+$ ]]; then
        declare -i elapsed=$(($tmend - $tmbegin))
        
        if test ${elapsed} -lt 60; then
            printf "%is\n" ${elapsed}
        elif test ${elapsed} -lt 3600 ; then
            printf "%im\n" $((${elapsed} / 60))
        elif test ${elapsed} -lt 86400; then
            printf "%ih\n" $((${elapsed} / 3600))
        elif test ${elapsed} -lt 2592000; then
            printf "%iD\n" $((${elapsed} / 86400))
        elif test ${elapsed} -lt 31536000; then
            printf "%iM\n" $((${elapsed} / 2592000))
        else
            printf "%iY\n" $((${elapsed} / 31536000))
        fi
    fi
}

