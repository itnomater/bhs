#/**
# Helper function for network 
# 
# [DEPENDENCIES]
# nbtscan command
# host command
# ping command
#*/

net_user_commands() {
    local commands=(nbtscan host ping)
    echo ${commands[@]}
}

#/**
# Print the domain address based on IP address.
# 
# If the address will not find it prints $1 argument.
#
# @param    String  $1      IP address.
# @return   Number          Operation status.
#*/
net_find_domain() {
    declare -r ip_pat='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
    local ip=${1}

    if test -z "${ip}"; then
        return 1
    elif test "${ip}" == '127.0.0.1' -o "${ip}" == 'localhost'; then
        echo -n localhost
    elif [[ ${ip} =~ ${ip_pat} ]]; then
        n=$(nbtscan -t 40 -e ${ip} 2> /dev/null | awk '{print $2}')
        if test -n "${n}"; then
            echo -n ${n}
        else
            n=$(host -W 1 ${ip} 2> /dev/null)
            test $? -eq 0 \
                && echo -n ${n} | sed 's/.* //;s/\.$//' \
                || echo -n ${1} # -unknown
        fi
    else
        echo -n ${ip} # -unknown
        return 1
    fi
}

#/**
# Print the IP address based on the domain address.
# 
# If the IP address will not find it returns $1 argument.
#
# @param    String  $1      The domain address.
# @return   Number          Operation status.
#*/
net_find_ip() {
    declare -r ip_pat='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'

    local ip=${1}
    if test -z "${ip}"; then
        return 1
    elif test "${1}" == '127.0.0.1' -o "${1}" == 'localhost'; then
        echo -n 127.0.0.1
    elif [[ ${ip} =~ ${ip_pat} ]]; then
        echo -n ${ip}
    else
        ping -c 1 -W 1 "${ip}" > /dev/null 2>&1
        if test $? -eq 0; then
            ping -c 1 -W 1 "${ip}" | head -n 1 | cut -d ' ' -f 3 | tr -d '()'
        else
            echo -n ${ip}
            return 1
        fi
    fi
}

#/**
# Check if the IP address is correct.
# 
# @param    String  $1      The IP address.
# @return   Number          Operation status.
#*/
net_is_ip() {
    if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        for o in ${1//./ }; do 
            test ${o:0:1} == '0' -a ${#o} -gt 1 && return 1
            test ${o} -gt 255 && return 1
        done
        
        return 0
    else
        return 1
    fi
}

#/**
# Print list of the network interfaces.
#*/
net_list_ifaces() {
    ls /sys/class/net 2> /dev/null
}

