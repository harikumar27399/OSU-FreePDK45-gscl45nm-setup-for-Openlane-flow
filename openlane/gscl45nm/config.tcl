set current_folder [file dirname [file normalize [info script]]]

# Technology lib
set ::env(LIB_SYNTH) "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/lib/$::env(PDK_VARIANT)/gscl45nm.lib"
set ::env(LIB_MAX) "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/lib/$::env(PDK_VARIANT)/gscl45nm.lib"
set ::env(LIB_MIN) "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/lib/$::env(PDK_VARIANT)/gscl45nm.lib"

set ::env(LIB_TYPICAL) $::env(LIB_SYNTH)

# Tracks info
set ::env(TRACKS_INFO_FILE) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(PDK_VARIANT)/tracks.info"


# Placement site for core cells
# This can be found in the technology lef
set ::env(PLACE_SITE) "CoreSite"
set ::env(PLACE_SITE_WIDTH) 0.380
set ::env(PLACE_SITE_HEIGHT) 2.470

# welltap and endcap cells
set ::env(FP_WELLTAP_CELL) "FILL"
set ::env(FP_ENDCAP_CELL) "FILL"

# defaults (can be overridden by designs):
set ::env(SYNTH_DRIVING_CELL) "INVX1"
#capacitance : 0.017653;
set ::env(SYNTH_DRIVING_CELL_PIN) "Y"
# update these
set ::env(SYNTH_CAP_LOAD) "1.55" ; # femtofarad INVX8 pin A cap #have to find from .lib file
set ::env(SYNTH_MIN_BUF_PORT) "BUFX2 A Y"
#set ::env(SYNTH_TIEHI_PORT) "sky130_fd_sc_hd__conb_1 HI"
#set ::env(SYNTH_TIELO_PORT) "sky130_fd_sc_hd__conb_1 LO"

# cts defaults
set ::env(CTS_ROOT_BUFFER) CLKBUF3
set ::env(CELL_CLK_PORT) CLK

# Placement defaults
set ::env(PL_LIB) $::env(LIB_TYPICAL)

# Fillcell insertion
set ::env(FILL_CELL) "FILL"
set ::env(DECAP_CELL) "FILL"
set ::env(RE_BUFFER_CELL) "BUFX4"


# Diode insertaion
#set ::env(DIODE_CELL) "sky130_fd_sc_hd__diode_2"
#set ::env(FAKEDIODE_CELL) "sky130_fd_sc_hd__fakediode_2"
#set ::env(DIODE_CELL_PIN) "DIODE"

set ::env(CELL_PAD) 8
set ::env(CELL_PAD_EXECLUDE) "FILL*"

# Clk Buffers info CTS data
set ::env(ROOT_CLK_BUFFER) CLKBUF3
set ::env(CLK_BUFFER) CLKBUF2
set ::env(CLK_BUFFER_INPUT) A
set ::env(CLK_BUFFER_OUTPUT) Y
set ::env(CTS_CLK_BUFFER_LIST) "CLKBUF1 CLKBUF2 CLKBUF3"
set ::env(CTS_SQR_CAP) 0.0
set ::env(CTS_SQR_RES) 0.25
set ::env(CTS_MAX_CAP) 2.082
