#/**
# Helper functions to control the audio. 
#*/

audio_init() {
    which amixer > /dev/null && return 0 || return 1
}

#/**
# Set the audio volume level.
#
# @param    $1      Audio volume level in percent.
#*/
audio_set() {
    local vol=${1:-0}
    [[ ${vol} =~ ^[0-9]+$ ]] || return 1
    test ${vol} -lt 0 -o ${vol} -gt 100 && return 2

    amixer -q set Master,0 ${1}%
}

#/**
# Get the audio volume level.
#
# @return           Audio volume level in percent.
#*/
audio_get() {
    amixer get Master,0 | grep 'Front Left:' | sed -r 's@^.*\[([0-9]+)%\].*$@\1@'
}

#/**
# Increase the audio volume level.
#
# @param    $1      The value to increase the audio volume in percent.
#*/
audio_up() {
    local vol=${1:-0}
    [[ ${vol} =~ ^[0-9]+$ ]] || return 1
    test ${vol} -lt 0 -o ${vol} -gt 100 && return 2

    amixer -q set Master,0 ${1}%+
}

#/**
# Decrease the audio volume level.
#
# @param    $1      The value to decrease the audio volume in percent.
#*/
audio_down() {
    local vol=${1:-0}
    [[ ${vol} =~ ^[0-9]+$ ]] || return 1
    test ${vol} -lt 0 -o ${vol} -gt 100 && return 2

    amixer -q set Master,0 ${1}%-
}

#/**
# Mute audio.
#*/
audio_mute() {
    amixer set Master,0 mute > /dev/null
}

#/**
# Unmute audio.
#*/
audio_unmute() {
    amixer set Master,0 unmute > /dev/null
}

#/**
# Toggle the audio mute state.
#*/
audio_toggle() {
    amixer set Master,0 toggle > /dev/null
}

#/**
# Check the audio mute state.
# 
# @return       Mute state:
#                   0   - muted.
#                   1   - unmuted.
#*/
audio_check() {
    local state=$(amixer get Master,0 | grep 'Front Left: ' | sed -r 's@^.*\[(.*)\]$@\1@')
    test "${state}" == 'on' && return 0 || return 1 
}

