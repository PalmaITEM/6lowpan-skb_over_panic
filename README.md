# 6lowpan-skb_over_panic
Steps to reproduce "skb_over_panic" kernel panic when sending a simple UDP packet over a 6lowpan interface (using fakelb).

Verified with the following kernels:
* 4.10.4-1-ARCH (archlinux)
* 4.9.0-0.bpo.2-amd64 (debian)

**Note:** could not reproduce it in on a raspberrypi with 4.11.y built from source (using https://github.com/raspberrypi/linux/tree/rpi-4.11.y)

## Setup WPAN network with two interfaces

As root run (root permissions are needed for loading/removing the fakelb module):

    ./setup_wpan.sh

This script will try to remove the fakelb module, load it with two lbs (wpan0 and wpan1), and create two namespaces for each lb (again wpan0 and wpan1), adding a lowpan link (lowpan0 and lowpan1) with the IP addresses b:1::1 and b:1::2 .

## Ping interfaces (optional)

    ./test_ping b:1::1 (or b:1::2)

## Send UDP packet to trigger skb_over_panic

This command should be run by a user with permissions to manage namespaces, but the actual sending of the UDP packets does not require any special privileges:

    ip netns exec wpan0 runuser -l user -c "python ./send_udp_packet.py"
    
or simply:

    ip netns exec wpan0 "python ./send_udp_packet.py"

## Screenshot from a VM where the error was reproduced:

