#/**
# TEMPORARY FILES.
# 
# The temporary files are stored in `${_TMP}/{current_user}` directory. Only current user have access to it. Variable `$_TMP` is declared in the `core` library.
# 
# - tmp_rootdir     - Print the temporary root directory path.
# - tmp_dir         - Create the temporary subdirectory and print its path.
# - tmp_file        - Create the temporary file and print its path.
# - tmp_clean       - Delete the temporary files/directories.
#*/

#/**
# Print the temporary root directory path.
#*/
tmp_rootdir() {
    { echo ${_TMP}/$(whoami); } 2> /dev/null
}

#/**
# Create the temporary subdirectory and print its path.
# 
# If the directory doesn't exist then it will be created.
#
# @param    String  $1      Name of the temporary subdirectory related to the temporary `tmp_rootdir()` directory:
#                   {any_value}     Specified name.
#                   {blank}         $(basename $0)-$$
#*/
tmp_dir() {
    {
    local rootdir=$(tmp_rootdir)
    local subdir=${1:-$(realscr)-$(pid)}

    if test -z "${subdir}"; then
        echo ${rootdir}
    else 
        test ! -e "${rootdir}/${subdir}" && mkdir "${rootdir}/${subdir}"

        echo ${rootdir}/${subdir}
    fi; } 2> /dev/null
}

#/**
# Create the temporary file and print its path.
#
# To keep order, it is possible to separete the temporary files into multiple subdirectories using a prefix.
# 
# @param    String  $1      File name: 
#               {any_value}     Specified name.
#               #|{blank_value} Random string based on the pattern [0-9a-f]{8}.
# @param    String  $2      Subdirectory name:
#               {any_value}     Specified name.
#               {blank}         $(tmp_dir). 
#*/
tmp_file() {
    {
    local fpath="$(tmp_dir ${2})/" prefix=${1}

    ! -e ${fpath} && mkdir ${fpath}

    if test "${prefix}" == '' -o "${prefix}" == '#'; then
        fpath+=$(cat /dev/urandom | head -n1 | md5sum | cut -c 1-8)
    else
        [[ ${prefix} =~ .*/.* ]] && prefix=$(basename "${prefix}")

        local hash_pattern='.*#.*'

        while [[ ${prefix} =~ ${hash_pattern} ]]; do
            prefix=${prefix/\#/$(cat /dev/urandom | head -n1 | md5sum | cut -c 1-8)}
        done

        fpath+=${prefix}
    fi

    touch "${fpath}"
    echo "${fpath}"; } 2> /dev/null
}

#/**
# Delete the temporary files/directories.
# 
# You should clean all temporary files/directory you have created before the script ends.
#
# @param    String  $1      Subdirectory name:
#                   {any_value}     Specified name.
#                   {blank}         $(basename $0)-$$
#*/
tmp_clean() {
    {
    local tmp=$(tmp_dir ${1})
    # call rm -fr ${tmp} is too risky.
    # rm -fr ${tmp}

    # Let's check first if we are in the right directory?
    if test -d "${tmp}" && [[ ${tmp} =~ ^/tmp ]]; then
        rm -f ${tmp}/*
        rmdir ${tmp}
    fi; } 2> /dev/null
}


#/**
# Create the temporary directory.
# 
# The function is unset after call.
#*/
_tmp_init() {
    local tmp_dir=$(tmp_rootdir)

    test ! -d ${tmp_dir} && mkdir -p ${tmp_dir}

    chmod 700 ${tmp_dir}
}

#/**
# Prepare the temporary directory and unset the `_tmp_init()` function.
#*/
tmp_init() {
    _tmp_init; unset _tmp_init
}

