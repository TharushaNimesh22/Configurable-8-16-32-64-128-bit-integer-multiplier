module wallace_tree_pipe #(
    parameter N   = 4,
    parameter WID = 16
)(
    input  wire             clk,
    input  wire [N*WID-1:0] rows,
    output wire [WID-1:0]   s,
    output wire [WID-1:0]   c
);
    generate
        if (N == 1) begin : g_one
            assign s = rows[WID-1:0];
            assign c = {WID{1'b0}};
        end else if (N == 2) begin : g_two
            assign s = rows[WID-1:0];
            assign c = rows[2*WID-1:WID];
        end else begin : g_level
            localparam G  = N / 3;
            localparam R  = N % 3;
            localparam NN = 2*G + R;

            wire [NN*WID-1:0] nxt;
            reg  [NN*WID-1:0] nxt_r;      // pipeline register for this level

            genvar g;
            for (g = 0; g < G; g = g + 1) begin : g_csa
                csa #(.W(WID)) u_csa (
                    .x(rows[(3*g  )*WID +: WID]),
                    .y(rows[(3*g+1)*WID +: WID]),
                    .z(rows[(3*g+2)*WID +: WID]),
                    .s(nxt [(2*g  )*WID +: WID]),
                    .c(nxt [(2*g+1)*WID +: WID])
                );
            end
            if (R == 1) begin : g_pass1
                assign nxt[(2*G)*WID +: WID]   = rows[(3*G)*WID +: WID];
            end else if (R == 2) begin : g_pass2
                assign nxt[(2*G)*WID +: 2*WID] = rows[(3*G)*WID +: 2*WID];
            end

            always @(posedge clk) nxt_r <= nxt;  // Write into pipeline register for this level

            wallace_tree_pipe #(.N(NN), .WID(WID)) u_next (
                .clk(clk), .rows(nxt_r), .s(s), .c(c)
            );
        end
    endgenerate
endmodule
