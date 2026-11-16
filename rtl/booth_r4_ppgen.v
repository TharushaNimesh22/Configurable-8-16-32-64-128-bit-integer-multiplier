// ============================================================================
// Radix-4 Booth Partial-Product Generator (used by architectures 4, 5, 6)
//   Search terms : "radix-4 Booth encoding", "Booth partial product generation"
// Produces WIDTH/2+1 Booth rows + 1 correction row = WIDTH/2+2 rows, each
// 2*WIDTH bits wide, already shifted into position. Their sum = a*b.
//
// Negative rows are formed as  ~(|d|*a)  and the "+1" needed to complete the
// two's complement negation is collected into one extra correction row
// (one bit per Booth digit). This avoids a separate negation adder per row.
// All arithmetic is modulo 2^(2*WIDTH), which is exact because a*b < 2^(2*WIDTH).
// ============================================================================
module booth_r4_ppgen #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]                   a,
    input  wire [WIDTH-1:0]                   b,
    output wire [(WIDTH/2+2)*2*WIDTH-1:0]     rows   // NR rows of PW bits
);
    localparam ND = WIDTH/2 + 1;   // Booth digits
    localparam M  = 2*ND;          // zero-extended multiplier width
    localparam PW = 2*WIDTH;

    // multiplier with zero extension on top and implicit b[-1] = 0 at bottom
    wire [M:0]    bx = {{(M-WIDTH){1'b0}}, b, 1'b0};
    wire [PW-1:0] a1 = {{WIDTH{1'b0}}, a};   // 1*a
    wire [PW-1:0] a2 = a1 << 1;              // 2*a

    wire [PW-1:0] corr_bits [0:ND];          // accumulates the +1 bits
    assign corr_bits[0] = {PW{1'b0}};

    genvar i;
    generate
        for (i = 0; i < ND; i = i + 1) begin : g_digit
            wire [2:0]    t   = bx[2*i+2 : 2*i];
            wire          one = t[1] ^ t[0];
            wire          two = (t[2] ^ t[1]) & ~(t[1] ^ t[0]);
            wire          neg = t[2];
            wire [PW-1:0] mag = one ? a1 : (two ? a2 : {PW{1'b0}});
            wire [PW-1:0] row = (mag ^ {PW{neg}}) << (2*i);

            assign rows[i*PW +: PW] = row;
            assign corr_bits[i+1]   = corr_bits[i] |
                                      ({{(PW-1){1'b0}}, neg} << (2*i));
        end
    endgenerate

    assign rows[ND*PW +: PW] = corr_bits[ND];   // correction row
endmodule
