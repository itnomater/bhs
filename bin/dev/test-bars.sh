#!/bin/bash

#/**
# Testing for progress bars from bar library.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

. ${SHELL_BOOTSTRAP}

lib bar

i=0
for ff in {0..9}; do
    for f in {0..9}; do
        index=$(bar_get_index $i)
        color=$(bar_get_color $index)
        symbol=$(bar_get_symbol $index)
        echo -en "$i [\x1b[38;5;${color}m${symbol}\x1b[0m]\t"
        let i++
    done
    echo
done

