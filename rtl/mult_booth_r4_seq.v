
module mult_booth_r4_seq #(
    parameter WIDTH = 8
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output reg                busy,
    output reg                done,
    output wire [2*WIDTH-1:0] p
);
    localparam ND = WIDTH/2 + 1;          // number of Booth digits
    localparam M  = 2*ND;                 // zero-extended multiplier register width
    localparam HW = WIDTH + 4;            // signed accumulator (with headroom)
    localparam CW = $clog2(ND + 1);       // counter width

    reg [HW-1:0]    hi;   // signed running sum (two's complement)
    reg [M-1:0]     lo;   // multiplier bits / low product bits
    reg             q;    // the overlapping bit b[i-1] (starts as 0)
    reg [WIDTH-1:0] a_r;
    reg [CW-1:0]    cnt;  // Iteration counter

    // Booth encoder: 3 bits -> {one, two, neg} 
    //   b(i+1) b(i) b(i-1) | digit
    //      0     0    0    |  0
    //      0     0    1    | +1
    //      0     1    0    | +1
    //      0     1    1    | +2
    //      1     0    0    | -2
    //      1     0    1    | -1
    //      1     1    0    | -1
    //      1     1    1    |  0
    wire [2:0] t   = {lo[1], lo[0], q};
    wire       one = t[1] ^ t[0];
    wire       two = (t[2] ^ t[1]) & ~(t[1] ^ t[0]);
    wire       neg = t[2];

    wire [HW-1:0] ax  = {{(HW-WIDTH){1'b0}}, a_r};
    wire [HW-1:0] mag = one ? ax : (two ? (ax << 1) : {HW{1'b0}});
    // negative digit: add (~mag + 1)  -> invert and use the adder's carry-in
    // two's complement negation when neg = 1, normally add mag, when neg = 0
    wire [HW-1:0] sum = hi + (mag ^ {HW{neg}}) + neg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hi <= 0; lo <= 0; q <= 1'b0; a_r <= 0; cnt <= 0;
            busy <= 1'b0; done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                hi   <= 0;
                lo   <= {{(M-WIDTH){1'b0}}, b};
                q    <= 1'b0;
                a_r  <= a;
                cnt  <= 0;
                busy <= 1'b1;
            end else if (busy) begin
                // arithmetic shift right by 2 of {sum, lo}
                hi  <= {{2{sum[HW-1]}}, sum[HW-1:2]};
                lo  <= {sum[1:0], lo[M-1:2]};
                q   <= lo[1];
                cnt <= cnt + 1'b1;
                if (cnt == ND-1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end

    wire [HW+M-1:0] full = {hi, lo};
    assign p = full[2*WIDTH-1:0]; // Take the lower 2*WIDTH bits of the full product (hi + lo)
endmodule
