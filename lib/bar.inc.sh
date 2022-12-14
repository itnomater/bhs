#/**
# Generate a text based progress bar using UTF8 characters. 
# You can generate a vertical bar (one character) or horizontal bar (20 characters).
#*/

#/**
# Draw the horizontal progress bar.
#
# Example:
#   echo "30%: $(bar_draw_horizontal 30)"       # 30% [██████              ]
#
# @param    Number  $1      Progress in percent.
# @param    String  $2      Use a frame?
#               noframe|false|0       Do not use a frame.
#               *                     Use a frame.
# @param    String  $3      Use a color?
#               nocolor|false|0       Do not use a color.
#               *                     Use a color.
#*/
function bar_draw_horizontal() {
    #             0  1 2 3 4 5
    local HBARS=(' ' ▎ ▍ ▋ ▊ █)

    local val=${1%%.*}
    [[ ${val} =~ ^[0-9]+$ ]] || val=0
    test ${val} -lt 0 && val=0
    test ${val} -gt 100 && val=100
    
    local use_frame=1
    case ${2} in
        noframe|false|0)    
            use_frame=
            ;;
    esac

    local use_color=1
    case ${3} in
        nocolor|false|0)
            use_color=
            ;;
    esac

    local num=$(echo "${val} / 5" | bc)
    local ext=$(echo "${val} % 5" | bc)
    local max=$((20 - ${num}))

    test -n "${use_frame}" && echo -n '['
    test -n "${use_color}" && echo -en "\x1b[38;5;$(bar_get_color $(bar_get_index ${val}))m"
  
    while test ${num} -gt 0; do 
        echo -n "${HBARS[5]}"
        ((num--))
    done
    
    if test ${max} -ne 0; then
        echo -n "${HBARS[${ext}]}"

        test -n "${use_color}" && echo -en '\x1b[0m'
        while test ${max} -gt 1; do 
            echo -n ' '
            ((max--))
        done
    elif test -n "${use_color}"; then
        echo -en '\x1b[0m'
    fi

    test -n "${use_frame}" && echo -n ']'
}

#/**
# Draw the vertical progress bar.
#
# Example:
#   echo "30%: $(bar_draw_vertical 30)"         # 30%: [▂]
# 
# @param    Number  $1      Progress in percent.
# @param    String  $2      Use a frame?
#               noframe|false|0       Do not use a frame.
#               *                     Use a frame.
# @param    String  $3      Use a color?
#               nocolor|false|0       Do not use a color.
#               *                     Use a color.
#*/
function bar_draw_vertical() {
    local val=${1%%.*}
    [[ ${val} =~ ^[0-9]+$ ]] || val=0
    test ${val} -lt 0 && val=0
    test ${val} -gt 100 && val=100
    
    local use_frame=1
    case ${2} in
        noframe|false|0)    
            use_frame=
            ;;
    esac

    local use_color=1
    case ${3} in
        nocolor|false|0)
            use_color=
            ;;
    esac

    local index=$(bar_get_index ${val})
    
    test -n "${use_frame}" && echo -n '['
    test -n "${use_color}" && echo -en "\x1b[38;5;$(bar_get_color ${index})m"
    bar_get_symbol ${index}
    test -n "${use_color}" && echo -en '\x1b[0m'
    test -n "${use_frame}" && echo -n ']'
}

# HELPER FUNCTIONS.

#/**
# Get the index of the SCOPES array by the percentage value.
# Because UTF8 vertical bar characters are limited to 8 I split 100% scale to 20 parts. One step is 5%.
# 
# Example:
#   bar_get_index 1         # Print 1
#   bar_get_index 11        # Print 3
#   bar_get_index 58        # Print 11
# 
# @param    $1          The level progress from the range: <0-100>.
#*/
function bar_get_index() {
    #                     0    5  10   15   20   25   30   35   40   45   50   55   60   65   70   75   80   85   90   95  100%
    #                     0    1  2    3    4    5    6    7    8    9    10   11   12   13   14   15   16   17   18   19  20
    local SCOPES=(       \     5  10   15   20   25   30   35   40   45   50   55   60   65   70   75   80   85   90   95  101)
    local percentage=${1:-0}
    [[ ! ${percentage} =~ ^[0-9]+$ ]] && percentage=0

    for i in {1..20}; do
        test ${SCOPES[$i]} -gt ${percentage} && break
    done

    echo ${i}
}

