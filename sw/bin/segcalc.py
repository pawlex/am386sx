#!/usr/bin/env python2

import sys
def main():
    if len(sys.argv) < 2:
        print "syntax: %s <physical address>"
        return
    #
    physical = int(sys.argv[1], 16)
    segment  = physical >> 16
    offset   = physical & 0xffff
    print "physical address : 0x%06x" % physical
    print "logical  address : 0x%04x:0x%04x" % (segment,offset)
#

if __name__ == '__main__':
    main()
#
