#!/usr/bin/env bash

QPATH=/opt/intelFPGA_lite/21.1/quartus/bin
cd ../../altera/BeMicro_Max10_template/
${QPATH}/quartus_map --read_settings_files=on --write_settings_files=off BeMicro_MAX10_top -c BeMicro_MAX10_top
${QPATH}/quartus_fit --read_settings_files=off --write_settings_files=off BeMicro_MAX10_top -c BeMicro_MAX10_top
#${QPATH}/quartus_asm --read_settings_files=off --write_settings_files=off BeMicro_MAX10_top -c BeMicro_MAX10_top

