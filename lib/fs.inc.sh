#/**
# FILES MANAGEMENT.
# 
# Helper functions to manage the files and directories. It uses a standard shell commands like: 
# stat, chmod or build-in test, 
# but wrapped them in the one interface.
# 
# In short it can do:
#   Check file type (regular, directory, symlink.
#   Get a file permissions, modification date or size.
#   Generate MD5 or SHA1 hash of the file.
#   Rename a file to lowercase/uppercase.
#   Change a file permissions.
#   Unlink a file.
#*/

#/** 
# Is the file exist?
#
# @param    String      $1      Path to the file.
#*/
function fs_is_exist() {
    test -n "${1}" -a -e "${1}"
}

#/**
# Is the file readable?
# 
# @param    String      $1      Path to the file.
#*/
function fs_is_readable() {
    test -n "${1}" -a -r "${1}"
}

#/** 
# Is the file writable?
#
# @param    String      $1      Path to the file.
#*/
function fs_is_writable() {
    test -n "${1}" -a -w "${1}"
}

#/** 
# Is the file executable?
#
# @param    String      $1      Path to the file.
#*/
function fs_is_executable() {
    test -n "${1}" -a -x "${1}"
}

#/**
# Is the path a directory?
# 
# @param    String      $1      Path to the file.
#*/
function fs_is_dir() {
    test -n "${1}" -a -d "${1}"
}

#/**
# Is the path a symlink?
# 
# @param    String      $1      Path to the file.
#*/
function fs_is_symlink() {
    test -n "${1}" -a -h "${1}"
}

#/**
# Is the path a regular file?
# 
# @param    String      $1      Path to the file.
#*/
function fs_is_reg() {
    test -n "${1}" -a -f "${1}" 
}

#/**
# Is the path a block device?
# 
# @param    String      $1      Path to the file.
#*/
function fs_is_block() {
    test -n "${1}" -a -b "${1}" 
}

#/**
# Is the path a character device?
# 
# @param    String      $1      Path to the file.
#*/
function fs_is_character() {
    test -n "${1}" -a -c "${1}" 
}

#/**
# Is the path a pipe?
# 
# @param    String      $1      Path to the file.
#*/
function fs_is_pipe() {
    test -n "${1}" -a -p "${1}" 
}

#/**
# Is the path a socket?
# 
# @param    String      $1      Path to the file.
#*/
function fs_is_socket() {
    test -n "${1}" -a -S "${1}" 
}

#/**
# Is the file/directory empty?
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_is_empty() {
    local path="${1}"

    if fs_is_reg "${path}"; then
        test -s "${path}" && return 1 || return 0
    elif fs_is_dir "${path}"; then
        local num_files=$(ls -a "${path}" | wc -l)
        test "${num_files}" -eq 2 && return 0 || return 2
    else
        return 3
    fi
}


#/**
# Is the file encrypt (using openssl + salt)?
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_is_salted() {
    local path="${1}"
    fs_is_reg "${path}" || return $?

    local h=$(dd bs=8 count=1 if="${path}" 2> /dev/null)
    test "${h}" = 'Salted__'           
}

#/**
# Is the file compress (using xz tool)?
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_is_compressed() {
    local path="${1}"
    fs_is_reg "${path}" || return $?

    xz=$(file "${path}" | awk -F: '{print $2}')
    test "${xz}" = ' XZ compressed data'
}


#/**
# Generate the MD5 hash of the file.
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_md5() {
    local path="${1}"
    fs_is_reg "${path}" && md5sum "${path}" | cut -d' ' -f 1 && return 0
    
    return 1
}

#/**
# Generate the SHA1 hash of the file.
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_sha1() {
    local path="${1}"
    fs_is_reg "${path}" && sha1sum "${path}" | cut -d' ' -f 1 && return 0

    return 1
}


#/**
# Get file modyfication date.
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_mdate() {
    local path="${1}"
    if fs_is_exist "${path}"; then
        local dt=$(stat -c "%y" "${path}")
        echo ${dt/ */}
        return 0
    else
        echo 0 
        return 1
    fi
}

