#!/bin/bash

#/**
# Send a HTTP request.
#
# Project:          
# Documentation:    https://itnomater.github.io/
# Source:           https://github.com/itnomater
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
# 
# ---
#
# You can send any request using one of method:
# POST, GET, PUT or DELETE
# 
# You can also send a request in JSON format.
#
#
# Examples
# 
# Send a standard request using PUT method:
# $ http-put.sh http://domain.com/entrypoint 'foo=value with spaces' 'bar=value "with" quotes'
#
# It will perform:
#   curl --request PUT 
#        --cookie /tmp/cookie 
#        --cookie-jar /tmp/cookie 
#        --url http://domain.com/entrypoint
#        -F foo=value%20with%20spaces 
#        -F bar=value%20"%20with%20"%20qutoes
# 
#
# --
# Send a JSON request using POST method:
# $ http-json-post.sh http://domain.com/entrypoint 'foo=value with spaces' 'bar=value "with" spaces"
# 
# It will perform: 
#   curl --request POST 
#        --header 'Content-Type: application/json'
#        --cookie /tmp/cookie 
#        --cookie-jar /tmp/cookie 
#        --url http://domain.com/entrypoint 
#        --data '{"value": "value with spaces", "bar": "value \" with \" qutoes"}'
# 
# --
# You can use verbose mode to see what exactly the request is. All you need is set global variable DEBUG=1 before run this script.
# 
# For one execution:
#   DEBUG=1 http-json-post.sh http://domain.com/entrypoint foo=value bar=value
# 
# For all executions in the current terminal.
#   export DEBUG=1; 
#   http-json-post.sh http://domain.com/entrypoint foo=value bar=value
#*/

. ${SHELL_BOOTSTRAP}

help() {
    echo "Syntax:
    Send a standard HTTP request:
    http-post.sh {url} {data1} {data2} .. {data3}   - Use the POST method.
    http-get.sh {url}                               - Use the GET method.
    http-put.sh {url} {data1} {data2} .. {data3}    - Use the PUT method.
    http-delete.sh {url}                            - Use the DELETE method.
    
    Send a JSON HTTP request:
    http-json-post.sh {url} {data1} {data2} .. {data3}   - Use the POST method.
    http-json-get.sh {url}                               - Use the GET method.
    http-json-put.sh {url} {data1} {data2} .. {data3}    - Use the PUT method.
    http-json-delete.sh {url}                            - Use the DELETE method."
}

#/**
# Sent a HTTP request.
#
# @param    String      $1      Entrypoint URL address.
# @param    String      $2+     Data to send in format: key=value.
#*/
main() {
    COOKIE=/tmp/cookie

    local method=$(scrname)
    local url=${1}
    shift

    local is_json=0

    case ${method} in
        http-post)          method='POST' ;;
        http-get)           method='GET' ;;
        http-put)           method='PUT' ;;
        http-delete)        method='DELETE' ;;

        http-json-post)     method='POST'; is_json=1 ;;
        http-json-get)      method='GET'; is_json=1 ;;
        http-json-put)      method='PUT'; is_json=1 ;;
        http-json-delete)   method='DELETE'; is_json=1 ;;
        *)  # install scripts
        
            local rootdir=$(dirname $0)
            for f in post get put delete  json-post json-get json-put json-delete; do
                ! test -h ${rootdir}/http-$f.sh && ln -s $0 ${rootdir}/http-$f.sh
            done
            
            help
            
            return 0;
            ;;
    esac

    test -z "${url}" && return 1

    test "${is_json}" = '1' \
        && _request_json "${method}" "${url}" "$@" \
        || _request "${method}" "${url}" "$@"
}

#/**
# Send a HTTP request.
#
# @param    String  $1      HTTP Method:
#               post            POST
#               get             GET
#               put             PUT
#               delete          DELETE
# @param    String  $2      URL address.
# @param    String  $3+     Data to send in format: key=value each of them.
#*/
_request() {
    local method=$1
    shift

    local url=$1
    shift

    local data=()

    if test "${method}" = 'POST'; then
        while test -n "${1}"; do
            data+=('-F' "${1}")
            shift
        done
    elif test "${method}" = 'PUT'; then
        while test -n "${1}"; do
            data+=('-F' "${1}")
            shift
        done
    else # GET & DELETE
        test -n "${1}" && url+='?'
        while test -n "${1}"; do
            url+="$(_parse_field ${1})&"
            shift
        done

        # Skip the last & character.
        url=${url%&}
    fi

    if test -n "${DEBUG}"; then
    # printf produces an invalid output!?
#        printf "curl --request %s
#     --cookie %s
#     --cookie-jar %s
#     --url %s
#     %s\n" \
#     "${method}" \
#     "${COOKIE}" \
#     "${COOKIE}" \
#     "${url}" \
#     "${data[@]}" 
        echo "curl --request ${method}
     --cookie ${COOKIE}
     --cookie-jar ${COOKIE}
     --url ${url}
     ${data[@]}" 
    fi

    curl --request "${method}" \
            --cookie ${COOKIE} \
            --cookie-jar ${COOKIE} \
            --url "${url}" \
            "${data[@]}"
}

