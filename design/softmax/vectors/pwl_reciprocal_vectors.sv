// Auto-generated — do not edit.
// Source: py/Softmax/pwl_reciprocal.py -v
// Format: Q16.16 signed 32-bit fixed-point, paper eq. 2
//
// Mapping  d  →  pwl_recip(d)  for d ∈ [1.000, 256.000]
// at step = 16 Q16.16 LSBs (≈ 0.000244).  1044481 vectors.
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
//   localparam int          PWL_RECIP_NUM
//   localparam logic        PWL_RECIP_D_MIN_Q / _MAX_Q / _STEP_Q
//   reg [31:0]              PWL_RECIP_D [0:PWL_RECIP_NUM-1]
//   reg [31:0]              PWL_RECIP_R [0:PWL_RECIP_NUM-1]
//   task                    pwl_recip_load_vectors()
//   function                pwl_recip_d_at(int i)         // → [31:0]
//   function                pwl_recip_expected([31:0] d)  // → [31:0]
//
// Example use (inside an `initial` block of any tb):
//
//   pwl_recip_load_vectors();
//   for (int i = 0; i < PWL_RECIP_NUM; i++) begin
//       d = pwl_recip_d_at(i); #1;
//       if (recip !== pwl_recip_expected(d)) $fatal;
//   end
//
// .mem files: vectors/pwl_reciprocal_in.mem
//             vectors/pwl_reciprocal_out.mem
// (paths relative to sim cwd, matching softmax_tb.sv)

localparam int          PWL_RECIP_NUM      = 1044481;
localparam logic [31:0] PWL_RECIP_D_MIN_Q  = 32'h00010000;  // 1.000
localparam logic [31:0] PWL_RECIP_D_MAX_Q  = 32'h01000000;  // 256.000
localparam logic [31:0] PWL_RECIP_D_STEP_Q = 32'h00000010;  // 16 LSB

// Parallel input / expected-output tables.  Row i of PWL_RECIP_R is
// the golden reciprocal for row i of PWL_RECIP_D.
reg [31:0] PWL_RECIP_D [0:PWL_RECIP_NUM-1];
reg [31:0] PWL_RECIP_R [0:PWL_RECIP_NUM-1];

// Load the golden tables from disk.  Call once in `initial`.
task automatic pwl_recip_load_vectors;
begin
    $readmemh("vectors/pwl_reciprocal_in.mem",  PWL_RECIP_D);
    $readmemh("vectors/pwl_reciprocal_out.mem", PWL_RECIP_R);
end
endtask

// Returns the i-th input d in the sweep (0 ≤ i < PWL_RECIP_NUM).
// Reads from PWL_RECIP_D so it works for any vector layout the .mem
// files happen to contain (contiguous or not).
function automatic [31:0] pwl_recip_d_at(input int i);
begin
    pwl_recip_d_at = PWL_RECIP_D[i];
end
endfunction

// Golden mapping  d → pwl_recip(d).
// O(1) lookup against the contiguous sweep:  idx = (d - D_MIN) / STEP.
// Returns 32'hx if d is outside [D_MIN, D_MAX] or not on a step
// boundary, so any out-of-coverage check surfaces as a clear mismatch
// instead of a silent rounded read.
function automatic [31:0] pwl_recip_expected(input [31:0] d);
    int diff;
    int idx;
begin
    if (d < PWL_RECIP_D_MIN_Q || d > PWL_RECIP_D_MAX_Q)
        pwl_recip_expected = 32'hxxxxxxxx;
    else begin
        diff = d - PWL_RECIP_D_MIN_Q;
        if ((diff % PWL_RECIP_D_STEP_Q) != 0)
            pwl_recip_expected = 32'hxxxxxxxx;  // not on a sweep tick
        else begin
            idx = diff / PWL_RECIP_D_STEP_Q;
            pwl_recip_expected = PWL_RECIP_R[idx];
        end
    end
end
endfunction
