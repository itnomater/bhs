#!/bin/bash
#/**
# Generate random data like numbers, letters, dates, logins, user names, surnames, addresses, etc.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
# 
# ---
#
# Data types:
#   numbers:
#       [+] | [#]           A record ID.
#       [digit:1]           One digit.
#       [digits:8]          Eight digits.
#       [number:100,1]      A number from range: {max:min}.
#       [decimal:4,2]       One decimal number: {base_length:decimal_length}.
#
#   strings:
#       [letter:1]          A one lowercase letter.
#       [letters:8]         Many lowercase letters.
#       [LETTER:1]          One uppercase letter.
#       [LETTERS:8]         Many uppercase letters.
#       [byte:1]            One byte from the charset: [0-9a-zA-Z].
#       [bytes:8]           Many bytes from the charset: [0-9a-zA-Z].
#       [word:1]            One word.
#       [words:8]           Many words.
#       [paras:16]          A paragraph containing X words.
#       [html:16]           A paragraph containing X words with HTML tags.
#
#   user data (personal):
#       [user_id]           Person ID in format ABC12345.
#       [name]              Person name (male or famale).
#       [fname]             Female name.
#       [mname]             Male name.
#       [surname]           Person surname.
#       [job]               Person job name.
#       [login]             User login.
#       [email]             User email.
#       [phone]             Phone number in format: ABC DEF GHI.
#
#   address data:
#       [city]              City name.
#       [street]            Street name.
#       [region]            Region name.
#       [room]              Room number.
#       [address]           Address.
#       [postcode]          Postcode in format XY-ABC.
#
#   date & time:
#       [time]              Time in format HH:MM:SS.
#       [date:365]          Date in format YYYY-MM-DD. Maximum 365 later.
#       [datetime:-14]      Date + time. Maximum 14 days back.
#    
#   extra data:
#       [hash:40]           SHA1 hash.
#       [url]               URL address.
#       [ip]                IP address.
# 
# datastring:
#   [type1] [type2] ... [typeX]
#
# datafile:
#   datastring
#*/

. ${SHELL_BOOTSTRAP}


#/**
# Script options
# 
# @param    -d      A datastring. E.g: [+] [login] [email].
# @param    -f      File path containing the datastring.
# @param    -n      Number of the records to generate.
# @param    -t      Type of the generating data (only one type).
# @param        -a      Extra arguments for data type.
# 
# Use:
#   gendata.sh -n 3 -d '[+] [login] [email]'    # Three records each containing ID, login and email address.
#   gendata.sh -n 10 -d '[words:2]'             # Ten records with two words for each.
#   gendata.sh -d '[letters]'                   # One record with 8 letters."
#   gendata.sh -t paras -a 10                   # Generate one paragraph containing ten words.
#   gendata.sh -f ./path                        # Generate data from the file containing datastring.
# 
#*/
main() {
    lib cmdline "$@"
    lib rand
    lib rand

    opt_is 'n' && local num=$(opt_get 'n') || local num=1

    # Generte only one data type.
    if opt_is 't'; then
        local type=$(opt_get 't')
        if is_function generate_${type}; then
            if test ${num} -le 1; then
                generate_${type} $(opt_get 'a')
                printf '\n'
            else
                while test ${num} -gt 0; do
                    generate_${type} $(opt_get 'a')
                    printf '\n'
                    let num--
                done
            fi
        fi

    # Generte data from stdin.
    elif opt_is 'd'; then
        local data="$(opt_get 'd')"
        parse "${data}" "${num}"

    # Generte data from the file.
    elif opt_is 'f'; then
        local fpath=$(opt_get 'f')
        if ! test -r "${fpath}"; then
            echo "File ${fpath} not found"
            return 1
        fi

        local data=$(head -n1 ${fpath})
        
        parse "${data}" "${num}"

    elif opt_is 'h'; then
        help 

    else
        help 
        return 1
    fi
}