#/**
# Get the UTF8 character represent a progress. 
# Because UTF8 vertical bar characters are limited to 8 I split 100% scale to 20 parts. One step is 5%.
# 
# Example:
#   bar_get_symbol 1         # Print ' '
#   bar_get_symbol 11        # Print '▄'
#   bar_get_symbol 16        # Print '▆'
# 
# @param    $1          The index of the BARS array element from the range: <1-20>.
#*/
function bar_get_symbol() {
    #                     0    5   10   15   20   25   30   35   40   45   50   55   60   65   70   75   80   85   90   95  100%
    #                     0    1   2    3    4    5    6    7    8    9    10   11   12   13   14   15   16   17   18   19  20
    local BARS=(         \    \    ▁    ▁    ▁    ▂    ▂    ▂    ▃    ▃    ▄    ▄    ▅    ▅    ▅    ▅    ▆    ▆    ▆    ▇    █)
    local i=${1:-1}
    [[ ${i} =~ ^[0-9]+$ ]] || i=1
    local symbol=${BARS[$i]}
    test -n "${symbol}" && echo -n "${symbol}" || echo -n ' '
}

#/**
# Get the number of color from the COLORS array. It uses a 256-color terminal. The colors are correspond to the progress value.
# Because UTF8 vertical bar characters are limited to 8 I split 100% scale to 20 parts. One step is 5%.
# 1. Less values means a light colors like lime, green, blue.
# 2. Middle values means like yellow, orange.
# 3. High value means dark colors like dark orange, dark red.
# 
# Examples:
#   bar_get_color 3         # Print '82' (light green).
#   bar_get_color 11        # Print '220' (light yellow).
#   bar_get_color 16        # Print '202' (dark orange).
#   bar_get_color 19        # Print '124' (dark red).
#   bar_get_color 19 json   # Print 'af0000' (dark red).
# 
# @param    $1          The index of the COLORS array.
# @param    $2          Output format:
#               json        Use hexdecimal color format.
#               *           Use the color number for 256-terminal.
#*/
function bar_get_color() {
    #                    0    5   10   15   20   25   30   35   40   45   50   55   60   65   70   75   80   85   90   95  100%
    #                    0    1   2    3    4    5    6    7    8    9    10   11   12   13   14   15   16   17   18   19  20
    local COLORS=(       \    51  51   82   46   46   154  190  190  226  226  220  220  214  208  208  202  196  196  124 124)
    local i=${1:-0}
    [[ ${i} =~ ^[0-9]+$ ]] || i=0
    case ${2} in
        json)   bar_get_hex_color ${COLORS[$i]} ;;
        *)      echo ${COLORS[$i]} ;;
    esac
}

#/**
# Get the number of color from the INVCOLORS array. It uses a 256-color terminal. The colors are correspond to the progress value.
# Because UTF8 vertical bar characters are limited to 8 I split 100% scale to 20 parts. One step is 5%.
# Function works similar to `bar_get_color()` function, but colors are iverted:
# 1. Less values means dark colors like dark orange, dark red.
# 2. Middle values means like yellow, orange.
# 3. High value means a light colors like lime, green, blue.
# 
# @param    $1          The index of the INVCOLORS array.
# @param    $2          Output format:
#               json        Use hexdecimal color format.
#               *           Use the color number for 256-terminal.
#*/
function bar_get_inv_color() {
    #                    0     5  10   15   20   25   30   35   40   45   50   55   60   65   70   75   80   85   90   95  100%
    local INVCOLORS=(    \   123 124  196  196  202  208  208  214  220  220  226  226  190  190  154   46   46   82   51   51)
    local i=${1:-0}

    [[ ${i} =~ ^[0-9]+$ ]] || i=0
    case ${2} in
        json)   bar_get_hex_color ${INVCOLORS[$i]} ;;
        *)      echo ${INVCOLORS[$i]} ;;
    esac
}

#/**
# Convert color from 256-terminal value to HEX value.
# 
# @param    Number  $1      The color number in 256-terminal value.
#*/
function bar_get_hex_color() {
    case ${1} in
        123)   echo '87ffff' ;;
        124)   echo 'af0000' ;;
        154)   echo 'afff00' ;;
        190)   echo 'd7ff00' ;;
        196)   echo 'ff0000' ;;
        202)   echo 'ff5f00' ;;
        208)   echo 'ff8700' ;;
        214)   echo 'ffaf00' ;;
        220)   echo 'ffd700' ;;
        226)   echo 'ffff00' ;;
        46)    echo '00ff00' ;;
        51)    echo '00ffff' ;;
        82)    echo '5fff00' ;;
    esac
}

