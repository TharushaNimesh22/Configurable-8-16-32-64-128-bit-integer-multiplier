module mult_booth_wallace #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output wire [2*WIDTH-1:0] p
);
    localparam NR = WIDTH/2 + 2;
    localparam PW = 2*WIDTH;

    wire [NR*PW-1:0] rows;  // Contains pratial products and correction bits 
                            // (input to the Wallace tree and output of the Booth partial product generator)
    wire [PW-1:0]    s, c;

    booth_r4_ppgen #(.WIDTH(WIDTH)) u_pp (
        .a(a), .b(b), .rows(rows)
    );

    wallace_tree #(.N(NR), .WID(PW)) u_tree (
        .rows(rows), .s(s), .c(c)
    );

    assign p = s + c;   // final carry propagate adder
endmodule
