#!/usr/bin/env bash

MODPROBE='sudo modprobe'
USBIPD='sudo usbipd -D'
USBIP='sudo usbip'
BIND='bind -b'
LIST_LOCAL='list -l'
LIST_REMOTE='list -r'
ATTACH_REMOTE='attach -r'
REMOTE_HOST='FastTrack'
LSUSB='sudo lsusb'

${MODPROBE} usbip-core
#${MODPROBE} usbip-host
${MODPROBE} vhci-hcd

${USBIP} ${LIST_REMOTE} ${REMOTE_HOST}
${USBIP} ${ATTACH_REMOTE} ${REMOTE_HOST} '-b 1-1.2'
${USBIP} ${ATTACH_REMOTE} ${REMOTE_HOST} '-b 1-1.3'

${LSUSB}

#> usbip list -l
# - busid 1-1.2 (09fb:6001)
#   Altera : Blaster (09fb:6001)
#
# - busid 1-1.3 (05ff:a001)
#   LeCroy Corp. : unknown product (05ff:a001)
#
# - busid 1-1.4 (0bda:8152)
#   Realtek Semiconductor Corp. : RTL8152 Fast Ethernet Adapter (0bda:8152)


#$ usbip list -r FastTrack
#usbip: error: failed to open /usr/share/hwdata//usb.ids
#Exportable USB devices
#======================
# - FastTrack
#      1-1.3: unknown vendor : unknown product (05ff:a001)
#           : /sys/devices/platform/soc/20980000.usb/usb1/1-1/1-1.3
#           : unknown class / unknown subclass / unknown protocol (ff/ff/ff)
#
#      1-1.2: unknown vendor : unknown product (09fb:6001)
#           : /sys/devices/platform/soc/20980000.usb/usb1/1-1/1-1.2
#           : (Defined at Interface level) (00/00/00)
