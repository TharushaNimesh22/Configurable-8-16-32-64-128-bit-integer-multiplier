module int_mult_top #(
    parameter WIDTH = 32,
    parameter ARCH  = 3,
    parameter BASE  = 16
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               in_valid,
    output wire               in_ready,
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output wire               out_valid,
    output wire [2*WIDTH-1:0] p
);
    generate
        // sequential cores
        if (ARCH == 0 || ARCH == 1) begin : g_seq
            wire busy, done;
            if (ARCH == 0) begin : g_sa              // Sequential shift and add (radix-2)
                mult_shift_add_seq #(.WIDTH(WIDTH)) u_core (
                    .clk(clk), .rst_n(rst_n), .start(in_valid),
                    .a(a), .b(b), .busy(busy), .done(done), .p(p));
            end else begin : g_bs                   // Sequential radix-4 Booth
                mult_booth_r4_seq #(.WIDTH(WIDTH)) u_core (
                    .clk(clk), .rst_n(rst_n), .start(in_valid),
                    .a(a), .b(b), .busy(busy), .done(done), .p(p));
            end
            assign in_ready  = ~busy;
            assign out_valid = done;

        // pipelined core
        end else if (ARCH == 4) begin : g_pipe    // Pipelined radix-4 Booth + Wallace tree
            wire [2*WIDTH-1:0] p_w;
            mult_booth_wallace_pipe #(.WIDTH(WIDTH)) u_core (
                .clk(clk), .rst_n(rst_n), .in_valid(in_valid),
                .a(a), .b(b), .out_valid(out_valid), .p(p_w));
            assign p        = p_w;
            assign in_ready = 1'b1;

        // combinational cores
        end else begin : g_comb
            reg  [WIDTH-1:0]   a_r, b_r;
            reg  [2*WIDTH-1:0] p_r;
            reg                v1, v2;
            wire [2*WIDTH-1:0] p_c;

            if (ARCH == 2) begin : g_arr           // Carry-save array multiplier
                mult_array_csa     #(.WIDTH(WIDTH))              u_core (.a(a_r), .b(b_r), .p(p_c));
            end else if (ARCH == 3) begin : g_bw  // Radix-4 Booth + Wallace tree
                mult_booth_wallace #(.WIDTH(WIDTH))              u_core (.a(a_r), .b(b_r), .p(p_c));
            end else begin : g_kara      // Karatsuba
                mult_karatsuba     #(.WIDTH(WIDTH), .BASE(BASE)) u_core (.a(a_r), .b(b_r), .p(p_c));
            end

            always @(posedge clk) begin
                a_r <= a;
                b_r <= b;
                p_r <= p_c;
            end
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin v1 <= 1'b0; v2 <= 1'b0; end
                else        begin v1 <= in_valid; v2 <= v1; end
            end

            assign p         = p_r;
            assign out_valid = v2;
            assign in_ready  = 1'b1;
        end
    endgenerate
endmodule
