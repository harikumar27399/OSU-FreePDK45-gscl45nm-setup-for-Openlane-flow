# Makefile for efabless design kits for OSU FreePDK45:
#
# gscl45nm      =  10-metal backend stack with dual MiM  
# Instructions:
#
# Modify values below as needed:
#
#	VENDOR_PATH: points to vendor sources
#	EF_STYLE: 1 for efabless style, 0 otherwise
#	LINK_TARGETS: link back to source or link to 1st PDK when possible
#	DIST_PATH: install location for distributed install
#	LOCAL_PATH: install location for local install or runtime location
#		    for distributed install
#
# Run "make" to stage the PDK for tool setup and vendor libraries

# If installing into the final destination (local install):
#
#   Run "make install-local" to install all staged files
#   ("make install" is equivalent to "make install-local")
#
# If installing into a repository to be distributed to the final destination:
#
#   Run "make install-dist" to install all staged files
#
# Run "make clean" to remove all staging files.
#
# Run "make veryclean" to remove all staging and install log files.
#
# For the sake of simplicity, the "standard" local install can be done
# with the usual
#
#   make
#   make install
#   make clean
#
#--------------------------------------------------------------------
# This Makefile contains bash-isms
SHELL = bash

REVISION    = 20200508 #date of makefile revision in yyyymmdd format
TECH        = gscl45nm

# If EF_STYLE is set to 1, then efabless naming conventions are
# used, otherwise the generic naming conventions are used.
# Mainly, the hierarchy of library names and file types is reversed
# (e.g., sky130_fd_sc_hd/lef vs. lef/sky130_fd_sc_hd).

EF_STYLE = 0
#EF_STYLE = 1

# Normally it's fine to keep the staging path in a local directory,
# although /tmp or a dedicated staging area are also fine, as long
# as the install process can write to the path.

STAGING_PATH = `pwd`

# If LINK_TARGETS is set to "none", then files are copied
# from the FreePDK45 sources to the target.  If set to "source",
# symbolic links are made in the target directories pointing
# back to the FreePDK45 sources.  If set to the name of another
# PDK (e.g, "osu45nmA"), then symbolic links are made to the
# same files in that PDK, where they exist, and are copied
# from source, where they don't.

# LINK_TARGETS = source
LINK_TARGETS = none
# LINK_TARGETS = osu45nmA

# Paths:

# Path to OSU FreePDK45
# Version below comes from https://vlsiarch.ecen.okstate.edu/flows/FreePDK_SRC/OSU_FreePDK.tar.gz
# Version below was released on 22 Jan 2017
FREEPDK45_PATH = ${PDK_ROOT}/osu_freepdk45/OSU_FreePDK_stdcells/osu_freepdk_1.0/lib

# NOTE:  Install destination is the git repository of the technology platform.
# Once updated in git, the git project can be distributed to all hosts.
#
ifeq (${EF_STYLE}, 1)
    LOCAL_PATH = ${PDK_ROOT}
    CONFIG_DIR = .ef-config
    REV_DIR = ${REVISION}
else
    LOCAL_PATH = ${PDK_ROOT}
    CONFIG_DIR = .config
    REV_DIR = .
endif

DIST_PATH = ~/gits/ef-osu45nm-${TECH}

# EF process nodes created from the master sources
FREEPDK45 = gscl45nm

ifeq (${LINK_TARGETS}, ${FREEPDK45})
    DIST_LINK_TARGETS = ${LOCAL_PATH}/${LINK_TARGETS}
else
    DIST_LINK_TARGETS = ${LINK_TARGETS}
endif

# Basic definitions for each EF process node
FREEPDK45_DEFS = -DTECHNAME=gscl45nm -DREVISION=${REVISION} 

# Module definitions for each process node
# (Note that MOS is default and therefore not used anywhere)
FREEPDK45_DEFS += -DMETAL10 -DMIM 
# Add staging path
FREEPDK45_DEFS += -DSTAGING_PATH=${STAGING_PATH}

ifeq (${EF_STYLE}, 1)
    EF_FORMAT = -ef_format
    FREEPDK45_DEFS += -DEF_FORMAT
else
    EF_FORMAT = -std_format
endif

