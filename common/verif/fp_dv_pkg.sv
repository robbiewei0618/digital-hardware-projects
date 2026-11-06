// =============================================================================
// fp_dv_pkg.sv - shared verification helpers for the floating-point projects
//
//  * DPI-C imports of the exact reference model (common/fpref/fpref.c)
//  * operand generators biased toward the cases that break FP datapaths
//    (subnormals, exponent extremes, cancellation, rounding ties ...)
//  * result comparison and a small pass/fail bookkeeping class
//
// Stimulus is generated procedurally with $urandom rather than randomize():
// the Verilator simulator solves class constraints with an external SMT solver
// (~5 ms per randomize() call), which is far too slow for the 10^5-10^6
// vectors per run used here. The weights below play the role of `dist`.
// =============================================================================
package fp_dv_pkg;

  // ---------------------------------------------------------------- DPI model
  import "DPI-C" function int unsigned fpref_add(input int fmt, input int unsigned a,
      input int unsigned b, input int mode, output int flags);
  import "DPI-C" function int unsigned fpref_mul(input int fmt, input int unsigned a,
      input int unsigned b, input int mode, output int flags);
  import "DPI-C" function int unsigned fpref_fma(input int fmt, input int unsigned a,
      input int unsigned b, input int unsigned c, input int mode, output int flags);
  import "DPI-C" function int unsigned fpref_dot4(input int fmt,
      input int unsigned x1, input int unsigned x2, input int unsigned x3, input int unsigned x4,
      input int unsigned y1, input int unsigned y2, input int unsigned y3, input int unsigned y4,
      input int mode, output int flags);

  localparam int FP32 = 0, FP16 = 1;
  localparam int MODE_IEEE = 0, MODE_FTZ = 1, MODE_DAZ = 2;

  localparam int F_INEXACT    = 'h01;
  localparam int F_ROUND_UP   = 'h02;
  localparam int F_TIE        = 'h04;
  localparam int F_TINY       = 'h08;
  localparam int F_FLUSHED    = 'h10;
  localparam int F_OVERFLOW   = 'h20;
  localparam int F_EXACT_ZERO = 'h40;

  // operand / result classes (coverage)
  typedef enum int { CL_ZERO, CL_SUB, CL_NORM, CL_INF, CL_NAN } fp_class_e;
  // rounding outcome (coverage)
  typedef enum int { RD_EXACT, RD_DOWN, RD_UP, RD_TIE_EVEN, RD_TIE_UP } round_e;

  // ------------------------------------------------------------ format info
  function automatic int ebits(int fmt); return fmt == FP16 ? 5 : 8;   endfunction
  function automatic int mbits(int fmt); return fmt == FP16 ? 10 : 23; endfunction
  function automatic int bias(int fmt);  return fmt == FP16 ? 15 : 127; endfunction
  function automatic int emax_raw(int fmt); return (1 << ebits(fmt)) - 1; endfunction

  function automatic int unsigned fp_pack(int fmt, bit s, int unsigned e, int unsigned m);
    return (int'(s) << (ebits(fmt) + mbits(fmt))) | (e << mbits(fmt)) | (m & ((1 << mbits(fmt)) - 1));
  endfunction

  function automatic int unsigned fp_exp(int fmt, int unsigned x);
    return (x >> mbits(fmt)) & emax_raw(fmt);
  endfunction
  function automatic int unsigned fp_frac(int fmt, int unsigned x);
    return x & ((1 << mbits(fmt)) - 1);
  endfunction
  function automatic bit fp_sign(int fmt, int unsigned x);
    return x[ebits(fmt) + mbits(fmt)];
  endfunction

  function automatic fp_class_e fp_class(int fmt, int unsigned x);
    int unsigned e = fp_exp(fmt, x), m = fp_frac(fmt, x);
    if (e == emax_raw(fmt)) return m ? CL_NAN : CL_INF;
    if (e == 0) return m ? CL_SUB : CL_ZERO;
    return CL_NORM;
  endfunction

  function automatic round_e round_kind(int flags, int unsigned result);
    if (!(flags & F_INEXACT)) return RD_EXACT;
    if (flags & F_TIE) return (flags & F_ROUND_UP) ? RD_TIE_UP : RD_TIE_EVEN;
    return (flags & F_ROUND_UP) ? RD_UP : RD_DOWN;
  endfunction

  // bit-exact compare; any NaN matches any NaN (payload is implementation
  // defined) - the per-design SVA checks the canonical NaN separately
  function automatic bit fp_same(int fmt, int unsigned dut, int unsigned ref_v);
    if (fp_class(fmt, ref_v) == CL_NAN) return fp_class(fmt, dut) == CL_NAN;
    return dut == ref_v;
  endfunction

  // ------------------------------------------------------- random operands
  typedef enum int { G_ZERO, G_SUB, G_TINY, G_NORM, G_NEAR1, G_HUGE, G_EDGE, G_INF, G_NAN } gen_cat_e;

  // weighted category pick (the procedural equivalent of a `dist`)
  function automatic gen_cat_e pick_cat(bit allow_special = 1);
    int r = $urandom_range(0, 99);
    if (r < 4)  return G_ZERO;
    if (r < 10) return G_SUB;
    if (r < 18) return G_TINY;
    if (r < 60) return G_NORM;
    if (r < 75) return G_NEAR1;
    if (r < 85) return G_HUGE;
    if (r < 92) return G_EDGE;
    if (!allow_special) return G_NORM;
    if (r < 96) return G_INF;
    return G_NAN;
  endfunction

  function automatic int unsigned rand_mant(int fmt);
    // mix of uniform, all-ones, all-zeros, single-bit and sparse patterns
    int unsigned m, mask = (1 << mbits(fmt)) - 1;
    case ($urandom_range(0, 9))
      0: m = mask;
      1: m = 0;
      2: m = 1 << $urandom_range(0, mbits(fmt) - 1);
      3: m = $urandom & $urandom & $urandom;
      4: m = mask ^ (1 << $urandom_range(0, mbits(fmt) - 1));
      default: m = $urandom;
    endcase
    return m & mask;
  endfunction

  function automatic int unsigned rand_fp(int fmt, gen_cat_e c);
    bit s = $urandom_range(0, 1);
    int emax = emax_raw(fmt);
    int unsigned m = rand_mant(fmt);
    case (c)
      G_ZERO:  return fp_pack(fmt, s, 0, 0);
      G_SUB:   return fp_pack(fmt, s, 0, m == 0 ? 1 : m);
      G_TINY:  return fp_pack(fmt, s, $urandom_range(1, (fmt == FP16) ? 3 : 24), m);
      G_NEAR1: return fp_pack(fmt, s, bias(fmt) + $urandom_range(0, 2) - 1, m);
      G_HUGE:  return fp_pack(fmt, s, emax - 1 - $urandom_range(0, (fmt == FP16) ? 2 : 16), m);
      G_EDGE: begin
        case ($urandom_range(0, 4))
          0: return fp_pack(fmt, s, 0, 1);                       // min subnormal
          1: return fp_pack(fmt, s, 0, (1 << mbits(fmt)) - 1);   // max subnormal
          2: return fp_pack(fmt, s, 1, 0);                       // min normal
          3: return fp_pack(fmt, s, emax - 1, (1 << mbits(fmt)) - 1); // max finite
          default: return fp_pack(fmt, s, bias(fmt), 0);         // +-1.0
        endcase
      end
      G_INF:   return fp_pack(fmt, s, emax, 0);
      G_NAN:   return fp_pack(fmt, s, emax, m == 0 ? 1 : m);
      default: return fp_pack(fmt, s, $urandom_range(1, emax - 1), m);
    endcase
  endfunction

  function automatic int unsigned rand_any(int fmt, bit allow_special = 1);
    return rand_fp(fmt, pick_cat(allow_special));
  endfunction

  // b chosen relative to a: same/near exponent, cancellation, exact negation
  function automatic int unsigned rand_partner(int fmt, int unsigned a);
    int unsigned e = fp_exp(fmt, a);
    int emax = emax_raw(fmt);
    int d;
    case ($urandom_range(0, 5))
      0: return a ^ (1 << (ebits(fmt) + mbits(fmt)));                         // -a  (x + -x)
      1: return (a ^ (1 << (ebits(fmt) + mbits(fmt)))) + $urandom_range(0, 3);  // near cancellation
      2: return a ^ (1 << (ebits(fmt) + mbits(fmt))) ^ (1 << $urandom_range(0, mbits(fmt) - 1));
      default: begin                                                           // controlled exponent gap
        d = $urandom_range(0, 3) == 0 ? $urandom_range(0, 2) : $urandom_range(0, mbits(fmt) + 6);
        if ($urandom_range(0, 1)) d = -d;
        d = int'(e) + d;
        if (d < 0) d = 0;
        if (d > emax - 1) d = emax - 1;
        return fp_pack(fmt, $urandom_range(0, 1), d, rand_mant(fmt));
      end
    endcase
  endfunction

  // ------------------------------------------------------------- bookkeeping
  // every assertion's fail action increments this, so a run reports *all*
  // failures (run with +verilator+error+limit+N) and still fails at the end
  int unsigned sva_errors = 0;

  class check_stats;
    string name;
    longint unsigned n_checks, n_errors;
    int max_print = 8;

    function new(string name);
      this.name = name;
    endfunction

    function void check(bit ok, string what);
      n_checks++;
      if (!ok) begin
        n_errors++;
        if (n_errors <= max_print) $display("[MISMATCH] %-18s %s", name, what);
      end
    endfunction

    function void report();
      $display("  %-18s checks=%0d  errors=%0d  %s", name, n_checks, n_errors,
               n_errors == 0 && n_checks > 0 ? "PASS" : "FAIL");
    endfunction

    function bit passed();
      return n_errors == 0 && n_checks > 0;
    endfunction
  endclass

endpackage
