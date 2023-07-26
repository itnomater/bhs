#!/bin/bash

#/**
# Monitoring directory changes.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
# 
# ---
#
# Example:
#
# test-directory.sh .
#
# It uses inotifywait command to monitor a directory.
# When an event occurs, it displays information like below:
# 
#        event time
#        |
# [ ++ ] 23:59:59: foo bar
#   |              |
#   |              file name
#   tag format:
#       ++  - file was modified.
#       <<  - file was created.
#       xx  - file was removed.
#*/

. ${SHELL_BOOTSTRAP}
  
#/**
# Monitoring directory changes.
# 
# @param    String      $1      Directory path. As default is current directory.
# @param    String      $2      Event separated by a comma.
#*/
main() {
    local path=${1:-.}
    local events=${2:-create,delete,modify}

    lib echo3
    lib dt

    while true; do 
        notify $(inotifywait --format '%e %f' -r -e ${events} ${path} 2> /dev/null)
    done
}

notify() {
    local action=$(echo $* | cut -d ' ' -f 1)
    local path=$(echo $* | sed -r 's@^[^ ]+ @@')
    local dt=$(dt_time)

    case ${action} in
        CREATE)     result -t '>>' -m "${dt}: ${path}" -f green ;;
        DELETE)     result -t 'xx' -m "${dt}: ${path}" -f red ;;
        MODIFY)     result -t '++' -m "${dt}: ${path}" -f blue ;;
    esac
}

main $*

