module mult_array_csa #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output wire [2*WIDTH-1:0] p
);
    localparam PW = 2*WIDTH;    // Product width

    wire [PW-1:0] s [0:WIDTH-1];   // running sum vector after row i
    wire [PW-1:0] c [0:WIDTH-1];   // running carry vector after row i

    // row 0
    assign s[0] = {{WIDTH{1'b0}}, (a & {WIDTH{b[0]}})};
    assign c[0] = {PW{1'b0}};

    genvar i;
    generate
        for (i = 1; i < WIDTH; i = i + 1) begin : g_row
            // partial product i : (a AND b[i]) shifted left by i
            wire [PW-1:0] pp = {{WIDTH{1'b0}}, (a & {WIDTH{b[i]}})} << i;
            csa #(.W(PW)) u_csa (
                .x(s[i-1]), .y(c[i-1]), .z(pp),
                .s(s[i]),   .c(c[i])
            );
        end
    endgenerate

    // final carry-propagate adder
    assign p = s[WIDTH-1] + c[WIDTH-1];
endmodule
