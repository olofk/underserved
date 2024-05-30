# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES =               \
underserved.v		        \
subservient_gpio.v	        \
rf_shift_reg.v                  \
spimemio.v		        \
serv_1.2.1/rtl/serv_aligner.v   \
serv_1.2.1/rtl/serv_rf_top.v    \
serv_1.2.1/rtl/serv_csr.v       \
serv_1.2.1/rtl/serv_compdec.v   \
serv_1.2.1/rtl/serv_rf_ram.v    \
serv_1.2.1/rtl/serv_bufreg2.v   \
serv_1.2.1/rtl/serv_bufreg.v    \
serv_1.2.1/rtl/serv_top.v       \
serv_1.2.1/rtl/serv_immdec.v    \
serv_1.2.1/rtl/serv_rf_if.v     \
serv_1.2.1/rtl/serv_ctrl.v      \
serv_1.2.1/rtl/serv_rf_ram_if.v \
serv_1.2.1/rtl/serv_state.v     \
serv_1.2.1/rtl/serv_mem_if.v    \
serv_1.2.1/rtl/serv_decode.v    \
serv_1.2.1/rtl/serv_alu.v

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -I$(SRC_DIR)

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/spiflash.v $(PWD)/tb.v
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
