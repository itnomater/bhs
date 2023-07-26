#!/bin/bash

#/**
# Test cron entries.
# 
# Project:          Bash Helper System
# Documentation:    https://itnomater.github.io/bhs/
# Source:           https://github.com/itnomater/bhs
# Licence:          GPL 3.0
# Author:           itnomater <itnomater@gmail.com>
# 
# Use it in `cron` for check if that environment variables are correct. 
#*/

OUTPUT=/tmp/cron.log

echo =============== >> ${OUTPUT}
date >> ${OUTPUT}
echo HOSTNAME: ${HOSTNAME} >> ${OUTPUT}
echo USER: ${USER} >> ${OUTPUT}
echo HOME: ${HOME} >> ${OUTPUT}
echo SHELL_ROOTDIR: ${SHELL_ROOTDIR} >> ${OUTPUT}
echo SHELL_BOOTSTRAP: ${SHELL_BOOTSTRAP} >> ${OUTPUT}
echo PATH ${PATH} >> ${OUTPUT}

echo whoami $(whoami) >> ${OUTPUT}
echo hostname $(hostname) >> ${OUTPUT}

echo >> ${OUTPUT}

