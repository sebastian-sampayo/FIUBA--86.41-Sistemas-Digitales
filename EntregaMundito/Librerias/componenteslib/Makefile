#******************************************************************************
#  Facultad de Ingeniería de la Universidad de Buenos Aires
#  Sistemas Digitales
#  2° Cuatrimestre de 2015
# 
#  Sampayo, Sebastián Lucas
#  Padrón: 93793
#  e-mail: sebisampayo@gmail.com
# 
#  Makefile para librería
#******************************************************************************

# Project name
# PROJECT = 

# vhdl files
VHDLEX = .vhd
SRCDIR = src
FILES = ${SRCDIR}/*${VHDLEX}

#FILES = src/my_components.vhd src/flip-flop-D.vhd src/VGActrl.vhd src/MemoryController.vhd src/ffd_serie.vhd src/receive.vhd src/transmit.vhd src/timing.vhd src/uart.vhd
PKG_DIR = ${SRCDIR}/packages
PKG_FILE = ${PKG_DIR}/*

# testbench
#TESTSDIR = tests
#TESTBENCH = test
#TESTBENCHPATH = ${TESTSDIR}/${TESTBENCH}$(VHDLEX)

# Libraries
LIB_NAME = componenteslib
#COMPONENTS_LIB_PATH = ../Librerias/componenteslib/work_ghdl
#LIBDIR = $(COMPONENTS_LIB_PATH)

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS = --ieee=synopsys --warn-no-vital-generic -v --std=02
#GHDL_LIB_FLAG = -P$(LIBDIR)
SIMDIR = work_ghdl

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
#GHDL_SIM_OPT = --stop-time=500ns
#WAVEFORM_VIEWER = gtkwave

# ISE
#ISEDIR = ise


#all: compile run view

#new :
#	echo "Setting up project ${PROJECT}"
#	mkdir ${SRCDIR} ${TESTSDIR} $(SIMDIR) $(ISEDIR)

#file_check:
#ifeq ($(strip $(FILES)),)
#	@echo "FILES not set. Use FILES=value to set it. Put mutltiple files in quotes"
#	@exit 2
#endif

#testbench_check:
#ifeq ($(strip $(TESTBENCH)),)
#	@echo "TESTBENCH not set. Use TESTBENCH=value to set it."
#	@exit 2
#endif

all: import compile

import:
#	mkdir -p simulation
	#$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=$(SIMDIR) --work=$(LIB_NAME) $(TESTBENCHPATH) $(FILES)
	$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=$(SIMDIR) --work=$(LIB_NAME) $(PKG_FILE) $(FILES)

compile :
#	testbench_check
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(GHDL_LIB_FLAG) --workdir=$(SIMDIR) --work=$(LIB_NAME) $(PKG_FILE)
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(GHDL_LIB_FLAG) --workdir=$(SIMDIR) --work=$(LIB_NAME) $(FILES)
#	$(GHDL_CMD) -m $(GHDL_FLAGS) $(GHDL_LIB_FLAG) --workdir=$(SIMDIR) --work=work $(FILES)
#	$(GHDL_CMD) -m $(GHDL_FLAGS) $(GHDL_LIB_FLAG) --workdir=$(SIMDIR) --work=work -o $(SIMDIR)/$(TESTBENCH) $(TESTBENCH)
#	$(GHDL_CMD) --gen-makefile $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCH) > makefile2
#	@mv $(TESTBENCH) simulation/$(TESTBENCH)

#run :
#	@$(SIMDIR)/$(TESTBENCH) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(TESTBENCH).vcdgz

#view :
#	gunzip --stdout $(SIMDIR)/$(TESTBENCH).vcdgz | $(WAVEFORM_VIEWER) --vcd &

clean :
	$(GHDL_CMD) --clean --workdir=$(SIMDIR)
	@rm $(SIMDIR)/*
