#!/bin/bash

#/**
# Check if UTF-8 characters are available in the current terminal font.
#
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

. ${SHELL_BOOTSTRAP}

#/**
# Print characters from the category.
# 
# @param    String      category:
#               powerline
#               arrows
#               symbols
#               alpha
#               frames
#               blocks
# @param    Boolean     Verbose mode:
#               {empty}         Quiet mode (defualt).
#               {non-empty}     Verbose mode.
#*/
main() {
    lib echo3

    case ${1} in
        powerline)
            echo "Powerline"
            for f in {0..6}; do
                print_powerline 7 ${f} 0 
            done

            print_powerline 0 7 0 
            ;;

        alpha)      print_alpha ${2} ;;
        arrows)     print_arrows ${2} ;;
        symbols)    print_symbols ${2} ;;
        frames)     print_frames ${2} ;;
        blocks)     print_blocks ${2} ;;
        *)          help ;;
    esac
}

#/**
# Print syntax.
#*/
help() {
    echo "Syntax: $0 <powerline|alpha|arrows|symbols|frames|blocks> <verbose_mode_flag>"
}

print_array() {
    local blocks=($*)
    for b in ${blocks[*]}; do
        printf "%x" "'${b}" | xxd | awk '{print $4}' | tr -d '\n'
        echo -e "\t$b"
    done
}

#/**
# Print statusline characters. 
#
# @param    Number  $1      Text color.
# @param    Number  $2      Background color.
# @param    Number  $3      Background color 2.
#*/
print_powerline() {
    local fcol=${1}
    local bcol=${2}
    local bcol2=${3}

    local powerline="%{fg$fcol}%{bg$bcol} lorem  ipsum %{fg$bcol}%{bg$bcol2}%{fg$bcol}%{bg$bcol2} lorem %{fg$bcol2}%{nobg} " 
    powerline+="%{move40}" 
    powerline+="%{fg$bcol}%{bg$bcol2} ipsum %{fg$bcol}%{bg$bcol2}%{fg$fcol}%{bg$bcol} lorem  ipsum%{reset}"
    echof "${powerline}"
    echo
}

#/**
# Print arrows.
# 
# @param    Boolean     $1          Verbose mode.
#*/
print_arrows() {
    local data=(❬ ❭ ❮ ❯ ❰ ❱ ⟨ ⟩ ⟪ ⟫   ◀ ▶   〈 〉 « » )
    data+=(          ← ↑ → ↓ ↖ ↗ ↘ ↙ )
    data+=(↔ ↕ ↩ ↪ ↯ ↰ ↱ ↲ ↳ ↴ ↵ ↶ ↷ ↺ ↻)

    if [ -z ${1} ]; then
        echo ${data[*]}
    else
        print_array ${data[*]}
    fi
}

#/**
# Print symbols.
# 
# @param    Boolean     $1          Verbose mode.
#*/
print_symbols() {
    local data=(≡ ▦ ◷ ✔ ✘ ✕ ✖ ⌁ ⚡ ⌂ ⚐ ⚑      ﱘ               漣        ﬙       力 \
                ♔ ♕ ♖ ♗ ♘ ♙ ♚ ♛ ♜ ♝ ♞ ♟ \
                ♠ ♡ ♢ ♣ ♤ ♥ ♦ ♧)
    
    if [ -z ${1} ]; then
        echo ${data[*]}
    else
        print_array ${data[*]}
    fi
}

#/**
# Print alphanumerical characters.
# 
# @param    Boolean     $1          Verbose mode.
#*/
print_alpha() {
    local letters_lower=(a ą b c ć d e ę f g h i j k l ł m n ń o ó p q r s ś t u v w x y z ż ź)
    local letters_upper=(A Ą B C Ć D E Ę F G H I J K L Ł M N Ń O Ó P Q R S Ś T U V W X Y Z Ż Ź)
    local numbers=(0 1 2 3 4 5 6 7 8 9)
    local extra=('~' '>' '<')
                
    if [ -z ${1} ]; then
        echof "%{reset}%{nounderline}"
        echo regular
        echo ${letters_lower[*]}
        echo ${letters_upper[*]}
        echo ${numbers[*]}
        echo ${extra[*]}
        
        echof "%{reset}%{bold}"
        echo bold
        echo ${letters_lower[*]}
        echo ${letters_upper[*]}
        echo ${numbers[*]}
        echo ${extra[*]}
        
        echof "%{reset}%{underline}"
        echo underline
        echo ${letters_lower[*]}
        echo ${letters_upper[*]}
        echo ${numbers[*]}
        echo ${extra[*]}
        
        echof "%{reset}%{bold}%{underline}"
        echo bold underline
        echo ${letters_lower[*]}
        echo ${letters_upper[*]}
        echo ${numbers[*]}
        echo ${extra[*]}
    else
        print_array ${letters_lower[*]}
        print_array ${letters_upper[*]}
        print_array ${numbers[*]}
        print_array ${extra[*]}
    fi
}

