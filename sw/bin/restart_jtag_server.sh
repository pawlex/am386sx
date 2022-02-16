#!/usr/bin/env bash

sudo killall -9 jtagd
sudo /opt/intelFPGA_lite/21.1/quartus/bin/jtagd 
/opt/intelFPGA_lite/21.1/quartus/bin/jtagconfig