#/**
# Get file modyfication time.
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_mtime() {
    local path="${1}"
    if fs_is_exist "${path}"; then
        local dt=$(stat -c "%y" "${path}")
        dt=${dt/.*/}
        echo ${dt/* /}
        return 0
    else
        echo 0 
        return 1
    fi
}

#/**
# Get file modyfication full date (date + time).
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_mdatetime() {
    local path="${1}"
    if fs_is_exist "${path}"; then
        local dt=$(stat -c "%y" "${path}")
        echo ${dt/.*/}
        return 0
    else
        echo 0 
        return 1
    fi
}

#/**
# Get file modyfication UNIX timestamp.
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_mtimestamp() {
    local path="${1}"
    if fs_is_exist "${path}"; then
        stat -c "%Y" "${path}"
        return $?
    else
        echo 0 
        return 1
    fi
}

#/**
# Get file permissions (in octal).
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_perm() {
    local path="${1}"
    if fs_is_exist "${path}"; then
        stat -c "%a" "${path}" 
        return 0
    else
        echo 0
        return 1
    fi
}

#/**
# Get file size (in bytes).
# 
# @param    String  -p  $1      Path to the file.
# @param    String      $2      Output format (suffixes).
#                       <null>          Size in bytes (no suffix).
#                   -b      B|b         Size in bytes.
#                   -k      K|KB|kb     Size in kilobytes.
#                   -m      M|MB|mb     Size in megabytes.
#                   -g      G|GB|gb     Size in gigabytes.
#                   -s      *           The suffix is adjusted dynamically.
# @return   Number              Operation status.
#*/
function fs_size() {
    declare -i size
    local path= suffix=
    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -p|--path)
                    path="${2}" 
                    shift 2 ;;

                -b|--bytes)
                    suffix='b'
                    shift 1 ;;

                -k|--kilobytes)
                    suffix='k'
                    shift 1 ;;
                    
                -m|--megabytes)
                    suffix='m'
                    shift 1 ;;
                    
                -g|--gigabytes)
                    suffix='g'
                    shift 1 ;;

                -s|--suffix)
                    suffix='a'
                    shift 1 ;;
                    
                *) shift
            esac
        done
    else
        path="${1}"
        suffix="${2}"
    fi
    
    ! fs_is_exist "${path}" && echo 0 && return 1
    
    let size=$(stat -c "%s" "${path}")
    test ${size} -eq 0 && echo 0 && return 0

    test -n "${suffix}" && _fs_convert_size "${size}" "${suffix}" || echo "${size}"
}

#/**
# Convert file size in bytes to human-readable.
# 
# @param    String  -s  $1      Size in bytes.
# @param    String      $2      Output format (suffix).
#                   <null>              The suffix is adjusted dynamically.
#                   -b      B|b         Size in bytes.
#                   -k      K|KB|kb     Size in kilobytes.
#                   -m      M|MB|mb     Size in megabytes.
#                   -g      G|GB|gb     Size in gigabytes.
# @return   Number              Operation status.
#*/
function _fs_convert_size() {
    declare -i size
    local suffix=a
    if test "${1:0:1}" == '-'; then
        while test -n "${1}"; do
            case ${1} in
                -b|--bytes)
                    suffix='b'
                    shift 1 ;;

                -k|--kilobytes)
                    suffix='k'
                    shift 1 ;;
                    
                -m|--megabytes)
                    suffix='m'
                    shift 1 ;;
                    
                -g|--gigabytes)
                    suffix='g'
                    shift 1 ;;

                -s|--size)
                    size=${2}
                    shift 2 ;;
                    
                *) shift
            esac
        done
    else
        size="${1}"
        suffix="${2}"
    fi

    if ! [[ ${size} =~ ^[1-9][0-9]+$ ]]; then
        echo 0
        return 1
    fi
    
    if test "${suffix}" == 'a'; then
        if test ${size} -lt 1024 ; then
            suffix='b'
        elif test ${size} -lt 1048576; then
            suffix='k'
        elif test ${size} -lt 1073741824; then
            suffix='m'
        else
            suffix='g'
        fi
    fi

    case ${suffix} in
        g)  sizex=$(echo "scale=2; ${size} / 1024 / 1024 / 1024" | bc -l)
            test "${sizex:0:1}" == '.' && sizex="0${sizex}G" || sizex+='G'
            ;;

        m)  sizex=$(echo "scale=2; ${size} / 1024 / 1024" | bc -l)
            test "${sizex:0:1}" == '.' && sizex="0${sizex}M" || sizex+='M'
            ;;

        k)  sizex=$(echo "scale=2; ${size} / 1024" | bc -l)
            test "${sizex:0:1}" == '.' && sizex="0${sizex}K" || sizex+='K'
            ;;

        b)  sizex="${size}B"
            ;;

        *)  sizex=${size} 
            ;;
    esac

    echo "${sizex}"
}


