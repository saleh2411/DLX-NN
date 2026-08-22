# =============================================================================
# Makefile — full Activation Engine simulation
# =============================================================================
# Edit sources.f to add/remove/disable RTL files.
# Pick the testbench by overriding TB on the command line.
#
# -----------------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------------
#   make            Compile the simulation binary ($(SIM))
#   make run        Compile (if needed) and run the simulation with vvp
#   make list       Print the testbench and the RTL files that will compile
#                   (good sanity check after editing sources.f)
#   make clean      Remove the simulation binary and any .vcd waveforms
#
# -----------------------------------------------------------------------------
# Usage examples
# -----------------------------------------------------------------------------
#   # 1. Default build + run (uses TB below)
#   make run
#
#   # 2. Run a specific sub-env testbench without editing the Makefile
#   make TB=softmax/softmax_subenv_tb.sv run
#   make TB=sigmoid/sigmoid_subenv_tb.sv run
#   make TB=sigmoid/archive/activation_unit_tb.sv run
#
#   # 3. Just see what files would be compiled with the current sources.f
#   make list
#
#   # 4. Compile only (no run) — useful to catch syntax/elaboration errors
#   make
#
#   # 5. One-liner: clean, then rebuild and run a specific TB
#   make clean && make TB=softmax/softmax_subenv_tb.sv run
#
#   # 6. Persistent override: change the TB ?= line below, then just `make run`.
#
# -----------------------------------------------------------------------------
# Adding / removing files
# -----------------------------------------------------------------------------
#   * To add a new RTL file, append its path (relative to this directory) to
#     the appropriate sub-env section in sources.f.
#   * To temporarily disable a file, prefix its line in sources.f with `//`.
#   * Testbenches do NOT go in sources.f — pass them via TB=... instead,
#     otherwise multiple top modules will collide.
# =============================================================================

IVERILOG = iverilog
VVP      = vvp
# Each sub-env keeps its `include stimulus under <subenv>/vectors, so both the
# sub-env dir and its vectors dir go on the include path.
FLAGS    = -g2012 -I. \
           -Isigmoid -Isigmoid/vectors \
           -Irelu \
           -Isoftmax -Isoftmax/vectors

SIM      = sim_activation
SRC_LIST = sources.f

# Default testbench — override with `make TB=<path>`
TB ?= sigmoid/sigmoid_subenv_tb.sv

# Extract the non-commented source paths from sources.f so the build
# re-runs whenever any listed file changes.
SOURCES := $(shell awk '!/^[[:space:]]*(\/\/|\#|$$)/ {print $$1}' $(SRC_LIST))

.PHONY: all run clean list

all: $(SIM)

$(SIM): $(SRC_LIST) $(TB) $(SOURCES)
	$(IVERILOG) $(FLAGS) -o $(SIM) -c $(SRC_LIST) $(TB)

run: $(SIM)
	$(VVP) $(SIM)

# Show which files will actually be compiled (handy for sanity-checking sources.f)
list:
	@echo "Testbench: $(TB)"
	@echo "RTL sources:"
	@printf '  %s\n' $(SOURCES)

clean:
	rm -f $(SIM) *.vcd
