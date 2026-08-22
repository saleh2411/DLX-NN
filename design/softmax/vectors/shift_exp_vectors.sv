// Auto-generated — do not edit.
// Source: py/Softmax/shift_exp.py -v
// Format: Q16.16 signed 32-bit fixed-point, paper eq. 1
//
// Mapping  x  →  shift_exp(x)  for x ∈ [-10.000, 0.000]
// at full Q16.16 resolution (step 2^-16).  655361 vectors → 100% coverage
// of the softmax operating range, identical to the Python sweep used
// for error analysis.
//
// Inputs and expected outputs live in two parallel `.mem` files,
// matching the tcXX_in.mem / tcXX_out.mem convention used by
// softmax_tb.sv.  Row i of *_out.mem is the golden output for row i
// of *_in.mem.
//
// `\`include`-able from inside any tb module so the same golden
// table is available at the unit, sub-env, and top-model level.
//
// Provides:
//   localparam int          SHIFT_EXP_NUM
//   localparam logic signed SHIFT_EXP_X_MIN_Q / _MAX_Q / _STEP_Q
//   reg [31:0]              SHIFT_EXP_X [0:SHIFT_EXP_NUM-1]
//   reg [31:0]              SHIFT_EXP_Y [0:SHIFT_EXP_NUM-1]
//   task                    shift_exp_load_vectors()
//   function                shift_exp_x_at(int i)         // → [31:0]
//   function                shift_exp_expected([31:0] x)  // → [31:0]
//
// Example use (inside an `initial` block of any tb):
//
//   shift_exp_load_vectors();
//   for (int i = 0; i < SHIFT_EXP_NUM; i++) begin
//       x = shift_exp_x_at(i); #1;
//       if (out !== shift_exp_expected(x)) $fatal;
//   end
//
// .mem files: vectors/shift_exp_in.mem
//             vectors/shift_exp_out.mem
// (paths relative to sim cwd, matching softmax_tb.sv)

localparam int                 SHIFT_EXP_NUM      = 655361;
localparam logic signed [31:0] SHIFT_EXP_X_MIN_Q  = 32'hFFF60000;  // -10.000
localparam logic signed [31:0] SHIFT_EXP_X_MAX_Q  = 32'h00000000;  // 0.000
localparam logic signed [31:0] SHIFT_EXP_X_STEP_Q = 32'h00000001;  // 2^-16

// Parallel input / expected-output tables.  Row i of SHIFT_EXP_Y is
// the golden output for row i of SHIFT_EXP_X.
reg [31:0] SHIFT_EXP_X [0:SHIFT_EXP_NUM-1];
reg [31:0] SHIFT_EXP_Y [0:SHIFT_EXP_NUM-1];

// Load the golden tables from disk.  Call once in `initial`.
task automatic shift_exp_load_vectors;
begin
    $readmemh("vectors/shift_exp_in.mem",  SHIFT_EXP_X);
    $readmemh("vectors/shift_exp_out.mem", SHIFT_EXP_Y);
end
endtask

// Returns the i-th input x in the sweep (0 ≤ i < SHIFT_EXP_NUM).
// Reads from SHIFT_EXP_X so it works for any vector layout the .mem
// files happen to contain (contiguous or not).
function automatic [31:0] shift_exp_x_at(input int i);
begin
    shift_exp_x_at = SHIFT_EXP_X[i];
end
endfunction

// Golden mapping  x → shift_exp(x).
// O(1) lookup: the sweep is contiguous at step = 2^-16, so the index
// is just (x - X_MIN).  Inputs outside the swept range return 32'hx
// so any out-of-coverage check surfaces as an obvious mismatch.
function automatic [31:0] shift_exp_expected(input [31:0] x);
    logic signed [31:0] xs;
    int                 idx;
begin
    xs = $signed(x);
    if (xs < $signed(SHIFT_EXP_X_MIN_Q) || xs > $signed(SHIFT_EXP_X_MAX_Q))
        shift_exp_expected = 32'hxxxxxxxx;
    else begin
        idx = xs - $signed(SHIFT_EXP_X_MIN_Q);  // step = 1 LSB
        shift_exp_expected = SHIFT_EXP_Y[idx];
    end
end
endfunction
