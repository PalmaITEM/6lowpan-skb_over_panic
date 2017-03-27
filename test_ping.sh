#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Please add destination (usage $0 ipv6_address)"
    exit 1
fi

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root" 1>&2
    exit 1
fi

IP=$1
#get the last part of the IP (assuming a wellformed one...)
id=${IP##*:}

if [[ $id -eq 1 ]]; then
    #working with wpan1 to ping wpan0
    ip netns exec wpan1 runuser -u user ping6 ${IP}
elif [[ $id -eq 2 ]]; then
    ip netns exec wpan0 runuser -u user ping6 ${IP}
else
    echo "this script is only for the simple 2 node setup I prepared :)"
    exit 1
fi
