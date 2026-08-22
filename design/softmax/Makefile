# Makefile for softmax_subenv_tb
#
# Usage:
#   make            # compile + run                                 (iverilog)
#   make run        # run already-compiled sim                      (iverilog)
#   make wave       # compile + run with $dumpvars, open GTKWave    (iverilog)
#   make view       # open existing VCD in GTKWave (no recompile)
#   make cov        # build+run under Verilator with --coverage,    (Verilator)
#                   # then verilator_coverage --annotate, open report
#   make lint       # iverilog syntax check only (no elaboration output)
#   make clean      # remove build artifacts
#
# Why `cov` uses Verilator: iverilog has no coverage support at all.
# All other targets stay on iverilog because the TB was written for it.

# ---- Tools --------------------------------------------------------------
IVERILOG  ?= iverilog
VVP       ?= vvp
GTKWAVE   ?= gtkwave
VERILATOR ?= verilator
VLT_COV   ?= verilator_coverage

# ---- Files --------------------------------------------------------------
TOP       := softmax_subenv_tb
TB        := softmax_subenv_tb.sv

# RTL sources required to elaborate the DUT hierarchy.
# `include`d files (agent.sv, softmax_coverage.sv, softmax_vectors.sv) are
# pulled in by the TB and must NOT appear on the command line.
RTL := \
    softmax_subenv.v   \
    softmax_crtl_fsm.v \
    softmax_dma.v      \
    shift_exp.v        \
    pwl_reciprocal.v

SRCS := $(RTL) $(TB)

# Output artifacts (iverilog flow)
OUT      := $(TOP).vvp
VCD      := $(TOP).vcd
COV_TXT  := softmax_coverage.txt
COV_HTML := softmax_coverage.html

# Verilator artifacts.  Build dir lives in /tmp because GNU Make cannot
# build inside a path containing spaces, and this project lives under
# "EE Project".  Coverage data lands back in the project dir.
VLT_MDIR := /tmp/softmax_cov_obj
VLT_BIN  := $(VLT_MDIR)/softmax_subenv_tb_vlt
COV_DAT  := coverage/coverage.dat
COV_ANN  := coverage/cov_annotated

# ---- Flags --------------------------------------------------------------
# -g2012 : SystemVerilog 2012 (classes, $urandom_range, $sformatf, etc.)
# -I .   : honour `include` paths inside this directory
IFLAGS := -g2012 -I . -I vectors

# ---- Default goal -------------------------------------------------------
.PHONY: all
all: run

# ---- Compile ------------------------------------------------------------
$(OUT): $(SRCS)
	$(IVERILOG) $(IFLAGS) -s $(TOP) -o $@ $(SRCS)

.PHONY: compile
compile: $(OUT)

# ---- Run (no waveform) --------------------------------------------------
.PHONY: run
run: $(OUT)
	$(VVP) $(OUT)

# ---- Run with waveform dump --------------------------------------------
# The TB checks $test$plusargs("WAVE"); we pass +WAVE to enable it.
.PHONY: wave
wave: $(OUT)
	$(VVP) $(OUT) +WAVE
	@if [ -f $(VCD) ]; then $(GTKWAVE) $(VCD) & fi

# ---- View existing VCD --------------------------------------------------
.PHONY: view
view:
	@test -f $(VCD) || { echo "No $(VCD) found; run 'make wave' first."; exit 1; }
	$(GTKWAVE) $(VCD) &

# ---- Coverage (Verilator) ------------------------------------------------
# Verilator gives real line / toggle / branch / expression coverage.
# Covergroup bins are currently silently ignored by Verilator 5.x (-Wno-COVERIGN
# suppresses the noise), so the `softmax_cg` block compiles but contributes
# nothing — the value here is structural coverage of the RTL, not bins.
#
# --timing is required because the TB uses #delay and @event control.
# --Mdir keeps the build dir out of the spaces-containing project path.
VLT_FLAGS := \
    --Mdir $(VLT_MDIR) \
    --binary --timing \
    --coverage --coverage-line --coverage-toggle --coverage-user \
    +define+COVERGROUP_OK \
    -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND -Wno-COVERIGN \
    -Wno-CASEINCOMPLETE -Wno-UNOPTFLAT \
    -sv --top-module $(TOP) \
    -o softmax_subenv_tb_vlt

.PHONY: cov
cov: $(SRCS)
	@echo "==> Verilator build (coverage)"
	$(VERILATOR) $(VLT_FLAGS) $(SRCS)
	@echo "==> Run"
	$(VLT_BIN)
	@echo "==> Annotate"
	@rm -rf $(COV_ANN)
	$(VLT_COV) --annotate $(COV_ANN) $(COV_DAT)
	@echo "Coverage report : $(COV_ANN)/  (annotated sources)"
	@echo "Raw data        : $(COV_DAT)"
	@echo "Manual dump     : $(COV_HTML) / $(COV_TXT)"
	@( command -v open     >/dev/null 2>&1 && open     $(COV_ANN) ) || \
	 ( command -v xdg-open >/dev/null 2>&1 && xdg-open $(COV_ANN) ) || true

# ---- Syntax-only check --------------------------------------------------
.PHONY: lint
lint:
	$(IVERILOG) $(IFLAGS) -t null -s $(TOP) $(SRCS)

# ---- Clean --------------------------------------------------------------
.PHONY: clean
clean:
	rm -f $(OUT) $(VCD) $(TOP) *.vvp $(COV_TXT) $(COV_HTML) $(COV_DAT)
	rm -rf $(VLT_MDIR) $(COV_ANN)
