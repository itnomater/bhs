#!/bin/bash

#/**
# Test whiptail command abilities.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#*/

. ${SHELL_BOOTSTRAP}

main() {
    export NEWT_COLORS='
    root=black,blue
    roottext=white,blue

    window=black,white
    title=red,white
    border=black,white
    shadow=white,blue

    textbox=black,white
    acttextbox=red,green

    button=white,red
    actbutton=red,black
    compactbutton=blue,white

    listbox=black,white
    actlistbox=white,blue
    actsellistbox=white,red

    checkbox=black,white
    actcheckbox=white,red

    entry=white,blue
    disentry=white,green

    sellistbox=green,blue
    label=green,red

    emptyscale=white,blue
    fullscale=white,red

    helpline=red,green
    '

    local item
    local is_active=1
    local __ANSWER_FILE=/tmp/answer
    ! which whiptail > /dev/null && 'Command whiptail not found' && return 1

    echo 1 > ${__ANSWER_FILE}
    while [ ${is_active} -eq 1 ]; do
        item=$(cat ${__ANSWER_FILE})
        echo > ${__ANSWER_FILE}
        whiptail    --default-item ${item} \
                    --backtitle 'Whiptail test' \
                    --title 'Whiptail test' \
                    --menu "Select Widget:" 19 40 11 \
                        1 'Back Title' \
                        3 'Message Box' \
                        4 'Yes No' \
                        5 'Gauge' \
                        6 'Menu' \
                        7 'Check List' \
                        8 'Radio List' \
                        9 'Input Box' \
                        10 'Password Box' \
                        11 'Text Box' \
                        2> ${__ANSWER_FILE}

        item=$(cat ${__ANSWER_FILE})
        if [ "${item}" != '' ]; then 
            _item ${item} 
        else 
            is_active=0
        fi
    done
}

_item() {
    case ${1} in
        1)  whiptail    --backtitle "Back Title: whiptail --backtitle 'BackTitle' <height> <width>" \
                        --msgbox "backtitle" \
                        5 30  \
                        2> /dev/null
                        ;;

        # TODO ???
        2)  whiptail    --backtitle "Info Box: --title 'Info Box' --infobox 'infobox' <height> <width>" \
                        --title 'Info Box' \
                        --infobox 'infobox' \
                        7 30 \
                        2> /dev/null
                        ;;

        3)  whiptail    --backtitle "Message Box: --title 'Message Box' --msgbox 'msgbox' <height> <width>" \
                        --title 'Message Box' \
                        --msgbox 'msgbox' \
                        7 30 \
                        2> /dev/null
                        ;;

        4)  whiptail   --backtitle "Yes No: --title 'Yes No' --yesno 'yesno' <height> <width>" \
                        --title 'Yes No' \
                        --yesno 'yesno' \
                        7 30 \
                        2> /dev/null
                        ;;

        5)  for f in {0..10}; do
                echo $((${f} * 10))
                sleep 0.11 
            done | whiptail   --backtitle "Gauge: --title 'Gauge' --gauge 'gauge' <height> <width> <percent>" \
                        --title 'Gauge' \
                        --gauge "gauge" \
                        7 30 73 \
                        2> /dev/null
                        ;;

        6)  whiptail    --backtitle "Menu: --title Menu --menu <title> <height> <width> <menu-height> [<tag> <item>]" \
                        --title 'Menu' \
                        --menu 'menu' 12 30 5 \
                            1 'first value' \
                            2 'second value' \
                            3 'third value' \
                            4 'fourth value' \
                            5 'fifth value' \
                            6 'sixth value' \
                            7 'seventh value' \
                            2> /dev/null
                        ;;

        7)  whiptail    --backtitle "Check List: --title 'Check List' --checklist <title> <height> <width> <list-height> [<tag> <item> <status>]" \
                        --title 'Check List' \
                        --checklist "checklist" 12 30 5 \
                            1 'first value' on \
                            2 'second value' off \
                            3 'third value' off \
                            4 'fourth value' off \
                            5 'fifth value' on \
                            6 'sixth value' off \
                            7 'seventh value' on \
                        2> /dev/null
                        ;;

        8)  whiptail    --backtitle "Radio List: --title 'Radio List' --radiolist <title> <height> <width> <list-height> [<tag> <item> <status>]" \
                        --title 'Radio List' \
                        --radiolist "radiolist" 12 30 5 \
                            1 'first value' off \
                            2 'second value' off \
                            3 'third value' off \
                            4 'fourth value' on \
                            5 'fifth value' off \
                            6 'sixth value' off \
                            7 'seventh value' off \
                        2> /dev/null
                        ;;

        9) whiptail     --backtitle "Input Box: --title 'Input Box' --inputbox 'inputbox' <height> <width> [<init>]" \
                        --title 'Input Box' \
                        --inputbox 'inputbox' \
                        8 40 'content' \
                        2> /dev/null
                        ;;

        10) whiptail    --backtitle "Password Box: --title 'Password Box' --passwordbox 'passwordbox' <height> <width> [<init>]" \
                        --title 'Password Box' \
                        --passwordbox 'passwordbox' \
                        8 40 'content' \
                        2> /dev/null
                        ;;

        11) whiptail    --backtitle "Text Box: --title 'Text Box' --title 'textbox' --textbox <path_to_file> <height> <width>" \
                        --title 'textbox' \
                        --textbox '/etc/passwd' \
                        20 40 \
                        2> /dev/null
                        ;;
    esac
}

main

