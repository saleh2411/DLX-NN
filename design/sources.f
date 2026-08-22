// =============================================================================
// Activation Engine — RTL source file list
// =============================================================================
// This file lists every RTL source compiled into the full activation-unit
// simulation. Comment out a line with `//` to exclude a file from the build.
//
// Paths are relative to this directory (design/).
// The testbench is NOT listed here — it is selected via the TB variable in
// the Makefile (e.g. `make TB=path/to/my_tb.sv`).
//
// Layout per sub-environment:  sources + testbenches together | vectors/ stimulus
// =============================================================================


// -----------------------------------------------------------------------------
// Top level
// -----------------------------------------------------------------------------
ActivationEngine.v


// -----------------------------------------------------------------------------
// Sigmoid sub-environment (also serves tanh/GELU via opcode)
// -----------------------------------------------------------------------------
sigmoid/sigmoid_subenv.v
sigmoid/sigmoid.v
sigmoid/MUX4_32bit.v


// -----------------------------------------------------------------------------
// ReLU sub-environment
// -----------------------------------------------------------------------------
relu/ReLU.v


// -----------------------------------------------------------------------------
// Softmax sub-environment
// -----------------------------------------------------------------------------
// These were commented out during the v2 rewrite. They are re-enabled: the RTL
// below elaborates and softmax/ `make run` reports ALL TESTS PASSED.
// Comment a line out again to exclude it from the build.
softmax/softmax_subenv.v
softmax/softmax_crtl_fsm.v
softmax/softmax_dma.v
softmax/mem_arbiter.v
softmax/pwl_reciprocal.v
softmax/shift_exp.v
