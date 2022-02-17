#!/usr/bin/env bash

MODPROBE='sudo modprobe'
USBIPD='sudo usbipd -D'
USBIP='sudo usbip'
BIND='bind -b'

${MODPROBE} usbip-core
${MODPROBE} usbip-host
${MODPROBE} vhci-hcd
${USBIPD}
${USBIP} ${BIND} "1-1.2"
${USBIP} ${BIND} "1-1.3"


#> usbip list -l
# - busid 1-1.2 (09fb:6001)
#   Altera : Blaster (09fb:6001)
#
# - busid 1-1.3 (05ff:a001)
#   LeCroy Corp. : unknown product (05ff:a001)
#
# - busid 1-1.4 (0bda:8152)
#   Realtek Semiconductor Corp. : RTL8152 Fast Ethernet Adapter (0bda:8152)


