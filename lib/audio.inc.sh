#/**
# Helper functions to control the audio. 
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
# 
# It is a wrapper for amixer shell command.
#/

audio_user_commands() {
    echo amixer
}

#    audio_init() {
#    which amixer > /dev/null && return 0 || return 1
#}

#/**
# Set audio volume level.
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
# Get audio volume level.
#
# @return           Audio volume level in percent.
#*/
audio_get() {
    amixer get Master,0 | grep 'Front Left:' | sed -r 's@^.*\[([0-9]+)%\].*$@\1@'
}

#/**
# Increase audio volume level.
#
# @param    $1      Percentage of audio volume level to increase.
#*/
audio_up() {
    local vol=${1:-1}
    [[ ${vol} =~ ^[0-9]+$ ]] || return 1
    test ${vol} -lt 0 -o ${vol} -gt 100 && return 2

    amixer -q set Master,0 ${vol}%+
}

#/**
# Decrease the audio volume level.
#
# @param    $1      Percentage of audio volume level to decrease.
#*/
audio_down() {
    local vol=${1:-1}
    [[ ${vol} =~ ^[0-9]+$ ]] || return 1
    test ${vol} -lt 0 -o ${vol} -gt 100 && return 2

    amixer -q set Master,0 ${vol}%-
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
# Toggle audio muted state.
#*/
audio_toggle() {
    amixer set Master,0 toggle > /dev/null
}

#/**
# Check audio muted state.
# 
# @return       Mute state:
#                   0   - muted.
#                   1   - unmuted.
#*/
audio_check() {
    local state=$(amixer get Master,0 | grep 'Front Left: ' | sed -r 's@^.*\[(.*)\]$@\1@')
    test "${state}" == 'on' && return 0 || return 1 
}

