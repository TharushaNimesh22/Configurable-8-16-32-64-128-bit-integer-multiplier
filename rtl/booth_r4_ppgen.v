// Radix 4 Booth partial product generator
module booth_r4_ppgen #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]                   a,
    input  wire [WIDTH-1:0]                   b,
    output wire [(WIDTH/2+2)*2*WIDTH-1:0]     rows   // NR rows of PW bits
);
    localparam ND = WIDTH/2 + 1;   // Booth digits
    localparam M  = 2*ND;          // zero extended multiplier width
    localparam PW = 2*WIDTH;       // Width of each partial product row

    // multiplier with zero extension on top and implicit b[-1] = 0 at bottom
    wire [M:0]    bx = {{(M-WIDTH){1'b0}}, b, 1'b0};
    wire [PW-1:0] a1 = {{WIDTH{1'b0}}, a};   // A
    wire [PW-1:0] a2 = a1 << 1;              // 2A

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
