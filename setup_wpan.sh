#!/bin/bash

#adapted from: http://wpan.cakelab.org/

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root" 1>&2
    exit 1
fi

# we need some Private Area Network ID
panid="0xbeef"
# number of nodes
numnodes=2

# include the kernel module for a fake node, tell it to create six
# nodes
rmmod fakelb
modprobe fakelb numlbs=$numnodes

# initialize all the nodes
for i in $(seq 0 $(( $numnodes - 1 )));
do
    #delete namespace if it exists
    ip netns delete wpan${i}
    #create it again
    ip netns add wpan${i}
    #look for physical number of the created wpan (they not always match)
    PHYNUM=$(iwpan dev | grep -B 1 wpan${i} | sed -ne '1 s/phy#\([0-9]\)/\1/p')
    #assign/move the phy to the created namespace
    iwpan phy${PHYNUM} set netns name wpan${i}

    #Configure wpan interface and add a 6lowpan link with an address
    ip netns exec wpan${i} iwpan dev wpan${i} set pan_id $panid
    ip netns exec wpan${i} ip link add link wpan${i} name lowpan${i} type lowpan
    ip netns exec wpan${i} ip link set wpan${i} up
    ip netns exec wpan${i} ip link set lowpan${i} up
    #should actually use something link fd00::$(( i + 1 ))/8
    ip netns exec wpan${i} ip a a b:1::$(( i + 1 ))/64 dev lowpan${i}

    echo "wpan${i} --> lowpan{$i} --> b:1::$(( i + 1 ))/64"
done
