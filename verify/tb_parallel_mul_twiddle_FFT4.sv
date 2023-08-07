`timescale 1ns/1ps
module tb_parallel_mul_twiddle_FFT4 ();
parameter DATA_WIDTH = 21;
parameter TWID_WIDTH = 16;
parameter MSB_CUTOFF = 26;   // [DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF : 0] temp_cut_tail_r[3:0];
parameter LSB_CUTOFF = 12;   // [DATA_WIDTH + TWID_WIDTH +1 : 0] temp_add_r_res[3:0];
parameter SHIFT = 15;

localparam FILE_NAME = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/testcase8003/dit4/serial2048_golden64.txt";
localparam GOLDEN = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/testcase8003/dit4/cfft8192_golden64.txt";

localparam clk_period = 10;
logic clk;
logic rst_n;
logic valid;
logic ready;
logic [10:0] lable;
logic [10:0] index;

logic signed [DATA_WIDTH-1:0] x0_r;
logic signed [DATA_WIDTH-1:0] x0_i;
logic signed [DATA_WIDTH-1:0] x1_r;
logic signed [DATA_WIDTH-1:0] x1_i;
logic signed [DATA_WIDTH-1:0] x2_r;
logic signed [DATA_WIDTH-1:0] x2_i;
logic signed [DATA_WIDTH-1:0] x3_r;
logic signed [DATA_WIDTH-1:0] x3_i;

logic signed [26:0] y0_r;
logic signed [26:0] y0_i;
logic signed [26:0] y1_r;
logic signed [26:0] y1_i;
logic signed [26:0] y2_r;
logic signed [26:0] y2_i;
logic signed [26:0] y3_r;
logic signed [26:0] y3_i;

logic [63:0] rom[8191:0];
logic [63:0] golden_rom[8191:0];
logic [63:0] input_FFT4[8191:0];

always #(clk_period/2) clk = ~clk;
initial begin
    clk = 0;
    rst_n = 0;
    valid =0;
    #clk_period rst_n = 1;

    for (int i = 0;i < 2048 ;i++ ) begin
        x0_r = input_FFT4[i*4+0][63:32];
        x0_i = input_FFT4[i*4+0][31: 0];
        x1_r = input_FFT4[i*4+1][63:32];
        x1_i = input_FFT4[i*4+1][31: 0];
        x2_r = input_FFT4[i*4+2][63:32];
        x2_i = input_FFT4[i*4+2][31: 0];
        x3_r = input_FFT4[i*4+3][63:32];
        x3_i = input_FFT4[i*4+3][31: 0];
        lable = 10'd0 + i;

        valid =1;
        #clk_period;
    end
    
    valid = 0;
    if(valid == 0)begin
        x0_r = 0;
        x0_i = 0;
        x1_r = 0;
        x1_i = 0;
        x2_r = 0;
        x2_i = 0;
        x3_r = 0;
        x3_i = 0;

    end
    #(100*clk_period);
end



//read txt file
initial begin
    $readmemh(FILE_NAME, rom); 
    for (int i = 0;i < 8192 ;i++ ) begin
        input_FFT4[i] = rom[i];
    end
end

//read golden
initial begin
    $readmemh(GOLDEN, golden_rom); 
end

//compare output with golden
logic [63:0] result [8191:0];

logic signed [31:0] y_r_s[3:0];
logic signed [31:0] y_i_s[3:0];

initial begin 

    for (int i = 0;i < 8192;i++ ) begin
            result[i] <= 0;
        end 

    #50;

        for (int i = 0;i < 8192 ;i=i+4 ) begin
            @(posedge clk)
            #2;
            y_r_s[0] = y0_r;
            y_i_s[0] = y0_i;
            y_r_s[1] = y1_r;
            y_i_s[1] = y1_i;
            y_r_s[2] = y2_r;
            y_i_s[2] = y2_i;
            y_r_s[3] = y3_r;
            y_i_s[3] = y3_i;
            #3;
            result[i + 0] = {y_r_s[0],y_i_s[0]};
            result[i + 1] = {y_r_s[1],y_i_s[1]};
            result[i + 2] = {y_r_s[2],y_i_s[2]};
            result[i + 3] = {y_r_s[3],y_i_s[3]};


        end   
    
end

int cnt_err;
initial begin
    @(posedge ready)
    $display("start to output");
    cnt_err = 0;
    @(negedge ready)
    $display("start to compare");
    for (int i = 0;i < 8192 ;i=i+1 ) begin
            if(result[i] != golden_rom[i])begin
                $display("addr %d x1 != golden data: %h %h", i, result[i], golden_rom[i]);
                cnt_err = cnt_err + 1;
            // $display("****** '%d'_right! ******",i);
            end
    end
    if(cnt_err == 0) begin
            $display("****** output_right! ******");
        end else begin
            $display("****** output_wrong! ******");
            $display("err_0 is %d", cnt_err);                    
        end
        $display("simulation finish!");
        #(100*clk_period);
        $finish;

    $display("compare end!");
end




parallel_mul_twiddle_FFT4 
#(
    .DATA_WIDTH (DATA_WIDTH ),
    .TWID_WIDTH (TWID_WIDTH ),
    .MSB_CUTOFF (MSB_CUTOFF ),
    .LSB_CUTOFF (LSB_CUTOFF ),
    .SHIFT      (SHIFT      )
)
u_parallel_mul_twiddle_FFT4(
    .clk   (clk   ),
    .rst_n (rst_n ),

    .lable (lable ),
    .x0_r  (x0_r  ),
    .x0_i  (x0_i  ),
    .x1_r  (x1_r  ),
    .x1_i  (x1_i  ),
    .x2_r  (x2_r  ),
    .x2_i  (x2_i  ),
    .x3_r  (x3_r  ),
    .x3_i  (x3_i  ),
    .y0_r  (y0_r  ),
    .y0_i  (y0_i  ),
    .y1_r  (y1_r  ),
    .y1_i  (y1_i  ),
    .y2_r  (y2_r  ),
    .y2_i  (y2_i  ),
    .y3_r  (y3_r  ),
    .y3_i  (y3_i  ),
    .index (index),

    .valid(valid),
    .ready(ready)
);

//test
// logic [31:0]y0_r_test = 32'h00000000;
// logic [31:0]y1_r_test = 32'hfffc0000;
// logic [31:0]y2_r_test = 32'h00000000;
// logic [31:0]y3_r_test = 32'h00040000;

// logic [31:0]y0_i_test = 32'h7ffbffff;
// logic [31:0]y1_i_test = 32'hfffc0000;
// logic [31:0]y2_i_test = 32'hfffc0000;
// logic [31:0]y3_i_test = 32'hfffc0000;

endmodule