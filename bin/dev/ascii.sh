#!/bin/bash

#/**
# Print ASCII character by its code number.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

#/**
# Print ASCII character by its code number.
# 
# You can pass multiple chararters. For example:
# ./ascii.sh A 0x42 67
# A: 0x41 (65)
# B: 0x42 (66)
# C: 0x43 (67)
#
# @param    Character   $1+ ASCII character (number) to print.
#*/
main() {
    while test -n "$1"; do
        dump_char $1
        shift
    done
}

#/**
# Print help.
#*/
help() {
    echo "syntax $0 <a-zA-Z|decimal|hexdecimal>"
}

#/**
# Print character in format:
# {character}: {hexdecimal} ({decimal})
# 
#
# @param    Character       $1  Character to print. You can use single character or its ASCII number (decimal or hexdecimal).
#*/
dump_char() {
    if [[ $1 =~ ^[a-zA-Z]$ ]]; then
        local c=$1
        local h=$(echo -n $c | xxd -p | tr [:lower:] [:upper:])
        local d=$(echo -e "obase=10\nibase=16\n$h" | bc)
    elif [[ $1 =~ ^[0-9]{1,3}$ ]]; then
        local d=$1
        local h=$(echo -e "obase=16\nibase=10\n$d" | bc)
        local c=$(echo -en "\x$h")
    elif [[ $1 =~ ^0?x[0-9a-fA-F]{1,2}$ ]]; then
        local h=$(echo -n "$1" | awk -Fx '{print $2}' | tr [:lower:] [:upper:])
        local d=$(echo -e "obase=10\nibase=16\n$h" | bc)
        local c=$(echo -en "\x$h")
    else
        help
        exit 1
    fi
    
    echo "$c: 0x$h ($d)"
}

main "$@"

