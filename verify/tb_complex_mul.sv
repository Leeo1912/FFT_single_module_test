module tb_complex_mul();
parameter DATA_WIDTH = 32;
parameter TWID_WIDTH = 32;
parameter MSB_CUTOFF = 31;
parameter SHIFT = 31;
logic rst_n;
logic clk;

logic signed [DATA_WIDTH - 1 : 0] a0_r = 32'h0000000e;
logic signed [DATA_WIDTH - 1 : 0] a0_i = 32'h00000000;

logic signed [DATA_WIDTH - 1 : 0] a1_r = 32'h00000007;
logic signed [DATA_WIDTH - 1 : 0] a1_i = 32'hfffffff8;
logic signed [DATA_WIDTH - 1 : 0] b1_r = 32'h001921fb;
logic signed [DATA_WIDTH - 1 : 0] b1_i = 32'h80000278;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] c1_r;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] c1_i;

logic signed [DATA_WIDTH + TWID_WIDTH : 0] a0_r_expand = a0_r;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] a0_i_expand = a0_i;


logic signed [DATA_WIDTH + TWID_WIDTH + 1 : 0] X0_r;
logic signed [DATA_WIDTH + TWID_WIDTH + 1 : 0] X0_i;
logic signed [DATA_WIDTH + TWID_WIDTH + 1 : 0] X0_i_test1;
logic signed [DATA_WIDTH + TWID_WIDTH + 1 : 0] X0_i_test2;




always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;
    #10 rst_n = 1;
    #1000 
    $finish;
end

complex_mul 
#(
    .DATA_WIDTH (DATA_WIDTH ),
    .TWID_WIDTH (TWID_WIDTH ),
    .MSB_CUTOFF (MSB_CUTOFF ),
    .SHIFT      (SHIFT      )
)
u_complex_mul_1(
    .clk   (clk   ),
    .rst_n (rst_n ),
    .a_r   (a1_r   ),
    .a_i   (a1_i   ),
    .b_r   (b1_r   ),
    .b_i   (b1_i   ),
    .c_r   (c1_r   ),
    .c_i   (c1_i   )
);

logic signed [DATA_WIDTH - 1 : 0] a2_r = 32'h00000008;
logic signed [DATA_WIDTH - 1 : 0] a2_i = 32'hfffffff4;
logic signed [DATA_WIDTH - 1 : 0] b2_r = 32'h800009df;
logic signed [DATA_WIDTH - 1 : 0] b2_i = 32'hffcdbc0b;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] c2_r;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] c2_i;

complex_mul 
#(
    .DATA_WIDTH (DATA_WIDTH ),
    .TWID_WIDTH (TWID_WIDTH ),
    .MSB_CUTOFF (MSB_CUTOFF ),
    .SHIFT      (SHIFT      )
)
u_complex_mul_2(
    .clk   (clk   ),
    .rst_n (rst_n ),
    .a_r   (a2_r   ),
    .a_i   (a2_i   ),
    .b_r   (b2_r   ),
    .b_i   (b2_i   ),
    .c_r   (c2_r   ),
    .c_i   (c2_i   )
);

logic signed [DATA_WIDTH - 1 : 0] a3_r = 32'h00000014;
logic signed [DATA_WIDTH - 1 : 0] a3_i = 32'h00000014;
logic signed [DATA_WIDTH - 1 : 0] b3_r = 32'hffb49a12;
logic signed [DATA_WIDTH - 1 : 0] b3_i = 32'h7fffe9cb;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] c3_r;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] c3_i;

complex_mul 
#(
    .DATA_WIDTH (DATA_WIDTH ),
    .TWID_WIDTH (TWID_WIDTH ),
    .MSB_CUTOFF (MSB_CUTOFF ),
    .SHIFT      (SHIFT      )
)
u_complex_mul_3(
    .clk   (clk   ),
    .rst_n (rst_n ),
    .a_r   (a3_r   ),
    .a_i   (a3_i   ),
    .b_r   (b3_r   ),
    .b_i   (b3_i   ),
    .c_r   (c3_r   ),
    .c_i   (c3_i   )
);

always_comb begin 
    
    X0_r <= (a0_r_expand<<1) + c1_r + c2_r + c3_r;
    X0_i <=  c1_i;
    X0_i_test1 <= c2_i;
    X0_i_test2 <= c3_i;


end

endmodule