#/**
# Set file permissions.
# 
# @param    String      $1      New file permissions (in octal).
# @param    String      $2      Path to the file.
# @return   Number              Operation status.
#*/
function fs_chmod() {
    ! fs_is_exist "${2}" && return 1
    
    chmod "${1}" "${2}" 2> /dev/null
}

#/**
# Set file modyfication time.
# 
# @param    String      $1      Modification time.
# @param    String      $2      Path to the file.
# @return   Number              Operation status.
#*/
function fs_set_mtimestamp() {
    ! fs_is_exist "${2}" && return 1
    
    touch -m -d @${1} "${2}" 2> /dev/null
}


#/**
# Remove the whole directory. It is too dangerous, so I don't want use it.
# 
# @param    String      $1      Path to the directory.
# @return   Number              Operation status.
#*/
#function dir_remove() {
#    fs_is_dir "${1}"
#    test $? -eq 0 && rm -fr "${1}"
#}

#/**
# Make a symbolic link to the file.
# 
# @param    String      $1      Name of the symbolic link.
# @param    String      $2      Path to the source file.
# @return   Number              Operation status.
#*/
function fs_mksym() {
    local src="${1}"
    local dst="${2}"

    test -z "${src}" && return 1
    test -z "${dst}" && return 2

#    ! fs_is_exist "${src}" && return 3

    fs_is_symlink "${dst}" && unlink "${dst}" 

    ln -s "${src}" "${dst}"
}

#/**
# Does the file system support permissions?
# 
# @param    String      $1      Path to the directory.
# @return   Number              Operation status.
#*/
function fs_is_support_permissions() {
    local test_fpath="${1}/.perm"
    touch "${test_fpath}" 2> /dev/null
    chmod 777 "${test_fpath}" 2> /dev/null
    local stat=$?
    test -e "${test_fpath}" && unlink "${test_fpath}" 2> /dev/null
    return ${stat}
}

#/**
# Create the directory (if doesn't exist).
# 
# @param    String      $1      Path to the directory.
# @return   Number              Operation status.
#*/
function fs_mkdir() {
    ! test -e "${1}" && mkdir -p "${1}" 2> /dev/null
}

#/**
# Remove the directory (if isn't empty).
# 
# @param    String      $1      Path to the directory.
# @return   Number              Operation status.
#*/
function fs_rmdir() {
    ! test -d "${1}" && return 1
    test $(ls -a "${1}" | wc -l) -ne 2 && return 2

    rmdir -p "${1}" 2> /dev/null
}

#/**
# Remove the file.
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_unlink() {
    ! fs_is_exist "${1}" && return 1
    fs_is_dir "${1}" && ! fs_is_symlink "${1}" && return 2
    
    unlink "${1}" 2> /dev/null
}

#/**
# Rename the file path to lowercase.
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_tolower() {
    local fpath="$*"
    fs_is_exist "${fpath}" && mv "${fpath}" "${fpath,,}" || return 1
}

#/**
# Rename the file path to uppercase.
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_toupper() {
    local fpath="$*"
    fs_is_exist "${fpath}" && mv "${fpath}" "${fpath^^}" || return 1
}

#/**
# Strip the file path to specified length.
# 
# When the path is shorten than 12 characters show all.
# Otherwise show the last parts preceded by ..
# 
# @param    String      $1      Path to the file.
# @return   Number              Operation status.
#*/
function fs_strip_path() {
    full="${1}"
    length=${#full}

    if test "${length}" -le 11; then
        echo "${full}"
    else
    # I don't want to make dependencies between modules..
#        eval $(string_2array -s '/' -n 'path' -d ${full})

        ( 
            IFS=/
            read -a path <<< "${full}"
            max=${#path[@]}
            if test ${max} -le 2; then
                echo ${full}
            else
                cur=$((${max} - 2))
                printf '..'
                while test ${cur} -lt ${max}; do
                    printf /${path[$cur]}
                    let cur++
                done
            fi
        )
    fi
}