MAGICTOP = libs.tech/magic
NETGENTOP = libs.tech/netgen
QFLOWTOP = libs.tech/qflow
#KLAYOUTTOP = libs.tech/klayout
OPENLANETOP = libs.tech/openlane

ifeq (${EF_STYLE}, 1)
    MAGICPATH = ${MAGICTOP}/${REVISION}
else
    MAGICPATH = ${MAGICTOP}
endif

# Currently, netgen, qflow, and klayout do not use revisioning (needs to change!)
NETGENPATH = ${NETGENTOP}
QFLOWPATH = ${QFLOWTOP}
#KLAYOUTPATH = ${KLAYOUTTOP}
OPENLANEPATH = ${OPENLANETOP}

MAGICTOP_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${MAGICTOP}
NETGENTOP_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${NETGENTOP}
QFLOWTOP_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${QFLOWTOP}
#KLAYOUTTOP_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${KLAYOUTTOP}
OPENLANETOP_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${OPENLANETOP}

MAGIC_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${MAGICPATH}
NETGEN_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${NETGENPATH}
QFLOW_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${QFLOWPATH}
#KLAYOUT_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${KLAYOUTPATH}
OPENLANE_STAGING_A = ${STAGING_PATH}/${FREEPDK45}/${OPENLANEPATH}

FREEPDK45_DEFS += -DMAGIC_CURRENT=${MAGICTOP}/current

# Where cpp syntax is followed, this is equivalent to cpp, but it does not
# mangle non-C source files under the belief that they are actually C code.
CPP   = ../common/preproc.py

# The following script in the ../common directory does most of the work of
# copying or linking the foundry vendor files to the target directory.
STAGE = set -f ; ../common/foundry_install.py ${EF_FORMAT}
INSTALL = ../common/staging_install.py ${EF_FORMAT}

# The script(s) below are used for custom changes to the vendor PDK files
ADDPROP = ../common/insert_property.py ${EF_FORMAT} 

# List the EDA tools to install local setup files for
TOOLS = magic qflow openlane

all: all-a

all-a:
	echo "Starting osu45nm PDK staging on "`date` > ${FREEPDK45}_install.log
	${MAKE} tools-a
	${MAKE} vendor-a
	echo "Ended osu45nm PDK staging on "`date` >> ${FREEPDK45}_install.log

tools-a: general-a magic-a qflow-a openlane-a

general-a: ${TECH}.json
	mkdir -p ${STAGING_PATH}/${FREEPDK45}/${CONFIG_DIR}
	rm -f ${STAGING_PATH}/${FREEPDK45}/${CONFIG_DIR}/nodeinfo.json
	${CPP} ${FREEPDK45_DEFS} ${TECH}.json > \
		${STAGING_PATH}/${FREEPDK45}/${CONFIG_DIR}/nodeinfo.json

magic-a: magic/${TECH}.tech magic/${TECH}.magicrc
	mkdir -p ${MAGICTOP_STAGING_A}
	mkdir -p ${MAGIC_STAGING_A}
	rm -f ${MAGICTOP_STAGING_A}/current
	rm -f ${MAGIC_STAGING_A}/${FREEPDK45}.tech
	#rm -f ${MAGIC_STAGING_A}/${FREEPDK45}-GDS.tech
	#rm -f ${MAGIC_STAGING_A}/${FREEPDK45}.tcl
	#rm -f ${MAGIC_STAGING_A}/${FREEPDK45}-BindKeys
	rm -f ${MAGIC_STAGING_A}/magicrc
	(cd ${MAGICTOP_STAGING_A} ; ln -s ${REV_DIR} current)
	#cp -rp custom/scripts/seal_ring_generator ${MAGIC_STAGING_A}/.
	${CPP} ${FREEPDK45_DEFS} magic/${TECH}.tech > ${MAGIC_STAGING_A}/${FREEPDK45}.tech
	#${CPP} ${FREEPDK45_DEFS} magic/${TECH}gds.tech > ${MAGIC_STAGING_A}/${FREEPDK45}-GDS.tech
	${CPP} ${FREEPDK45_DEFS} magic/${TECH}.magicrc > ${MAGIC_STAGING_A}/${FREEPDK45}.magicrc
	#${CPP} ${FREEPDK45_DEFS} ../common/pdk.bindkeys > ${MAGIC_STAGING_A}/${FREEPDK45}-BindKeys
	#${CPP} ${FREEPDK45_DEFS} magic/${TECH}.tcl > ${MAGIC_STAGING_A}/${FREEPDK45}.tcl
	${CPP} ${FREEPDK45_DEFS} ../common/pdk.tcl >> ${MAGIC_STAGING_A}/${FREEPDK45}.tcl

