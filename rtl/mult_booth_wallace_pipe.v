
module mult_booth_wallace_pipe #(
    parameter WIDTH = 8
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               in_valid,
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output wire               out_valid,
    output reg  [2*WIDTH-1:0] p
);
    localparam NR = WIDTH/2 + 2;
    localparam PW = 2*WIDTH;

    // Calculate the number of Wallace tree levels
    function integer tree_levels(input integer n);
        integer k, m;
        begin
            k = 0; m = n;
            while (m > 2) begin
                m = 2*(m/3) + (m%3);
                k = k + 1;
            end
            tree_levels = k;
        end
    endfunction

    localparam L   = tree_levels(NR);
    localparam LAT = L + 3;

    // stage 1: input registers
    reg [WIDTH-1:0] a_r, b_r;
    always @(posedge clk) begin
        a_r <= a;
        b_r <= b;
    end

    // stage 2: partial products
    wire [NR*PW-1:0] rows;
    reg  [NR*PW-1:0] rows_r;
    booth_r4_ppgen #(.WIDTH(WIDTH)) u_pp (.a(a_r), .b(b_r), .rows(rows));
    always @(posedge clk) rows_r <= rows;

    // stages 3 to L+2: pipelined tree
    wire [PW-1:0] s, c;
    wallace_tree_pipe #(.N(NR), .WID(PW)) u_tree (
        .clk(clk), .rows(rows_r), .s(s), .c(c)
    );

    // stage L+3: final adder
    always @(posedge clk) p <= s + c;

    // valid shift register
    reg [LAT-1:0] vpipe;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) vpipe <= {LAT{1'b0}};
        else        vpipe <= {vpipe[LAT-2:0], in_valid};
    end
    assign out_valid = vpipe[LAT-1];
endmodule
