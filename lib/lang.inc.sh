#/**
# LANGUAGE MANAGEMENT.
#
# The interface for managing the language data.
#
# [DEPENDENCIES] 
# conf module
# 
# It based on the `conf` module mechanism.
#
# The language data is stored in extra INI files instead of being hardcoded in proper shell script.
# 
# The root directory for the language files is:
# ${SHELL_LANGDIR}/${LC_MESSAGES}
# 
# The language file name is:
# <name>.lang.ini
#
# In short:
#   lang_load     Load the language data.
#   lang_get      Get the language variable.
#   lang_set      Set the language variable.
# 
# 
# Example:
#
# -- foobar.lang.ini
# [app]
# name      = What is the name?
# started   = Application started at %s by %s
# stopped   = Application stopped at %s by %s
# 
# [account]
# type = Account type is %s
# hello = Hello %s
#
# -- foobar.sh
# . ${SHELL_BOOTSTRAP}
# lib lang 
#
# lang_load 'foobar'
# lang_get 'app:name'               # it produces: What is the name?
# lang_get 'account:hello' Foo      # it produces: Hello Foo
#*/

#/**
# Load the language data. When you specify only name of the language file it will try to load file:
# ${SHELL_LANGDIR}/${LC_MESSAGES}/<name>.lang.ini
#
# @param    String  $1      The language file name. You can pass the absolute path to the file or name only.
# @param    String  $2      The section name [DEFAULT].
# @return   Number          Operation status.
function lang_load() {
    { 
    local lang_source=${1}
    local section=${2}

    if test -z "${lang_source}"; then
        echo "No lang file name"
        return 1
    fi

    local lang_fpath=${lang_source}
    if ! test -f "${lang_fpath}"; then
        local lang_def=${LC_MESSAGES:-default}
        local lang_fpath=${SHELL_LANGDIR}/${lang_def}/${lang_source/.*/}.lang.ini
    fi

    ! test -f "${lang_fpath}" && lang_fpath=${lang_source}.lang.ini
    if ! test -f "${lang_fpath}"; then
        echo "No lang file ${lang_fpath}"
        return 2
    fi

    conf_load "${lang_fpath}" "${section}" 'LANG'
    return $?; } 2> /dev/null
}

#/**
# Get the language variable.
#
# If the language variable is parametrized then you put the parameters as arguments starting by 2.
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
function lang_get() {
    {
    if conf_is "$1" 'LANG'; then
        conf_get $* 'LANG'
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
function lang_set() {
    {
    conf_set "$1" "$2" 'LANG'
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
function @() {
    { lang_get $*; } 2> /dev/null
}

#/**
# Initialize the module.
#*/
function lang_init() {
    {
    lib conf 

    test -n "${1}" && lang_load "${1}"
    
    local lang_def=${LC_MESSAGES:-default}
    
    local lang_fpath=${SHELL_LANGDIR}/${lang_def}/core.lang.ini 
    test -f ${lang_fpath} && lang_load ${lang_fpath}

    if test "${1}" != ''; then
        local lang_fpath=${SHELL_LANGDIR}/${lang_def}/${1/.*/}.lang.ini
        test -f ${lang_fpath} && lang_load ${lang_fpath}
    fi
        
    return 0; } 2> /dev/null
}

