#/**
# Language management.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
#
# ---
#
# The interface for managing the language data in bash scripts.
#
# [DEPENDENCIES] 
# conf library
# 
# It based on the `conf` library mechanism.
#
# The language data are stored in extra INI files instead of being hardcoded in a proper shell script.
# 
# The root directory for the language files is:
# ${SHELL_LANGDIR}/${LC_MESSAGES}
# 
# The language file name is:
# <name>.lang.ini
#
# In short:
#   lang_load     Load the language data from the file.
#   lang_get      Print the language variable.
#   lang_set      Set the language variable value.
# 
# 
# Example:
#
# --- ${SHELL_LANGDIR}/foobar.lang.ini ---
# [app]
# name      = What is the name?
# started   = Application started at %s by %s
# stopped   = Application stopped at %s by %s
# 
# [account]
# type = Account type is %s
# hello = Hello %s
#
# --- foobar.sh ---
# . ${SHELL_BOOTSTRAP}
# lib lang 
#
# lang_load 'foobar'
# lang_get 'app:name'               # it produces: What is the name?
# lang_get 'account:hello' Foo      # it produces: Hello Foo
#*/

#/**
# Load the language data from the file. 
#
# When you specify only the name of the language file, it will try to load it like below:
# ${SHELL_LANGDIR}/${LC_MESSAGES}/{name}.lang.ini
#
# @param    String  $1      The language file name. You can pass the absolute path to the file or only the name.
# @param    String  $2      The section name [DEFAULT].
# @return   Number          Operation status.
lang_load() {
    { 
    local lang_source=${1}
    local section=${2}

    if test -z "${lang_source}"; then
        echo "No lang file name"
        return 1
    fi

    local lang_fpath=${lang_source}
    ! test -f "${lang_fpath}" && lang_fpath=${SHELL_LANGDIR}/${LC_MESSAGES}/${lang_source/.*/}.lang.ini
    ! test -f "${lang_fpath}" && lang_fpath=${SHELL_LANGDIR}/default/${lang_source/.*/}.lang.ini
    ! test -f "${lang_fpath}" && lang_fpath=${lang_source}.lang.ini

    if ! test -f "${lang_fpath}"; then
        echo "No lang file ${lang_fpath}"
        return 2
    fi

    conf_load "${lang_fpath}" "${section}" '@LANG'
    return $?; } 2> /dev/null
}

#/**
# Print the language variable.
#
# The language variable can be parametrized. You can put the parameters as arguments starting by the second one.
# There is a shorter version of this function. Instead `lang_get` you can use `@`.
# Example:
#
# -- foobar.lang.ini:
# [account]
# hello = Hello %s
# 
# -- foobar.sh
# ..
# lang_get 'account:hello' 'Foo'    # it produces: Hello Foo
# 
# @param    String  $1      The language variable in format [section:]key.
# @param    String  $2+     Extra parameters for the language variable.
# @return   Number          Operation status.
#*/
lang_get() {
    {
    if conf_is "$1" '@LANG'; then
        conf_get "$@" '@LANG'
    else
        echo $1
        return 1
    fi; } 2> /dev/null
}

#/**
# Set the value of the language variable.
#
# @param    String  $1      The language variable name in format [section:]key.
# @param    String  $2      The language variable value.
# @return   Number          Operation status.
#*/
lang_set() {
    {
    conf_set "$1" "$2" '@LANG'
    local ret=$?
    if test ${ret} -ne 0; then
        return ${ret}
    else
        echo 1 > /dev/null
    fi; } 2> /dev/null
}

#/**
# Wrapper for the `lang_get()` function.
#*/
@() {
    { lang_get $*; } 2> /dev/null
}

#/**
# Initialize the library.
#*/
lang_init() {
    {
    lib conf 

    test -n "${1}" && lang_load "${1}"
    
    local lang_fpath=${SHELL_LANGDIR}/${LC_MESSAGES}/core.lang.ini 
    test -f ${lang_fpath} && lang_load ${lang_fpath}

    if test "${1}" != ''; then
        lang_fpath=${SHELL_LANGDIR}/${LC_MESSAGES}/${1/.*/}.lang.ini
        ! test -f ${lang_fpath} && lang_fpath=${SHELL_LANGDIR}/default/${1/.*/}.lang.ini

        test -f ${lang_fpath} && lang_load ${lang_fpath}
    fi
        
    return 0; } 2> /dev/null
}