#/**
# Show help of use.
#*/
help() {
    echo "$0 
        -t <datatype> | -d <datastring> | -f <datafilepath>
        [-n x]                      Number of the records [1].
        [-a <datatype_arguments>]   It is use only with -t option.

    datatype:
        numbers:
            [+] | [#]           A record ID.
            [digit:1]           One digit.
            [digits:8]          Many digits.
            [number:100:1]      A number from range: {max:min}.
            [decimal:4:2]       One decimal number: {base_length:decimal_length}.

        strings:
            [letter:1]          A one lowercase letter.
            [letters:8]         Many lowercase letters.
            [LETTER:1]          One uppercase letter.
            [LETTERS:8]         Many uppercase letters.
            [byte:1]            One byte from the charset: [0-9a-zA-Z].
            [bytes:8]           Many bytes from the charset: [0-9a-zA-Z].
            [word:1]            One word.
            [words:8]           Many words.
            [paras:16]          A paragraph containing X words.
            [html:16]           A paragraph containing X words with HTML tags.

        user data (personal):
            [user_id]           Person ID in format ABC12345.
            [name]              Person name (male or famale).
            [fname]             Female name.
            [mname]             Male name.
            [surname]           Person surname.
            [job]               Person job name.
            [login]             User login.
            [email]             User email.
            [phone]             Phone number in format: ABC DEF GHI.
        
        address data:
            [city]              City name.
            [street]            Street name.
            [region]            Region name.
            [room]              Room number.
            [address]           Address.
            [postcode]          Postcode in format XY-ABC.

        date & time:
            [time]              Time in format HH:MM:SS.
            [date]              Date in format YYYY-MM-DD.
            [datetime]          Date + time.
        
        extra data:
            [hash:40]           SHA1 hash.
            [url]               URL address.
            [ip]                IP address.

    datastring:
        [type1] [type2] ... [typeX]

    datafile:
        datastring

    Exammples:
        $(basename $0) -n 3 -d '[+] [login] [email]'    # Three records each containing ID, login and email address.
        $(basename $0) -n 10 -d '[words:2]'             # Ten records with two words for each.
        $(basename $0) -d '[letters]'                   # One record with 8 letters."
}

#/**
# Generate random rows in specified format.
# 
# @param    $1      Data format.
# @param    $2      Number of rows [1].
#*/
parse() {
    local row_format="${1}"
    local num=$(_intval ${2:-1})
    local line=
    local name=
    local args=
    local id=1

    while test ${num} -gt 0; do
        line="${row_format}"

        while [[ ${line} =~ \[.+\] ]]; do
            name=
            args=

            if [[ ${line} =~ \[\+\] ]]; then
                line=$(echo "${line}" | sed -r "s@\[\+\]@${id}@") 
                continue
            elif [[ ${line} =~ \[#\] ]]; then
                line=$(echo "${line}" | sed -r "s@\[#\]@${id}@") 
                continue
            elif [[ ${line} =~ \[[a-zA-Z_]+(:.*)+\] ]]; then
                name=$(echo "${line}" | sed -r "s@.*\[([^]]+):(.*)+\].*@\1:\2@")
                args=${name#*:}
                name=${name%%:*}
            elif [[ ${line} =~ \[[a-zA-Z_]+\] ]]; then
                name=$(echo "${line}" | sed -r "s@.*\[([^]]+)\].*@\1@")
            fi

            if test -n "${name}" && is_function generate_${name}; then
                test -n "${args}" \
                    && line=$(echo "${line}" | sed -r "s@\[${name}:${args}\]@$(generate_${name} ${args//[:,]/ })@") \
                    || line=$(echo "${line}" | sed -r "s@\[${name}\]@$(generate_${name})@")
            else
                test -n "${args}" \
                    && line=$(echo "${line}" | sed -r "s@\[${name}:${args}\]@@") \
                    || line=$(echo "${line}" | sed -r "s@\[${name}\]@@")
            fi

            
#        for f in ${line}; do
#            if test "${f}" = '[+]' -o "${f}" = '[#]'; then 
#                printf '%s ' ${id}
#                continue
#            elif [[ ${f} =~ ^\[[a-zA-Z_]+\]$ ]]; then
#                name=${f//[\[\]]}
#                args=
#            elif [[ ${f} =~ ^\[[a-zA-Z_]+(:.*)+\]$ ]]; then
#                name=${f//[\[\]]}
#                args=${name#*:}
#                name=${name%%:*}
#            else
#                name=
#            fi
#
#            test -n "${name}"\
#                && is_function generate_${name} && generate_${name} ${args//:/ } && printf ' ' \
#                || printf '%s ' ${f}
        done

        printf "${line}\n"

        let id++
        let num--
    done
}


# NUMBERS

#/**
# Generate a few digits.
# 
# @param    Number  $1      Number of the digits [1].
#*/
generate_digit() {
    local num=${1:-1}
    test "${num}" = '1' \
        && _get_data $(_get_digits) \
        || rand_digits ${num}
}

#/**
# Generate a random digits.
# 
# @param    Number  $1      Number of the digits [8].
#*/
generate_digits() {
    rand_digits ${1:-8}
}

#/**
# Generate a random number in specified range.
#
# @param    $1      Maximum range value [100].
# @param    @2      Minimum range value [1].
#*/
generate_number() { 
    rand_integer $*
}

#/**
# Generate a random real number.
#
# @param   $1       Number digits of integer part [4].
# @param   $2       Number digits of decimal part [2].
# @param   $3       Probability of use negative value.
#*/
generate_decimal() {
    rand_real $*
}


# LETTERS

#/**
# Generate a few lowercase letters. By default its generate only one letter.
# 
# @param    Number  $1      Number of the characters [1].
#*/
generate_letter() {
    test -z "${1}" -o "${1}" = '1' && _get_data $(_get_letters) && return 0
    generate_letters ${1}
}

#/**
# Generate a few lowercase letters. By default its generate 8 letters.
# 
# @param    Number  $1      Number of the characters [8].
#*/
generate_letters() {
    local num=${1:-8}

    while test ${num} -gt 0; do
        _get_data $(_get_letters)
        let num--
    done
}

#/**
# Generate a few uppercase letters.
# 
# @param    Number  $1      Number of the letters [1].
#*/
generate_LETTER() {
    test -z "${1}" -o "${1}" = '1' && _get_data $(_get_LETTERS) && return 0
    generate_LETTERS ${1}
}

#/**
# Generate a few uppercase letters.
# 
# @param    Number  $1      Number of the letters [8].
#*/
generate_LETTERS() {
    local num=${1:-8}

    while test ${num} -gt 0; do
        _get_data $(_get_LETTERS)
        let num--
    done
}

#/**
# Generate a random words.
# 
# @param    $1      Number of words [1].
# @param    $2      Uset HTML tags?
#*/
generate_words() {
    local num=${1:-1}
    local use_html=${2}

    local words=($(_get_ipsum))
    local tag=

    while test ${num} -gt 0; do
        tag=

        if test -n "${use_html}" && rand_probe 10; then
            if rand_probe 20; then
                tag='b'
            elif rand_probe 20; then
                tag='i'
            elif rand_probe 20; then
                tag='strong'
            elif rand_probe 20; then
                tag='abbr'
            elif rand_probe 20; then
                tag='href'
            fi
        fi

        if test -z "${tag}"; then
            printf '%s ' "$(_get_data ${words[@]})"
        else
            test "${tag}" = 'href' \
                && printf '<a href="#">%s</a>' "$(_get_data ${words[@]})" \
                || printf '<%s>%s</%s>' "${tag}" "$(_get_data ${words[@]})" "${tag}"
        fi

        let num--
    done
}

#/**
# Generate a random paragraphs.
# 
# @param    $1      Number of words in paragraph. [16].
# @param    $2      Use HTML tags?
#*/
generate_paras() {
    local num=${1:-16}
    local use_html=${2}
    local words=($(_get_ipsum))
    local i=0
    local tag=

    test -n "${use_html}" && printf '<p>'

    while test ${num} -gt 0; do 
        tag=

        if test -n "${use_html}" && rand_probe 10; then
            if rand_probe 20; then
                tag='b'
            elif rand_probe 20; then
                tag='i'
            elif rand_probe 20; then
                tag='strong'
            elif rand_probe 20; then
                tag='abbr'
            elif rand_probe 20; then
                tag='href'
            fi
        fi

        if test -z "${tag}"; then
            printf '%s ' $(_get_data ${words[@]})
        else
            test "${tag}" = 'href' \
                && printf '<a href="#">%s</a>' $(_get_data ${words[@]}) \
                || printf '<%s>%s</%s>' "${tag}" "$(_get_data ${words[@]})" "${tag}"
        fi

        let num--
    done

    test -n "${use_html}" && printf '</p>'
}

#/**
# Generate a random paragraphs with HTML tags.
# 
# @param    $1      Number of paragraphs [1].
# @param    $2      Number of words in paragraph. [16].
#*/
generate_html() {
    generate_paras "${1:-16}" '1'
}


# PEOPLE 

#/**
# Generate a random ID in format XYZ12345.
#*/
generate_user_id() {
    printf '%s%s%s%i' \
        $(generate_LETTER) $(generate_LETTER) $(generate_LETTER) \
        $(rand_digits 5)
}

#/**
# Generate a random name.
#
# @param    $1      Name for sex:
#               m       Only male names.
#               f       Only female names.
#               -       Both names.
#*/
generate_name() {
    _get_data $(_get_names ${1}) 
}

#/**
# Generate a random female name.
#*/
generate_fname() {
    generate_name 'f'
}

#/**
# Generate a random male name.
#*/
generate_mname() {
    generate_name 'm'
}

#/**
# Generate a random surname.
#*/
generate_surname() {
    _get_data $(_get_surnames) 
}

#/**
# Generate a random job name.
#*/
generate_job() {
    declare -a jobs
    _get_jobs jobs
    _get_data "${jobs[@]}"
}

#/**
# Generate a random job name.
#*/
generate_login() {
    local data=$(ps -eo ucmd | head | sort -R | tr -d ' \n/[0-9]\-_')
    local login=${data:$(rand_integer ${#data} 0):1}
    login+=$(generate_surname)

    printf '%s' "${login}" | iconv -f UTF-8 -t ANSI_X3.110 | tr [:upper:] [:lower:]
}

#/**
# Generate a random e-mail address.
#*/
generate_email() {
    printf '%s\@gmail.com' "$(generate_login)"
}

#/**
# Generate a random phone number in format AAA BBB CCC.
#*/
generate_phone() { 
    printf '%.3i %.3i %.3i' \
        $(generate_digits 3) $(generate_digits 3) $(generate_digits 3) 
}


# ADDRESS

#/**
# Generate a random city name.
#*/
generate_city() {
    declare -a cities
    _get_cities cities
    _get_data "${cities[@]}"
}

#/**
# Generate a random street name.
#*/
generate_street() {
    declare -a streets
    _get_streets streets
    _get_data "${streets[@]}"
}

#/**
# Generate a random region name.
#*/
generate_region() {
    _get_data $(_get_regions)
}

#/**
# Generate a random flat number in format xxx[/yy].
#*/
generate_room() { 
    local room=$(generate_digit)                            #  1

    rand_probe && room+=$(generate_digit)                   #  12

    if rand_probe 20; then                                  #  12?
        if rand_probe 50; then
            room+=$(generate_letter)                        #  12a
        else
            room+=$(generate_LETTER)                        #  12A
        fi
    fi

    room+='/'                                               #  12X/
    room+=$(generate_digit)                                 #  12X/3

    rand_probe 80 && room+=$(generate_digit)                #  12X/3#
    
    printf '%s' "${room}"
}

#/** 
# Generate a random address in format <street> <flat_number>.
#*/
generate_address() { 
    printf '%s %s' \
        "$(generate_street)" "$(generate_room)"
}

#/**
# Generate an post code in format XY-ABC.
#*/
generate_postcode() { 
    printf '%i%i-%i%i%i' \
        $(generate_number 9 1) $(generate_number 9 0) \
        $(generate_number 9 0) $(generate_number 9 0) $(generate_number 9 0) 
}


# DATE & TIME

#/**
# Generate a random time.
#*/
generate_time() {
    printf '%.2i:%.2i:%.2i' \
        $(generate_number 23 0) $(generate_number 59 0) $(generate_number 59 0)
}

#/**
# Generate an post code in format XY-ABC
# 
# @param    $1      Data offset in days. If null, returns 0000-00-00.
#*/
generate_date() {
    local offset=${1}

    ! [[ ${offset} =~ ^-?[0-9]+$ ]] && printf '0000-00-00' && return 0

    local tm=
    if test ${offset} -eq 0; then
        tm=$(date +%s)
    elif test ${offset} -gt 0; then
        tm=$(( $(date +%s) + (86400 * ($(rand_integer ${offset}))) + $(rand_integer 86400) ))
    elif test ${offset} -lt 0; then
        tm=$(( $(date +%s) - 86400 - (86400 * $(rand_integer ${offset/-/})) + $(rand_integer 86400) ))
    fi

    printf '%s' $(date -d @${tm} '+%Y-%m-%d')
}

#/**
# Generate random date and time.
# 
# @param    $1      Data offset in days. If null, returns 0000-00-00.
#*/
generate_datetime() {
    printf '%s %s' \
        $(generate_date ${1}) $(generate_time)
}


# DATA 

#/**
# Generate a few random bytes. By default its generate a one random byte.
# 
# @param    $1      Number of the bytes [1].
#*/
generate_byte() {
    generate_bytes ${1:-1}
}

#/**
# Generate a few random bytes. By default its generate 8 random bytes.
# 
# @param    $1      Number of the bytes [8].
#*/
generate_bytes() {
    local num=${1:-8}

    while test ${num} -gt 0; do
        if rand_probe 20; then
            printf '%s' $(generate_digit)
        elif rand_probe 50; then
            printf '%s' $(generate_letter)
        else 
            printf '%s' $(generate_LETTER)
        fi
        
        let num--
    done
}

#/**
# Generate a random hash.
#
# @param    $1      Length of hash [40].
#*/
generate_hash() {
    local length=$(_intval ${1:-40})
    test ${length} -gt 40 && length=40
    test ${length} -le 0 && length=8

    local hash=$(echo ${RANDOM} | sha1sum | cut -c -${length})
    printf '%s' ${hash}
}

#/**
# Generate a random url address.
#*/
generate_url() { 
    local url='https//www.'$(generate_words 1)
    rand_probe 10 && url+=".$(generate_words 1)"
    url+='.com'
    rand_probe 30 && url+="/$(generate_words 1)"
    rand_probe 20 && url+="/$(generate_words 1)"
    rand_probe 10 && url+="/$(generate_words 1)"
    if rand_probe 60; then
        url+="?$(generate_words 1)=$(generate_words 1)"
        rand_probe 30 && url+="\&$(generate_words 1)=$(generate_bytes 6)"
        rand_probe 20 && url+="\&$(generate_words 1)=$(generate_number)"
        rand_probe 10 && url+="\&$(generate_words 1)=$(generate_words 1)"
    fi

    printf '%s' ${url}
}

#/**
# Generate an IP address.
#*/
generate_ip() { 
    printf '%i.%i.%i.%i' \
        $(generate_number 255 0) \
        $(generate_number 255 0) \
        $(generate_number 255 0) \
        $(generate_number 255 0)
}


# HELPERS

#/**
# Get a list of lowercase letters.
#*/
_get_letters() {
    printf 'a b c d e f g h i j k l m n o p q r s t u v w x y z'
}

#/**
# Get a list of upperce letters.
#*/
_get_LETTERS() {
    printf 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'
}

#/**
# Get a list of digits.
#*/
_get_digits() {
    printf '0 1 2 3 4 5 6 7 8 9'
}

#/**
# Get a list of people names.
#
# @param    $1  Sex:
#               m   Only male names.
#               f   Only famale names.
#               -   Both male and famale names.
#*/
_get_names() {
    local which=${1:-a} 
    local males=(\
        'Alek'  'Alwin'  'Amir' 'Angelo'  'Aureliusz'  'Aylin' \
        'Brandon' \
        'Carlos' \
        'Dastin' 'Davide'  'Deniz' \
        'Edmund' 'Elif' 'Elvis'  'Erik'  'Eugeniusz' 'Euzebiusz' \
        'Fabio' 'Federico' 'Felix' 'Franek' \
        'Gaspar' 'Goran' \
        'Hektor' 'Henry' 'Hieronim' \
        'Ian' 'Ibrahim' \
        'Jack' 'Jarema' 'Jason' 'John' 'Jonas' 'Jovan' \
        'Kilian'  'Krzesimir' \
        'Lew' \
        'Marcus'  'Marko'  'Matilda'  'Megan' \
        'Oktawiusz' \
        'Paskal' \
        'Robin' \
        'Sajmon' \
        'Valentino' \
        'Wiesław' 'Wilhelm' \
    )
    
    local famales=(\
        'Adelajda' 'Aisha' 'Alessia' 'Alisa' 'Amelie' 'Ariadna' 'Arlena' 'Augustyna' 'Aurora' \
        'Balbina' 'Blanca' \
        'Carla' 'Caroline' 'Chanel' 'Chioma' \
        'Dagna' 'Debora' 'Donata' \
        'Emilie' 'Erika' \
        'Gaia' \
        'Hana' \
        'Ismena' 'Iwa' \
        'Jarema' \
        'Kira' \
        'Latika' 'Latoya' 'Leokadia' 'Leonia' 'Ligia' 'Lorena' 'Luca' 'Luna' \
        'Marieta' 'Masza' 'Matilda' 'Megan' \
        'Nadzieja' 'Nastia' 'Nikita' 'Noelia' \
        'Oxana' \
        'Pamela' \
        'Raisa' \
        'Salma' 'Scarlett' 'Sofija' \
        'Waleria' 'Wiwiana' \
    ) \

    if test "${which}" = 'm'; then 
        echo -n ${males[@]}
    elif test "${which}" = 'f'; then
        echo -n ${famales[@]}
    else
        echo -n ${males[@]} ${famales[@]}
    fi
}

#/**
# Get a list of people surnames.
#*/
_get_surnames() {
    local surnames=( \
        'Aach' \
        'Bisaga' 'Boligłowa' 'Bzibziak' \
        'Chudolej' 'Chujeba' 'Cieciński' 'Cincio' \
        'Dupajka' 'Duplaga' 'Dzierzgoniów' \
        'Fluk' \
        'Hachuj' \
        'Jakoktochce' 'Jopek' 'Jurkowski' \
        'Kusibab' 'Kurdziel' 'Kutasiewicz' 'Kutasko' 'Kwasigroch' \
        'Lapeta' 'Lejek' \
        'Machuj' 'Machujski' 'Moczygęba' 'Męczywór' 'Męka' \
        'Nieruchaj' 'Nieruchalski' 'Niewiem' \
        'Ocipka' 'Ojdana' 'Oswięcim' \
        'Padninice' 'Paskuda' 'Pała' 'Pierdas' 'Pijak' 'Pinda' 'Pokraka' 'Porąbaniec' 'Prukała' 'Psipsiński' 'Pyta' 'Pędzimąż' \
        'Rura' \
        'Siekierka' 'Sierota' 'Sikała' 'Siurek' 'Spleśniały' 'Sprzeczka' 'Starybrat' 'Strzelce' 'Student' 'Stęchły' 'Suka' 'Szaleniec' 'Szczybrocha' 'Szkodnik' 'Szmata' 'Szpara' \
        'Śmigło' 'Strzygło' \
        'Tatarata' 'Tumidaj' \
        'Wozignuj' 'Wyczesany' 'Wytrych' \
        'Zgryz' \
        'Ściera' 'Śmieć' 'Świr' \
        'Żygadło' 'Żygała' \
    )

    echo -n ${surnames[@]}
}

#/**
# Get a list of city names .
#*/
_get_cities() {
    cities=(
        'Całowanie' 'Cyców' \
        'Dziewicza Struga' \
        'Grzeczna Panna' 'Gwizd' \
        'Jęczydół' \
        'Kocury' 'Koniec Świata' 'Kozionozki' 'Krzywe Kolano' 'Kłopotowo' 'Kłopotowo' \
        'Lenie Wielkie' \
        'Męcikał' \
        'Nowe Laski' \
        'Odletajka' 'Ostatni Grosz' \
        'Piekło' 'Pieścidała' 'Psie Głowy' \
        'Rękoraj' \
        'Samogon' 'Stare Babki' 'Stolec' \
        'Tumidaj' \
        'Wielkanoc' \
        'Zimna Wódka' \
        'Złe Mięso' \
    )
}

#/**
# Get a list of street names.
#*/
_get_streets() {
    streets=(
        'Astronomów' \
        'Buraczana' \
        'Calineczki' 'Ciasna' \
        'Gazowa w dzielnicy żydowskiej' 'Gazowa' \
        'Gruszowe Sady' 'Klasztorna' \
        'Kopciuszka ' 'Królewny Śnieżki' 'Kupa' \
        'Meksyk' 'Merkurego' \
        'Misia Uszatka' 'Myszki Miki' 'Młodzieżowa' \
        'Onufrego Zagłoby' 'Ozyrysa' \
        'Pelikana' 'Poniedziałkowy Dół' 'Porannych Mgieł ' 'Pszczółki Mai' \
        'Różowa' \
        'Saperska' 'Smerfów' 'Sojowa' \
        'Zaczarowane koło' 'Zodiakalna' \
    )
}

#/**
# Get a list of region names.
#*/
_get_regions() {
    local regions=(
        'dolnośląskie' \
        'kujawsko-pomorskie' \
        'lubelskie' \
        'lubuskie' \
        'łódzkie' \
        'małopolskie' \
        'mazowieckie' \
        'opolskie' \
        'podkarpackie' \
        'podlaskie' \
        'pomorskie' \
        'śląskie' \
        'świętokrzyskie' \
        'warmińsko-mazurskie' \
        'wielkopolskie' \
        'zachodniopomorskie' \
    )

    echo -n ${regions[@]}
}

#/**
# Get a list of people jobs.
#*/
_get_jobs() {
    jobs=(
        'Coolhunter' \
        'Groomer' \
        'Gumolog' \
        'Inspektor kości do gry' \
        'Kontroler zapachów z odbytu' \
        'Licznik ryb' \
        'Malarz cytrusów' \
        'Masturbator zwierząt' \
        'Pielęgniarz drzew' \
        'Projektant sukienek dla lalek barbie' \
        'Przeżuwacz gum' \
        'Sekser' \
        'Sprzątacz Toi Toi' \
        'Tanatopraktor' \
        'Tester karmy dla zwierząt' \
        'Tester zapachów z odbytu' \
        'Upychacz pasażerów' \
    )
}

#/**
# Get a list of words.
#*/
_get_ipsum() {
    local ipsum=(
        'a' 'ac' 'accumsan' 'ad' 'adipiscing' 'aenean' 'aliquam' 'aliquet' 'amet' 'ante' 'aptent' 'arcu' 'at' 'auctor' 'augue' \
        'bibendum' 'blandit' \
        'class' 'commodo' 'condimentum' 'congue' 'consectetur' 'consequat' 'conubia' 'convallis' 'cras' 'cubilia' 'cum' 'curabitur' 'curae' 'cursus' \
        'dapibus' 'diam' 'dictum' 'dictumst' 'dignissim' 'dis' 'dolor' 'donec' 'dui' 'duis' \
        'efficitur' 'egestas' 'eget' 'eleifend' 'elementum' 'elit' 'enim' 'erat' 'eros' 'est' 'et' 'etiam' 'eu' 'euismod' 'ex' \
        'facilisi' 'facilisis' 'fames' 'faucibus' 'felis' 'fermentum' 'feugiat' 'finibus' 'fringilla' 'fusce' \
        'gravida' \
        'habitant' 'habitasse' 'hac' 'hendrerit' 'himenaeos' \
        'iaculis' 'id' 'imperdiet' 'in' 'inceptos' 'integer' 'interdum' 'ipsum' \
        'justo' \
        'lacinia' 'lacus' 'laoreet' 'lectus' 'leo' 'libero' 'ligula' 'litora' 'lobortis' 'lorem' 'luctus' \
        'maecenas' 'magna' 'magnis' 'malesuada' 'massa' 'mattis' 'mauris' 'maximus' 'metus' 'mi' 'molestie' 'mollis' 'montes' 'morbi' 'mus' \
        'nam' 'nascetur' 'natoque' 'nec' 'neque' 'netus' 'nibh' 'nisi' 'nisl' 'non' 'nostra' 'nulla' 'nullam' 'nunc' \
        'odio' 'orci' 'ornare' \
        'parturient' 'pellentesque' 'penatibus' 'per' 'pharetra' 'phasellus' 'placerat' 'platea' 'porta' 'porttitor' 'posuere' 'potenti' 'praesent' 'pretium' 'primis' 'proin' 'pulvinar' 'purus' \
        'quam' 'quis' 'quisque' \
        'rhoncus' 'ridiculus' 'risus' 'rutrum' \
        'sagittis' 'sapien' 'scelerisque' 'sed' 'sem' 'semper' 'senectus' 'sit' 'sociis' 'sociosqu' 'sodales' 'sollicitudin' 'suscipit' 'suspendisse' \
        'taciti' 'tellus' 'tempor' 'tempus' 'tincidunt' 'torquent' 'tortor' 'tristique' 'turpis' \
        'ullamcorper' 'ultrices' 'ultricies' 'urna' 'ut' \
        'varius' 'vehicula' 'vel' 'velit' 'venenatis' 'vestibulum' 'vitae' 'vivamus' 'viverra' 'volutpat' 'vulputate' \
    )

    echo -n ${ipsum[@]}
}

#/**
# Get random value from the list.
# 
# @param    $*      List data.
#*/
_get_data() {
    local data=("$@")
    local max=${#data[@]}
    local id=$(rand_integer ${max} 1)
    let id--

    echo -n ${data[$id]}
}

_intval() {
    local arg=${1}
    [[ ${arg} =~ ^-?[0-9]+$ ]] && printf ${arg} || printf 0
}

main "$@"

