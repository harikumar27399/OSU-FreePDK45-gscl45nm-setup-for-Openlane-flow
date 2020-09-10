# Power nets
set ::power_nets $::env(VDD_PIN)
set ::ground_nets $::env(GND_PIN)

set ::macro_blockage_layer_list "metal1 metal2 metal3 metal4 metal5 metal6 metal7 metal8 metal9 metal10"

pdngen::specify_grid stdcell {
    name grid
    rails {
	    metal1 {width 0.48 pitch $::env(PLACE_SITE_HEIGHT) offset 0}
    }
    straps {
	    metal9 {width 0.8 pitch $::env(FP_PDN_VPITCH) offset $::env(FP_PDN_VOFFSET)}
	    metal10 {width 0.8 pitch $::env(FP_PDN_HPITCH) offset $::env(FP_PDN_HOFFSET)}
    }
    connect {{metal1 metal9} {metal9 metal10}}
}

pdngen::specify_grid macro {
    orient {R0 R180 MX MY R90 R270 MXR90 MYR90}
    power_pins "vdde"
    ground_pins "vsse"
    blockages "metal1 metal2 metal3 metal4 metal5 metal6 metal7 metal8 metal9 metal10" 
    straps { 
    } 
    connect { }
}

set ::halo 0

# Metal layer for rails on every row
set ::rails_mlayer "metal1" ;

# POWER or GROUND #Std. cell rails starting with power or ground rails at the bottom of the core area
set ::rails_start_with "POWER" ;

# POWER or GROUND #Upper metal stripes starting with power or ground rails at the left/bottom of the core area
set ::stripes_start_with "POWER" ;
