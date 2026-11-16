// ============================================================================
// Carry-Save Adder (3:2 compressor) - building block for architectures 3-6
//   Search terms : "carry save adder", "3:2 compressor", "full adder array"
// Adds THREE numbers and returns TWO numbers (sum, carry) with sum+carry = x+y+z.
// Every bit is an independent full adder -> no carry ripples, constant delay.
// ============================================================================
module csa #(
    parameter W = 16
)(
    input  wire [W-1:0] x,
    input  wire [W-1:0] y,
    input  wire [W-1:0] z,
    output wire [W-1:0] s,
    output wire [W-1:0] c
);
    assign s = x ^ y ^ z;                              // sum bits
    assign c = ((x & y) | (x & z) | (y & z)) << 1;     // carries, weight x2
endmodule
