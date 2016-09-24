#******************************************************************************
#  Facultad de Ingeniería de la Universidad de Buenos Aires
#  Sistemas Digitales
#  2° Cuatrimestre de 2015
# 
#  Sampayo, Sebastián Lucas
#  Padrón: 93793
#  e-mail: sebisampayo@gmail.com
# 
#  Makefile para proyecto genérico
#******************************************************************************

# Project name
PROJECT = Cordic_TP

# vhdl files
SRCDIR = src
FILES = ${SRCDIR}/*
VHDLEX = .vhd

# testbench
TESTSDIR = tests
# File Name:
# TESTBENCH = test# test de solo la video_ram
TESTBENCH = test_aplic# test de la aplicación aplic
# Entity Name:
TESTBENCH_UNIT = testbench
TESTBENCHPATH = ${TESTSDIR}/${TESTBENCH}$(VHDLEX)

# Board-Top
# TOPFILE = ${SRCDIR}/board_top
BOARDTOPDIR = ${SRCDIR}
# File Name:
# BOARDTOP = board_top # solo la video_ram con la vga
BOARDTOP = aplic # uart + ext_ram + video_ram + vga
# Entity Name:
BOARDTOP_UNIT = board_top
BOARDTOPPATH = ${SRCDIR}/${BOARDTOP}$(VHDLEX)

# Libraries
#COMPONENTS_LIB_NAME = componenteslib
COMPONENTS_LIB_PATH = "../Librerias/componenteslib/work_ghdl"
LIBDIR = $(COMPONENTS_LIB_PATH)

#GHDL CONFIG
GHDL_CMD = ghdl
# GHDL_FLAGS = --ieee=synopsys --warn-no-vital-generic -v --std=02
GHDL_FLAGS = --ieee=synopsys --warn-no-vital-generic -v --std=02 -fexplicit
GHDL_LIB_FLAG = -P$(LIBDIR)
SIMDIR = simulation

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=20000us
WAVEFORM_VIEWER = gtkwave
TCL_SCRIPT_NAME = gtkwave_script.tcl
TCL_SCRIPT_PATH = $(TESTSDIR)/$(TCL_SCRIPT_NAME)
WAVEFORM_VIEWER_OPTS = "-S $(TCL_SCRIPT_PATH)"

# ISE
ISEDIR = ise
DEVICE = xc3s200-ft256-4


# -------------------------------------------------------------------------- #

test: compile_test run view

top: compile_top

# No funciona aún
ise: ise-env ise-synthesize ise-translate ise-map ise-par ise-trce ise-view-summary

new :
	echo "Setting up project ${PROJECT}"
	mkdir ${SRCDIR} ${TESTSDIR} $(SIMDIR) $(ISEDIR)

# -------------------------------------------------------------------------- #
file_check:
ifeq ($(strip $(FILES)),)
	@echo "FILES not set. Use FILES=value to set it. Put mutltiple files in quotes"
	@exit 2
endif

testbench_check:
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=value to set it."
	@exit 2
endif

# -------------------------------------------------------------------------- #

# Importar archivos:

import: file_check
#	mkdir -p simulation <= ????
	$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=$(SIMDIR) --work=work $(TESTBENCHPATH) $(FILES)

# Esto es al pepe, porq el boardtop está incluído en $(FILES), por lo tanto ya fue importado con "import"
# y no importa que también esté importado el testbench, mientras no se pida que compile la unidad test
import_top:
	$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=$(SIMDIR) --work=work $(BOARDTOPPATH) $(FILES)

# Se puede hacer:
# import_test:
# test: compile_test run_test view_test
# import_top:
# top: compile_top

# Compilar
compile_test : testbench_check file_check
	@echo $(GHDL_LIB_FLAG)
	$(GHDL_CMD) -m $(GHDL_FLAGS) $(GHDL_LIB_FLAG) --workdir=$(SIMDIR) --work=work -o $(SIMDIR)/$(TESTBENCH) $(TESTBENCH_UNIT)

compile_top :
	$(GHDL_CMD) -m $(GHDL_FLAGS) $(GHDL_LIB_FLAG) --workdir=$(SIMDIR) --work=work -o $(SIMDIR)/$(BOARDTOP) $(BOARDTOP_UNIT)

run :
	@$(SIMDIR)/$(TESTBENCH) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(TESTBENCH).vcdgz

view :
	gunzip --stdout $(SIMDIR)/$(TESTBENCH).vcdgz | $(WAVEFORM_VIEWER) $(WAVEFORM_VIEWER_OPTS) --vcd &

# -------------------------------------------------------------------------- #
# ISE

# Environment variables
# Esto seguramente haya que agregarlo en cada comando
# TODO: No reconoce "source"
ise-env:
	source /opt/Xilinx/14.7/ISE_DS/settings32.sh

# Synthesize
# Chequear que exista el proyecto
# TODO: Esto tendría que generar el NGC y no lo hace 
ise-synthesize: $(FILES)
	cd $(ISEDIR)/$(PROJECT); \
	mkdir -p reports; \
	xst -intstyle ise \
	-ifn "$(BOARDTOP).xst" \
	-ofn "$(BOARDTOP).syr" \
	| tee reports/cmd.log ; \
	cp $(BOARDTOP).syr reports/$(BOARDTOP)_xst.syr; \
	ls; \
	cd ../..

# Translate
# The Translate process merges all of the input netlists and design constraints
# and outputs a Xilinx Native Generic Database (NGD) file, which describes the 
# logical design reduced to Xilinx primitives. See the following table for 
# details.
ise-translate: 
	cd $(ISEDIR)/$(PROJECT); \
	ngdbuild -intstyle ise \
	-dd _ngo \
	-nt timestamp \
	-i \
	-p $(DEVICE) \
	$(BOARDTOP).ngc \
	$(BOARDTOP).ngd \
	| tee reports/cmd.log ; \
	cp $(BOARDTOP).bld reports/$(BOARDTOP)_ngbuild.bld ; \
	cd ../..

# Map
# The Map process maps the logic defined by an NGD file into FPGA elements, such as CLBs and IOBs. The output design is a Native Circuit Description (NCD) file that physically represents the design mapped to the components in the Xilinx FPGA
ise-map:
	cd $(ISEDIR)/$(PROJECT) ; \
	map -intstyle ise \
	-p $(DEVICE) \
	-cm area \
	-ir off \
	-pr off \
	-c 100 \
	-o $(BOARDTOP).ncd \
	$(BOARDTOP).ngd \
	$(BOARDTOP).pcf \
	| tee reports/cmd.log ; \
	cp $(BOARDTOP)_map.mrp reports/ ; \
	cd ../..

# Place and Route
# The Place and Route process takes a mapped NCD file, places and routes the design, and produces an NCD file that is used as input for bitstream generation.
ise-par:
	cd $(ISEDIR)/$(PROJECT) ; \
	par -intstyle ise \
	-w \
	-ol high \
	-t 1 \
	$(BOARDTOP)_map.ncd \
	$(BOARDTOP).ncd \
	$(BOARDTOP).pcf \
	| tee reports/cmd.log ; \
	cp $(BOARDTOP).par reports/ ; \
	cd ../..

# TRACE
# Timing Reporter And Circuit Evaluator (TRACE) tool provides static timing analysis of an FPGA design
# based on input timing constraints.
ise-trce:
	cd $(ISEDIR)/$(PROJECT) ; \
	trce -intstyle ise \
	-v 3 \
	-s 4 \
	-n 3 \
	-fastpaths \
	-xml $(BOARDTOP).twx \
	$(BOARDTOP).ncd \
	-o $(BOARDTOP).twr \
	$(BOARDTOP).pcf \
	| tee reports/cmd.log ; \
	cd ../..

# View Summary
ise-view-summary:
	google-chrome $(ISEDIR)/$(PROJECT)/$(BOARDTOP)_summary.html

# -------------------------------------------------------------------------- #
clean :
	$(GHDL_CMD) --clean --workdir=$(SIMDIR)
	@rm $(SIMDIR)/*
#	@rm -R $(ISEDIR)/$(PROJECT)
