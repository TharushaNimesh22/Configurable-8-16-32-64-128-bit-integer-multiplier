module mult_shift_add_seq #(
    parameter WIDTH = 8
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,   // accepted when !busy
    input  wire [WIDTH-1:0]   a,       // multiplicand
    input  wire [WIDTH-1:0]   b,       // multiplier
    output reg                busy,
    output reg                done,    // 1-cycle pulse, p valid while done=1
    output wire [2*WIDTH-1:0] p
);
    localparam CW = $clog2(WIDTH + 1);

    reg [WIDTH:0]   hi;      // upper half of product (+1 bit for the carry)
    reg [WIDTH-1:0] lo;      // lower half of product / remaining multiplier bits
    reg [WIDTH-1:0] a_r;
    reg [CW-1:0]    cnt;

    wire [WIDTH:0] sum = hi + (lo[0] ? {1'b0, a_r} : {(WIDTH+1){1'b0}});

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hi <= 0; lo <= 0; a_r <= 0; cnt <= 0; busy <= 1'b0; done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                hi   <= 0;
                lo   <= b;
                a_r  <= a;
                cnt  <= 0;
                busy <= 1'b1;
            end else if (busy) begin
                // add then shift-right the whole {sum, lo} register by one
                hi  <= {1'b0, sum[WIDTH:1]};
                lo  <= {sum[0], lo[WIDTH-1:1]};
                cnt <= cnt + 1'b1;
                if (cnt == WIDTH-1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end

    assign p = {hi[WIDTH-1:0], lo};
endmodule
