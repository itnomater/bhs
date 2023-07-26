#!/bin/bash

#/**
# Test dialog command abilities.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#
# ---
#
# Options:
# 
#   extra elements:
#       --backtitle - Screen header
#       --title     - Widget title
#       --hline     - Widget footer
#       --insecure  - show asterisks in password box instead none
# 
#       --no-ok     - hide OK button
#       --no-cancel - hide CANCEL button
#       --no-tags   - hide TAGS column
#       --no-items  - hide ITEMS column
# 
#       --no-lines  - hide all lines
#       --no-shadow - hide widget shadow
#       --no-mouse  - disable mouse events
#       --scrollbar - show scrollbar in scrollable widgets
#
#   default elements:
#       --defaultno         - preselect NO button as default
#       --default-button    - preselect custom button as default
#       --default-item      - preselect custom item in list/menu/checklist/etc as default
# 
#   override labels in buttons:
#       --ok-label
#       --yes-label
#       --no-label
#       --cancel-label
#       --exit-label
#       --extra-label
#*/

. ${SHELL_BOOTSTRAP}

main() {
    local item
    local is_active=1
    local __ANSWER_FILE=/tmp/answer

    
    ! which dialog > /dev/null && echo 'Command dialog not found' && return 1
    echo 1 > ${__ANSWER_FILE}
    while [ ${is_active} -eq 1 ]; do
        item=$(cat ${__ANSWER_FILE})
        echo > ${__ANSWER_FILE}
        dialog --default-item ${item} \
            --backtitle 'Dialog test' \
            --no-lines \
            --menu "Select Widget:" 32 40 30 \
                    1 'Back Title' \
                    2 'Info Box' \
                    3 'Message Box' \
                    4 'Yes No' \
                    5 'Gauge' \
                    6 'Menu' \
                    7 'Input Menu' \
                    8 'Check List' \
                    9 'Radio List' \
                    10 'Build List' \
                    11 'Range Box' \
                    12 'Directory Select' \
                    13 'File Select' \
                    14 'Tree View' \
                    15 'Input Box' \
                    16 'Password Box' \
                    17 'Edit Box' \
                    18 'Text Box' \
                    19 'Tail Box' \
                    20 'Program Box' \
                    21 'Progress Box' \
                    22 'Pause' \
                    23 'Calendar' \
                    24 'Time Box' \
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
        1)  dialog  --backtitle "Back Title" \
                    --msgbox "-- backtitle" \
                    5 30  \
                    2> /dev/null
                    ;;

        2)  dialog  --backtitle "Info Box" \
                    --title 'Info Box' \
                    --infobox '-- infobox' \
                    5 30 \
                    2> /dev/null
                    sleep 2
                    ;;

        3)  dialog  --backtitle "Message Box" \
                    --title 'Message Box' \
                    --msgbox '-- msgbox' \
                    5 30 \
                    2> /dev/null
                    ;;

        4)  dialog  --backtitle "Yes No" \
                    --title 'Yes No' \
                    --yesno '-- yesno' \
                    5 30 \
                    2> /dev/null
                    ;;

        5)  for f in {0..10}; do
                echo $((${f} * 10))
                sleep 0.11
            done | dialog  --backtitle "Gauge" \
                    --title 'Gauge' \
                    --gauge "-- gauge" \
                    7 30 73 \
                    2> /dev/null
                    ;;

        6)  dialog  --backtitle "Menu" \
                    --title 'Menu' \
                    --menu '-- menu' 12 30 73 \
                        1 'first value' \
                        2 'second value' \
                        3 'third value' \
                        4 'fourth value' \
                        5 'fifth value' \
                        6 'sixth value' \
                        7 'seventh value' \
                        2> /dev/null
                    ;;

        7)  dialog  --backtitle "Input Menu" \
                    --title 'Input Menu' \
                    --inputmenu '-- inputmenu' 12 30 73 \
                        1 'first value' \
                        2 'second value' \
                        3 'third value' \
                        4 'fourth value' \
                        5 'fifth value' \
                        6 'sixth value' \
                        7 'seventh value' \
                        2> /dev/null
                    ;;

        8)  dialog  --backtitle "Check List" \
                    --title 'Check List' \
                    --checklist "-- checklist" 12 30 73 \
                        1 'first value' on \
                        2 'second value' off \
                        3 'third value' off \
                        4 'fourth value' off \
                        5 'fifth value' on \
                        6 'sixth value' off \
                        7 'seventh value' on \
                    2> /dev/null
                    ;;

        9)  dialog  --backtitle "Radio List" \
                    --title 'Radio List' \
                    --radiolist "-- radiolist" 12 30 73 \
                        1 'first value' off \
                        2 'second value' off \
                        3 'third value' off \
                        4 'fourth value' on \
                        5 'fifth value' off \
                        6 'sixth value' off \
                        7 'seventh value' off \
                    2> /dev/null
                    ;;

        10)  dialog  --backtitle "Build List" \
                    --title 'Build List' \
                    --visit-items \
                    --buildlist "-- buildlist" 12 40 75 \
                        1 'first value' off \
                        2 'second value' off \
                        3 'third value' off \
                        4 'fourth value' on \
                        5 'fifth value' off \
                        6 'sixth value' off \
                        7 'seventh value' off \
                    2> /dev/null
                    ;;

        11) dialog  --backtitle "Range Box" \
                    --title 'Range Box' \
                    --rangebox '-- rangebox' 6 40 0 10 3 \
                    2> /dev/null
                    ;;

        12) dialog  --backtitle "Directory Select" \
                    --visit-items \
                    --title '-- dselect' \
                    --dselect '/tmp' 6 40 \
                    2> /dev/null
                    ;;

        13) dialog  --backtitle "File Select" \
                    --visit-items \
                    --title '-- fselect' \
                    --fselect '/tmp' 6 40 \
                    2> /dev/null
                    ;;

        14) dialog  --backtitle "Tree View" \
                    --title 'Tree View' \
                    --treeview '-- treeview' 20 40 70 \
                        1 'first value' off 0 \
                        2 'second value' off 0 \
                        3 'third value' off 1 \
                        4 'fourth value' on 1 \
                        5 'fifth value' off 2 \
                    2> /dev/null
                    ;;

        15) dialog  --backtitle "Input Box" \
                    --title 'Input Box' \
                    --inputbox '-- inputbox' 20 40 'content' \
                    2> /dev/null
                    ;;

        16) dialog  --backtitle "Password Box" \
                    --title 'Password Box' \
                    --passwordbox '-- passwordbox' 20 40 'content' \
                    2> /dev/null
                    ;;

        17) dialog  --backtitle "Edit Box" \
                    --title '-- editbox' \
                    --editbox '/etc/passwd' 20 40 \
                    2> /dev/null
                    ;;

        18) dialog  --backtitle "Text Box" \
                    --title '-- textbox' \
                    --textbox '/etc/passwd' 20 40 \
                    2> /dev/null
                    ;;
  
        19) dialog  --backtitle "Tail Box" \
                    --title '-- tailbox' \
                    --tailbox '/etc/passwd' 10 40 \
                    2> /dev/null
                    ;;

        20) ls | dialog  --backtitle "Program Box" \
                    --title 'Program Box' \
                    --programbox '-- programbox' 10 40 \
                    2> /dev/null
                    ;;

        21) for f in {1..10}; do 
                echo $f; sleep 0.11; 
            done | dialog  --backtitle "Progress Box" \
                    --title 'Progress Box' \
                    --progressbox '-- progressbox' 7 40 \
                    2> /dev/null
                    ;;

        22) dialog  --backtitle "Pause" \
                    --title 'Pause' \
                    --pause '-- pause' 7 40 2 \
                    2> /dev/null
                    ;;

        23) dialog  --backtitle "Calendar" \
                    --title 'Calendar' \
                    --calendar '-- calendar' 20 40 3 10 2019 \
                    2> /dev/null
                    ;;

        24) dialog  --backtitle "Time Box" \
                    --title 'Time Box' \
                    --timebox '-- timebox' 7 40 13 59 0 \
                    2> /dev/null
                    ;;

#        25) dialog  --backtitle "Form" \
#                    --title 'Form' \
#                    --form

    esac
}
    
main

