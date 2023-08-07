`timescale 1ns/1ps
module tb_butterfly();
parameter DATA_WIDTH = 16;
parameter TWID_WIDTH = 16;
parameter SHIFT = 0;
logic rst_n;
logic clk;

logic signed [DATA_WIDTH - 1 : 0] xp_r;
logic signed [DATA_WIDTH - 1 : 0] xp_i;
logic signed [DATA_WIDTH - 1 : 0] xq_r;
logic signed [DATA_WIDTH - 1 : 0] xq_i;

logic signed [TWID_WIDTH - 1 : 0] wn_r;
logic signed [TWID_WIDTH - 1 : 0] wn_i;

logic signed [DATA_WIDTH - 1 : 0] yp_r;
logic signed [DATA_WIDTH - 1 : 0] yp_i;
logic signed [DATA_WIDTH - 1 : 0] yq_r;
logic signed [DATA_WIDTH - 1 : 0] yq_i;
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;
    #10 rst_n = 1;
    #1000 
    $finish;
end

initial begin
    xp_r = 10;
    xp_i = 1;
    xq_r = 20;
    xq_i = 2;
    wn_r = 1;
    wn_i = 2;

 @(negedge clk) ;
     
       forever begin
          @(negedge clk) ;
          xp_r = (xp_r > 16'hffff) ? 'b0 : xp_r + 1 ;
          xp_i = (xp_i > 16'hffff) ? 'b0 : xp_i + 2 ;
          xq_r = (xq_r > 16'hffff) ? 'b0 : xq_r + 3 ;
          xq_i = (xq_i > 16'hffff) ? 'b0 : xq_i + 4 ;
       end

end





butterfly 
#(
    .DATA_WIDTH (DATA_WIDTH ),
    .TWID_WIDTH (TWID_WIDTH ),
    .MSB_CUTOFF (DATA_WIDTH - 1 ),
    .SHIFT      (SHIFT)
)
u_butterfly(
    .clk   (clk   ),
    .rst_n (rst_n ),
    //.en    (en    ),
    .xp_r  (xp_r  ),
    .xp_i  (xp_i  ),
    .xq_r  (xq_r  ),
    .xq_i  (xq_i  ),
    .wn_r  (wn_r  ),
    .wn_i  (wn_i  ),
    .yp_r  (yp_r  ),
    .yp_i  (yp_i  ),
    .yq_r  (yq_r  ),
    .yq_i  (yq_i  )
);



endmodule