#/**
# Send a HTTP request in JSON format.
#
# @param    String  $1      HTTP Method:
#               post            POST
#               get             GET
#               put             PUT
#               delete          DELETE
# @param    String  $2      URL address.
# @param    String  $3+     Data to send.
#*/
_request_json() {
    local method=$1
    shift

    local url=$1
    shift

    local data=

    while test -n "${1}"; do
        data+="$(_parse_json_field ${1}), "
        shift
    done

    data=$(echo "$data" | sed 's@, *$@@')

    if test -n "${DEBUG}"; then
        printf "curl --request %s
     --header 'Content-Type: application/json' 
     --cookie %s
     --cookie-jar %s
     --url %s 
     --data '{%s}'\n" \
                 "${method}" \
                 "${COOKIE}" \
                 "${COOKIE}" \
                 "${url}" \
                 "${data}"
    fi

    curl --request "${method}" \
     --header 'Content-Type: application/json' \
     --cookie ${COOKIE} \
     --cookie-jar ${COOKIE} \
     --url "${url}" \
     --data "'{${data}}'"
}


# HELPER FUNCTIONS.

#/**
# Encode the string as URL characters.
# 
# @param    String  $1      Input string.
#*/
_urlencode() {
    local t=$*
    if [[ ${t} =~ [\]\[\ \'\#\$%\&\+,\\:\;=\?@^!\{\}\<\>\|/\~\`\"] ]]; then
        t="${t//\%/%25}"        # It have to substitute at first.
        t="${t// /%20}"
        t="${t//!/%21}"
        t="${t//\"/%22}"
        t="${t//\#/%23}"
        t="${t//$/%24}"
        t="${t//\&/%26}"
        t="${t//\'/%27}"
        t="${t//(/%28}"
        t="${t//)/%29}"
        t="${t//\*/%2A}"
        t="${t//+/%2B}"
        t="${t//,/%2C}"
        t="${t//\//%2F}"
        t="${t//\:/%3A}"
        t="${t//\;/%3B}"
        t="${t//</%3C}"
        t="${t//\=/%3D}"
        t="${t//>/%3E}"
        t="${t//\?/%3F}"
        t="${t//\@/%40}"
        t="${t//\[/%5B}"
        t="${t//\\/%5C}"
        t="${t//\]/%5D}"
        t="${t//^/%5E}"
        t="${t//\{/%7B}"
        t="${t//|/%7C}"
        t="${t//\}/%7D}"
#        t="${t//\~}/%7E}"
#        t="${t//\`}/%60}"
    fi

    echo ${t}
}

#/**
# Parse field content in format:
#
# key=value
#
# to URL encoded version like:
# 
# key=$(_urlencode value)
#
# @param    String  $1      Input string in format key=value.
#*/
_parse_field() {
    local field=$*
    local key="${field/=*}"
    local val="${field/*=}"
    
    printf '%s=%s' "${key}" "$(_urlencode ${val})"
}

#/**
# Parse field content in format:
#
# key=value
#
# to JSON encoded version like:
#
# "key": "value"
#
# @param    String  $1      Input string in format key=value.
#*/
_parse_json_field() {
    local field=$*
    local key=${field/=*}
    local val=${field/*=}

    printf '"%s": "%s"' "${key}" "${val//\"/\\\"}"
}

_tests() {
    _test_urlencode
}

_test_urlencode() {
    local a=" '#$%&+,\\:;=?@[]!^<>{}|/\`\~"
    local i=0
    local max=${#a}

    while test $i -lt $max; do
        echo "${a:${i}:1} =>" $(_urlencode "${a:${i}:1}") 
        let i++
    done
}

test -n "${TEST}" && _tests || main "$@"

