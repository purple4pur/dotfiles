#!/usr/bin/env bash

PROFILE_URL="/org/gnome/terminal/legacy/profiles:"
UUID=$(uuidgen)
FILENAME=${1}

if [[ "${FILENAME}" == "" ]]; then
    echo ">>x Example: ${0} Brogrammer.dconf"
    exit 1
elif [[ ! -e "${FILENAME}" ]]; then
    echo ">>x File not found: ${FILENAME}"
    exit 1
fi

# add profile to dconf
dconf load ${PROFILE_URL}/:${UUID}/ < ${FILENAME}

# read and append profile list
ENTRIES=($(dconf read ${PROFILE_URL}/list | tr -d "[]',") ${UUID})
ENTRIES=$(printf ", '%s'" "${ENTRIES[@]}")
ENTRIES="[${ENTRIES:2}]"
dconf write ${PROFILE_URL}/list "${ENTRIES}"

# print imported profile info
CMD="dconf dump ${PROFILE_URL}/:${UUID}/"
echo ">>> Imported profile:"
echo ">>> ${CMD}"
${CMD}
