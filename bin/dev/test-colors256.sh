#!/bin/bash

#/**
# Print 256-color palette.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

#/**
# Print colors
#
# @param    String  $1      What colors to print.
#               base|16         Only 16 base colors.
#               extra|216       Extra 216 colors (only if the terminal support 256-colors).
#               gray            24 grayscale colors (only if the terminal supports 256-colors).
#               {empty}|all     Print all 256 colors.
#*/
main() {
    case ${1} in
        base|16)    colors_base ;;
        extra|216)  colors_extra ;;
        gray)       colors_gray ;;
        all|*)      colors_base
                    colors_extra
                    colors_gray
                    ;;
    esac
}

#/**
# Print 16 base colors.
#*/
colors_base() {
    local c= p= o=

    echo 'Basic colors:'
    for o in 0 8; do
        for p in {0..1}; do
            for c in {0..7}; do
                echo -en "\x1b[38;5;$((240 + o + c));48;5;$((o + c))m$(color ${p} $((o + c)) )"
            done

            echo -e "\x1b[0m"
        done
    done
}

#/**
# Print 216-colors palette.
# 
# 6 boxes of 6x6 colors.
#*/
colors_extra() {
    local o=16 r= g= b= p= fg=
    local cnum=$(tput cols)
    local rnum=1 r0=0 r1=2
    
    if test ${cnum} -gt 80; then
        rnum=0
        r0=0 
        r1=5
    fi

    echo 'Extra colors:'

    for row in $(eval echo "{0..${rnum}}"); do
        for g in {0..5}; do         # green..
            for p in {0..1}; do         # color height..
                for r in $(eval echo "{${r0}..${r1}}"); do         # red..
                    for b in {0..5}; do         # blue..
                        fg=232
                        case ${r} in
                            0)  test ${g} -lt 5 && fg=255 ;;
                            1)  test ${g} -lt 4 && fg=255 ;;
                            2)  test ${g} -lt 3 && fg=255 ;;
                            3)  test ${g} -lt 2 && fg=255 ;;
                            4)  test ${g} -lt 1 && fg=255 ;;
                            5)  test ${g} -lt 0 && fg=255 ;;
                        esac

                        echo -en "\x1b[38;5;${fg};48;5;$((o + r * 36 + g * 6 + b))m$(color ${p} $((o + r * 36 + g * 6 + b)))"
                    done

                    echo -en '\x1b[0m  '
                done

                echo -e "\x1b[0m"
            done
        done
        
        echo 
        r0=3
        r1=5
    done
}

#/**
# Print 24-color grayscale palette.
#*/
colors_gray() {
    local p= c= o=
    local cnum=$(tput cols)
    local rnum=1 r0=232 r1=243
    
    if test ${cnum} -gt 80; then
        rnum=0
        r0=232 
        r1=255
    fi

    echo 'Grayscale colors:'
    for row in $(eval echo "{0..${rnum}}"); do
        for p in {0..1}; do
            for c in $(eval echo "{${r0}..${r1}}"); do
                echo -en "\x1b[38;5;$((c + 12));48;5;${c}m$(color ${p} ${c})"
            done
            
            echo -e '\x1b[0m'
        done
        
        r0=244 
        r1=255
    done
}

color() {
    local visible=${1}
    local cc=${#2}
    local pad='       '
    test "${visible}" = '0' \
        && echo "${2}${pad:0:$((4-cc))}" \
        || echo "${pad:0:4}"
}


main "$@"

