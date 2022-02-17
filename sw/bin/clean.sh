#!/usr/bin/env bash

QPATH=/opt/intelFPGA_lite/21.1/quartus/bin
cd ../../altera/BeMicro_Max10_template/
#${QPATH}/quartus_sh --clean -c * BeMicro_MAX10_top
${QPATH}/quartus_sh --clean BeMicro_MAX10_top

