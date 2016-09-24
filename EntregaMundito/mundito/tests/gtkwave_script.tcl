# --------------------------------------------------------------------------- #
#  Facultad de Ingeniería de la Universidad de Buenos Aires
#  Sistemas Digitales
#  2° Cuatrimestre de 2015
# 
#  Sampayo, Sebastián Lucas
#  Padrón: 93793
#  e-mail: sebisampayo@gmail.com
# 
# TCL Script to automatically add all design signals from $module to the wave 
# window on startup, for GTKWave;
# ie
# > gtkwave -S gtkwave_script.tcl test.vcd
# > testprog | gtkwave -v -S gwShowall.tcl
# --------------------------------------------------------------------------- #

# Parámetros:
# Módulo cuyas señales se van a añadir:
#set module "dut"

# --------------------------------------------------------------------------- #
# Límite temporal izquierdo
# gtkwave::setFromEntry 180us

# Zoom
# gtkwave::setZoomFactor -20
#gtkwave::setZoomRangeTimes 150900ns 151200ns
gtkwave::setZoomRangeTimes 171300ns 172000ns

# --------------------------------------------------------------------------- #

# getNumFacs devuelve la cantidad de señales en el archivo dump.
set nsigs [ gtkwave::getNumFacs ]
set sigs [list]

lappend sigs "clock"
lappend sigs "go_in_ram"
lappend sigs "ce"
lappend sigs "we"
lappend sigs "write_in_ram"
lappend sigs "busy_ram"
lappend sigs "data_a"
lappend sigs "data_b"
lappend sigs "read_ram_ctrl"
lappend sigs "read_ram_ctrl_delay"
lappend sigs "uart_rxrdy"
lappend sigs "uart_rxrdy_delay"
lappend sigs "write_address_ram_counter"
lappend sigs "read_address_ram_counter"
lappend sigs "data_out_ram"
lappend sigs "a_row"
lappend sigs "a_col"
lappend sigs "video_ram_inst.mem.ram_aux"
lappend sigs "pixel_row"
lappend sigs "pixel_col"
lappend sigs "vga_pixel_in"
lappend sigs "b_row"
lappend sigs "b_col"
lappend sigs "enable_vga"
lappend sigs "enable_vga_delay"
lappend sigs "data_loader.clock"
lappend sigs "data_loader.data_in"
lappend sigs "data_loader.data_out"
lappend sigs "data_loader.RxRdy_in"
lappend sigs "data_loader.RxRdy_out"
#lappend sigs ""


# este bug no existe más
# fix a strange bug where addSignalsFromList doesn't seem to work
# if the 1st signal to be added is not a single bit
# lappend sigs "__bug_marker__" 

# Recorro la lista de señales, y agrego a solamente las que empiezan con dut.
# for {set i 0} {$i < $nsigs} {incr i} {
#   set name [ gtkwave::getFacName $i ] 
#   if { [ string match $module.* $name ] } {
#     lappend sigs $name
#     puts "$i: $name"
#   }
# }
set added [ gtkwave::addSignalsFromList $sigs ]

# ----------------------
# Devuelve el SST seleccionado
# proc tracer {varname args} {
#       upvar #0 $varname var
#           puts "$varname was updated to be \"$var\""
# }
# 
# trace add variable gtkwave::cbTreeSelect write "tracer gtkwave::cbTreeSelect"
# set sst_sel [ gtkwave::cbTreeSelect ]
# puts $sst_sel

