#!/bin/bash

#/**
# Test 16-palette terminal colors.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

. ${SHELL_BOOTSTRAP}

#/**
# @param    String  $1      How to print the colors?
#               [names]         Print names.
#               ansi            Print ANSI codes.
#*/
main() {
    lib echo3

    declare -A _labels
    _labels[dark]="Dark (default) background."
    _labels[light]="Light background."
    _labels[ansi]="Light background."
    _colors=(black red green yellow blue purple cyan white)
    _COLORS=(BLACK RED GREEN YELLOW BLUE PURPLE CYAN WHITE)

    local mode=${1:-names}

    colors_group dark ${mode}
    test "${mode}" = 'names' && colors_group light ${mode} || true
}

#/**
# Print the color name (value) with pad to 10 characters.
#*/
item() {
    local length=${#1}
    local padlength=${2:-10}
    local pad='                                                                                                                                     '
    echo "${1}${pad:0:$((padlength-length))}"
}

#/**
# @param    String  $1      The colors group: light or dark.
# @param    String  $2      The background colors group: light or dark.
# @param    Number  $3      The background color number.
# @param    String  $4      How to print the colors?
#               names           Print names.
#               ansi            Print ANSI codes.
#*/
colors_row() {
    local grp=${1} bggrp=${2} bg=${3:-0} mode=${4:-names} sufix= label= c=

    if test -z "${grp}" -o "${grp}" = 'dark'; then
        local cc=(${_colors[@]}) 

        if test "${mode}" = 'ansi'; then
            label=$((40 + bg))
        elif test "${bggrp}" = 'dark'; then
            label=${_colors[$bg]}
            bg=${_colors[$bg]}
        else
            label=${_COLORS[$bg]}
            bg=${_COLORS[$bg]}
        fi
    else
        local cc=(${_COLORS[@]})

        if test "${mode}" = 'ansi'; then
            label=$((40 + bg))
            sufix=';1' 
        elif test "${bggrp}" = 'dark'; then
            label=${_colors[$bg]}
            bg=${_colors[$bg]}
        else
            label=${_COLORS[$bg]}
            bg=${_COLORS[$bg]}
        fi

    fi

    text -m "$(item ${label})" -f ${bg}

    for c in {0..7}; do
        test "${mode}" = 'ansi' && label="$((30 + c))${sufix}" || label="${cc[$c]}${sufix}"
        text -f ${cc[$c]} -b ${bg} -m "$(item ${label})"
    done

    echo
}

#/**
# @param    String  $1      The colors group: light or dark.
# @param    String  $2      How to print the colors?
#               names           Print names.
#               ansi            Print ANSI codes.
colors_group() {
    local grp=${1} mode=${2:-names} c= 
    test -z ${grp} -o "${grp}" = 'dark' && local cc=(${_colors[@]}) || local cc=(${_COLORS[@]})
    textln -m "${_labels[$grp]}"

    for c in {0..7}; do
        colors_row dark ${grp} ${c} ${mode}
        colors_row light ${grp} ${c} ${mode}
    done
}

main "$@"

