# =============================================================================
# Makefile — sigmoid sub-environment (also serves tanh / GELU via opcode)
# =============================================================================
#   make        compile
#   make run    compile + run
#   make clean  remove sim binary and waveforms
#
# Layout:  sources + testbenches side by side | vectors/ `include stimulus
# =============================================================================

IVERILOG   = iverilog
VVP        = vvp
# vectors/ is on the include path so the testbenches' `include
# "sigmoid_vectors.sv" (etc.) resolve.
FLAGS      = -g2012 -I. -Ivectors

SIM        = sim_sigmoid_subenv

SOURCES    = sigmoid_subenv_tb.sv \
             sigmoid_subenv.v \
             sigmoid.v \
             MUX4_32bit.v

.PHONY: all run clean

all: $(SIM)

$(SIM): $(SOURCES)
	$(IVERILOG) $(FLAGS) -o $(SIM) $(SOURCES)

run: $(SIM)
	$(VVP) $(SIM)

clean:
	rm -f $(SIM) *.vcd
