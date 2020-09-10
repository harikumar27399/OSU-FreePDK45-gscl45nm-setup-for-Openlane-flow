# Process node
set ::env(PROCESS) 45
set ::env(DEF_UNITS_PER_MICRON) 2000


# Placement site for core cells
# This can be found in the technology lef

set ::env(VDD_PIN) "vdd"
set ::env(GND_PIN) "gnd"

# Technology LEF #have to set correct paths
set ::env(TECH_LEF) "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/techLEF/$::env(PDK_VARIANT)/$::env(PDK_VARIANT).tlef"
set ::env(CELLS_LEF) [glob "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/lef/$::env(PDK_VARIANT)/*.lef"]
#set ::env(GPIO_PADS_LEF) [glob "$::env(PDK_ROOT)/sky130A/libs.ref/lef/sky130_fd_io/sky130_fd_io.lef"]

# magic setup
set ::env(MAGIC_MAGICRC) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/magic/gscl45nm.magicrc"
set ::env(MAGIC_TECH_FILE) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/magic/gscl45nm.tech"

# netgen setup #TO DO
set ::env(NETGEN_SETUP_FILE) $::env(PDK_ROOT)/$::env(PDK)/libs.tech/netgen/gscl45nm_setup.tcl

# CTS luts
set ::env(CTS_TECH_DIR) "N/A"

set ::env(FP_TAPCELL_DIST) 14

set ::env(GLB_RT_L1_ADJUSTMENT) 0.99
