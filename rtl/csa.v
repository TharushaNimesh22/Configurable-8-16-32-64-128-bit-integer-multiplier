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
