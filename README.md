# 6lowpan-skb_over_panic
Steps to reproduce "skb_over_panic" kernel panic when sending a simple UDP packet over a 6lowpan interface (using fakelb).

Verified with the following kernels:
* Linux version 4.9.0-0.bpo.2-amd64 (debian-kernel@lists.debian.org) (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Debian 4.9.13-1~bpo8+1 (2017-02-27)
* Linux version 4.10.4-1-ARCH (builduser@tobias) (gcc version 6.3.1 20170306 (GCC) ) #1 SMP PREEMPT Sat Mar 18 19:39:18 CET 2017
* Linux version 4.10.5-1-ARCH (builduser@tobias) (gcc version 6.3.1 20170306 (GCC) ) #1 SMP PREEMPT Wed Mar 22 14:42:03 CET 2017

**Note:** Could not reproduce it on a Raspberry Pi 3 running alarm with any of the following kernels:
* 4.9.17-1-ARCH (from alarm repositories)
* 4.10.5-v7+ built from source (using https://github.com/raspberrypi/linux/tree/rpi-4.10.y)
* 4.11.0-rc3-v7+ built from source (using https://github.com/raspberrypi/linux/tree/rpi-4.11.y)


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

## Kernel dump screenshot:

![Kernel Dump](https://github.com/PalmaITEM/6lowpan-skb_over_panic/raw/master/6lowpanic.png)

## Odd note (MAC CTRL packets)

I can't explain this but, when SSHing real hardware and making it fail with the above setup, connectivity is lost on all machines connected to the same hub. Looking deeper into the matter, a tcpdump revealed the generation of MAC CTRL packets looking like this:

    [no.]	[time]	[source]	Spanning-tree-(for-bridges)_01	MAC CTRL	60	Pause: pause_time: 65535 quanta
