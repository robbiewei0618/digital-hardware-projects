//=============================================================================
// Module: multiply_row_opt
// Description: 8x8 signed multiplier using row accumulation
//              "Optimized" sign-extension by relying on signed arithmetic
//              instead of手動展開一整牆 sign bits
//=============================================================================
module multiply_row_opt #(
    parameter M = 8,
    parameter N = 16
)(
    input  wire [M-1:0]  a,   // signed multiplicand
    input  wire [N-1:0]  b,   // signed multiplier
    output wire [M+N-1:0] p    // signed product
);

    // 固定 8x8 → MN = 16
    localparam MN = M + N;

    // 轉成 signed 型別，讓 Verilog 自動做 sign extension
    wire signed [M-1:0]  a_s = a;
    wire signed [N-1:0]  b_s = b;

    // 把 a_s 丟進較寬的 bus → 自動 sign-extension 到 16 bits
    wire signed [MN-1:0] a_ext = a_s;

    // 部分積陣列：8 列、每列 16 bits
    wire signed [MN-1:0] pp [0:N-1];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_pp
            // 如果 b_s[i] = 1 → 產生一列 a_ext <<< i
            // 如果 b_s[i] = 0 → 該列為 0
            // 使用 signed + <<<，由語意處理符號，不再手刻一整排 sign bits
            assign pp[i] = b_s[i] ? (a_ext <<< i) : {MN{1'b0}};
        end
    endgenerate

    //=====================================================================
    // Row accumulation:
    //   - 將 pp[0] ~ pp[6] 當作「正的列」全部相加
    //   - 將 pp[7] 當作「負的列」在最後減掉
    //=====================================================================
    wire signed [MN-1:0] partial_sum [0:N];  // partial_sum[0..8]

    // 起點 = 0
    assign partial_sum[0] = {MN{1'b0}};

    // 依序累加 pp[0] ~ pp[6]（也就是 0 .. N-2）
    generate
        for (i = 0; i < N - 1; i = i + 1) begin : gen_sum_pos
            assign partial_sum[i+1] = partial_sum[i] + pp[i];
        end
    endgenerate

    // 最後：p = sum(pp[0..6]) - pp[7]
    // 對應到 2's complement：b7 是負權重 bit
    //2's complement 數學公式
    assign p = partial_sum[N-1] - pp[N-1];

endmodule