qflow-a: qflow/${TECH}.sh qflow/${TECH}.par
	mkdir -p ${QFLOWTOP_STAGING_A}
	mkdir -p ${QFLOW_STAGING_A}
	rm -f ${QFLOW_STAGING_A}/${FREEPDK45}.sh
	rm -f ${QFLOW_STAGING_A}/${FREEPDK45}.par
	${CPP} ${FREEPDK45_DEFS} -DLIBRARY=gscl45nm qflow/${TECH}.sh > \
		${QFLOW_STAGING_A}/${FREEPDK45}.sh
	${CPP} ${FREEPDK45_DEFS} qflow/${TECH}.par > ${QFLOW_STAGING_A}/${FREEPDK45}.par
	
#netgen-a: netgen/${TECH}_setup.tcl
	#mkdir -p ${NETGENTOP_STAGING_A}
	#mkdir -p ${NETGEN_STAGING_A}
	#rm -f ${NETGEN_STAGING_A}/${FREEPDK45}_setup.tcl
	#rm -f ${NETGEN_STAGING_A}/setup.tcl
	#${CPP} ${FREEPDK45_DEFS} netgen/${TECH}_setup.tcl > ${NETGEN_STAGING_A}/${FREEPDK45}_setup.tcl
	#(cd ${NETGEN_STAGING_A} ; ln -s ${FREEPDK45}_setup.tcl setup.tcl)

openlane-a: openlane/common_pdn.tcl openlane/config.tcl openlane/gscl45nm/config.tcl 
	mkdir -p ${OPENLANETOP_STAGING_A}
	mkdir -p ${OPENLANE_STAGING_A}
	mkdir -p ${OPENLANE_STAGING_A}/gscl45nm
	rm -f ${OPENLANE_STAGING_A}/common_pdn.info
	rm -f ${OPENLANE_STAGING_A}/config.tcl
	rm -f ${OPENLANE_STAGING_A}/gscl45nm/config.tcl
	rm -f ${OPENLANE_STAGING_A}/gscl45nm/tracks.info
	rm -f ${OPENLANE_STAGING_A}/gscl45nm/no_synth.cells
	#rm -f ${OPENLANE_STAGING_A}/sky130_fd_sc_hd/sky130_fd_sc_hd__fakediode_2.gds

	${CPP} ${FREEPDK45_DEFS} openlane/common_pdn.tcl > ${OPENLANE_STAGING_A}/common_pdn.tcl
	${CPP} ${FREEPDK45_DEFS} openlane/config.tcl > ${OPENLANE_STAGING_A}/config.tcl
	${CPP} ${FREEPDK45_DEFS} openlane/gscl45nm/config.tcl > ${OPENLANE_STAGING_A}/gscl45nm/config.tcl
	${CPP} ${FREEPDK45_DEFS} openlane/gscl45nm/tracks.info > ${OPENLANE_STAGING_A}/gscl45nm/tracks.info
	${CPP} ${FREEPDK45_DEFS} openlane/gscl45nm/no_synth.cells > ${OPENLANE_STAGING_A}/gscl45nm/no_synth.cells
	#cp openlane/sky130_fd_sc_hd/sky130_fd_sc_hd__fakediode_2.gds ${OPENLANE_STAGING_A}/sky130_fd_sc_hd/sky130_fd_sc_hd__fakediode_2.gds

