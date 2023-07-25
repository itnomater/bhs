#!/bin/bash

#/**
# Test colors from 256-color palette.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

#/**
# Print the content in the specyfic color (Foreground or background).
#
# @param    String      $1      Which color to use?
#                           fg      Text color.
#                           bg      Background color.
# @param    Number      $2      Starting color.
# @param    Number      [$3]    End color.
#*/
function main() {
    local scope=${1}
    local color_begin=${2}
    local color_end=${3}
    local _LOREM='vehicula pellentesque aptent nulla litora sapien lacinia natoque volutpat aliquam commodo rhoncus sociis condimentum penatibus hendrerit quam congue consectetur consequat conubia convallis cras cubilia cum curabitur curae cursus dapibus diam dictum dictumst dignissim dis dolor donec dui duis efficitur egestas eget eleifend elementum elit enim erat eros est et etiam eu euismod ex facilisi facilisis fames faucibus felis fermentum feugiat finibus fringilla fusce gravida'
    
    test -z "${color_begin}" && help && return 1
    ! [[ ${color_begin} =~ ^[0-9]+$ ]] && help && return 2

    test -n "${scope}" -a "${scope}" = 'bg' \
        && scope=48 \
        || scope=38

    test -z "${color_end}" && color_end=${color_begin}
    while test ${color_begin} -le ${color_end}; do
        echo -e "\x1b[${scope};5;${color_begin}m${color_begin}: ${_LOREM}"
        let color_begin++
    done
}

#/**
# Show help.
#*/
help() {
    echo "syntax: $0 <type: fg|bg> <color_min> [<color_max>]"
}


main "$@"