#/**
# Print block characters.
# 
# @param    Boolean     $1          Verbose mode.
#*/
print_blocks() {
    local data=(▀ ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▉ ▊ ▋ ▌ ▍ ▎ ▏ ▐ ░ ▒ ▓ ▔ ▕ ◼ ◾ ▪)

    if [ -z ${1} ]; then
        echo '▁▂▃▄▅▆▇█▉     ▏▎▍▌▋▊      ▔▀▐▕    ░▒▓   ◼ ◾ ▪'
    else
        print_array ${data[*]}
    fi
}

#/**
# Print frame characters.
# 
# @param    Boolean     $1          Verbose mode.
#*/
print_frames() {
    local data=(▖ ▗ ▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟ \
                ─ ━ │ ┃ ┄ ┅ ┆ ┇ ┈ ┉ ┊ ┋ ┌ ┍ ┎ ┏ ┐ ┑ ┒ ┓ └ ┕ ┖ ┗ ┘ ┙ ┚ ┛ ├ ┝ ┞ ┟ ┠ ┡ ┢ ┣ ┤ ┥ ┦ ┧ \
                ┨ ┩ ┪ ┫ ┬ ┭ ┮ ┯ ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻ ┼ ┽ ┾ ┿ ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╌ ╍ ╎ ╏ \
                ═ ║ ╒ ╓ ╔ ╕ ╖ ╗ ╘ ╙ ╚ ╛ ╜ ╝ ╞ ╟ ╠ ╡ ╢ ╣ ╤ ╥ ╦ ╧ ╨ ╩ ╪ ╫ ╬)

    if [ -z ${1} ]; then
        echo '┌──┬──┐   ╭──┬──╮'    
        echo '│  │  │   │  │  │   ╲ ╱ '
        echo '├──┼──┤   ├──┼──┤    ╳  '    
        echo '│  │  │   │  │  │   ╱ ╲ '
        echo '└──┴──┘   ╰──┴──╯'   
        echo                                               
        echo '┏━━┳━━┓   ┍━━┯━━┑   ┎──┰──┒'
        echo '┃  ┃  ┃   │  │  │   ┃  ┃  ┃'
        echo '┣━━╋━━┫   ┝━━┿━━┥   ┠──╂──┨'
        echo '┃  ┃  ┃   │  │  │   ┃  ┃  ┃'
        echo '┗━━┻━━┛   ┕━━┷━━┙   ┖──┸──┚'
        echo
        echo '╔══╦══╗   ╒══╤══╕   ╓──╥──╖'
        echo '║  ║  ║   │  │  │   ║  ║  ║'
        echo '╠══╬══╣   ╞══╪══╡   ╟──╫──╢'
        echo '║  ║  ║   │  │  │   ║  ║  ║'      
        echo '╚══╩══╝   ╘══╧══╛   ╙──╨──╜'
        echo
        echo '╎  ┆  ┊   ╏  ┇  ┋   ╌╌╌╌╌╌╌   ▛▀▀▀▀▀▜'
        echo '╎  ┆  ┊   ╏  ┇  ┋   ┄┄┄┄┄┄┄   ▌     ▐'
        echo '╎  ┆  ┊   ╏  ┇  ┋   ╍╍╍╍╍╍╍   ▌     ▐'
        echo '╎  ┆  ┊   ╏  ┇  ┋   ┅┅┅┅┅┅┅   ▙▄▄▄▄▄▟'
    else
        print_array ${data[*]}
    fi
}


main $*