vendor-a:
	# Install base device models from vendor files
	# (NOTE: .mod and .pm3 files should not be in /cells/?)
	#${STAGE} -source ${FREEPDK45_PATH} -target ${STAGING_PATH}/${FREEPDK45} \
		#-ngspice sky130_fd_pr_base/v%v/models/* filter=custom/scripts/fixspice.py \
		#-ngspice sky130_fd_pr_base/v%v/cells/*.mod filter=custom/scripts/fixspice.py \
		#-ngspice sky130_fd_pr_base/v%v/cells/*.pm3 filter=custom/scripts/fixspice.py \
		#|& tee -a ${FREEPDK45}_install.log
	# Install RF device models from vendor files
	#${STAGE} -source ${SKYWATER_PATH} -target ${STAGING_PATH}/${FREEPDK45} \
		#-ngspice sky130_fd_pr_rf/v%v/models/* filter=custom/scripts/fixspice.py \
		#|& tee -a ${FREEPDK45}_install.log
	# Install additional RF device models from vendor files
	#${STAGE} -source ${SKYWATER_PATH} -target ${STAGING_PATH}/${FREEPDK45} \
		#-ngspice sky130_fd_pr_rf2/v%v/models/* filter=custom/scripts/fixspice.py \
		#|& tee -a ${FREEPDK45}_install.log
	# Install base device library from vendor files
	${STAGE} -source ${FREEPDK45_PATH} -target ${STAGING_PATH}/${FREEPDK45} \
		-gds %l/v%v/cells/*.gds \
		-spice %l/v%v/cells/*.sp ignore=topography \
		-spice %l/v%v/cells/*.sp \
		-library primitive gscl45nm |& tee -a ${FREEPDK45}_install.log
	# Purposely making our own LEF views
	#${STAGE} -source ${FREEPDK45_PATH} -target ${STAGING_PATH}/${FREEPDK45} \
		#-gds %l/v%v/cells/gds/*.gds \
		#-verilog %l/v%v/cells/*.v \
		#-lib %l/v%v/cells/*.lib \
		#-doc %l/v%v/cells/*/*.doc \
		#-cdl %l/v%v/cells/*/*.cdl ignore=topography \
		#-spice %l/v%v/cells/netlists/*.pxi  \
		#-library general gscl45nm |& tee -a ${FREEPDK45}_install.log
	# Install all OSU FreePDK45nm digital standard cells.
	${STAGE} -source ${FREEPDK45_PATH} -target ${STAGING_PATH}/${FREEPDK45} \
		-techlef %l/cells/*.tlef \
		-spice %l/cells/*.sp compile-only \
		-lef %l/cells/*.lef exclude=*.*.v compile-only \
		-lib %l/cells/*.lib \
		-gds %l/cells/*.gds compile-only \
		-verilog %l/cells/*.v compile-only \
		-library digital gscl45nm |& tee -a ${FREEPDK45}_install.log
	# Install additional model file (efabless)
	${STAGE} -source ./custom -target ${STAGING_PATH}/${FREEPDK45} \
		-ngspice models/*.lib rename=${FREEPDK45}.lib \
		|& tee -a ${FREEPDK45}_install.log

install: install-local

install-local: install-local-a

install-local-a:
	echo "Starting osu45nm PDK migration on "`date` > ${FREEPDK45}_migrate.log
	${INSTALL} -source ${STAGING_PATH}/${FREEPDK45} \
		-target ${LOCAL_PATH}/${FREEPDK45} \
		-link_from ${LINK_TARGETS} |& tee -a ${FREEPDK45}_migrate.log
	echo "Ended osu45nm PDK migration on "`date` >> ${FREEPDK45}_migrate.log

install-dist: install-dist-a

install-dist-a:
	echo "Starting osu45nm PDK migration on "`date` > ${FREEPDK45}_migrate.log
	${INSTALL} -source ${STAGING_PATH}/${FREEPDK45} \
		-target ${DIST_PATH}/${FREEPDK45} \
		-local ${LOCAL_PATH}/${FREEPDK45} \
		-link_from ${DIST_LINK_TARGETS} |& tee -a ${FREEPDK45}_migrate.log
	echo "Ended osu45nm PDK migration on "`date` >> ${FREEPDK45}_migrate.log

clean: clean-a

clean-a:
	${STAGE} -target ${STAGING_PATH}/${FREEPDK45} -clean

veryclean: veryclean-a

veryclean-a: clean-a
	${RM} ${FREEPDK45}_install.log
	${RM} ${FREEPDK45}_migrate.log
