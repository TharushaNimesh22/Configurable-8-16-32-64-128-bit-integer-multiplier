module wallace_tree #(
    parameter N   = 4,     // number of input rows
    parameter WID = 16     // width of each row
)(
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
            localparam G  = N / 3;          // number of complete groups containing three rows
            localparam R  = N % 3;          // number of remaining rows
            localparam NN = 2*G + R;        // number of rows after compression

            wire [NN*WID-1:0] nxt;

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

            // Handle the remaining rows by passing them through to the next level
            if (R == 1) begin : g_pass1
                assign nxt[(2*G)*WID +: WID]   = rows[(3*G)*WID +: WID];
            end else if (R == 2) begin : g_pass2
                assign nxt[(2*G)*WID +: 2*WID] = rows[(3*G)*WID +: 2*WID];
            end

            wallace_tree #(.N(NN), .WID(WID)) u_next (
                .rows(nxt), .s(s), .c(c)
            );
        end
    endgenerate
endmodule
