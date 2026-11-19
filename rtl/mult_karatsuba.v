module mult_karatsuba #(
    parameter WIDTH = 64,
    parameter BASE  = 16
)(
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output wire [2*WIDTH-1:0] p
);
    generate
        if (WIDTH < 2*BASE) begin : g_leaf
            mult_booth_wallace #(.WIDTH(WIDTH)) u_leaf (.a(a), .b(b), .p(p));
        end else begin : g_split
            localparam H  = WIDTH / 2;      // low half width
            localparam HI = WIDTH - H;      // high half width (>= H)

            wire [H-1:0]  a0 = a[H-1:0];
            wire [H-1:0]  b0 = b[H-1:0];
            wire [HI-1:0] a1 = a[WIDTH-1:H];
            wire [HI-1:0] b1 = b[WIDTH-1:H];

            wire [HI:0]   as = a1 + a0;     // one bit wider (may carry)
            wire [HI:0]   bs = b1 + b0;

            wire [2*H-1:0]    z0;
            wire [2*HI-1:0]   z2;
            wire [2*HI+1:0]   zm;

            mult_karatsuba #(.WIDTH(H),    .BASE(BASE)) u_z0 (.a(a0), .b(b0), .p(z0));
            mult_karatsuba #(.WIDTH(HI),   .BASE(BASE)) u_z2 (.a(a1), .b(b1), .p(z2));
            mult_karatsuba #(.WIDTH(HI+1), .BASE(BASE)) u_zm (.a(as), .b(bs), .p(zm));

            wire [2*WIDTH-1:0] z1 = zm - z2 - z0;

            assign p = (z2 << (2*H)) + (z1 << H) + z0;
        end
    endgenerate
endmodule
