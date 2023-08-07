`timescale 1ns/1ps
module tb_recover_2n_FFT ();
    
parameter DATA_WIDTH = 27;
parameter TWID_WIDTH = 16;
parameter LSB_CUTOFF = 12;   // [DATA_WIDTH + TWID_WIDTH +1 : 0] temp_add_r_res[3:0];
parameter SHIFT = 15;

    localparam FILE_NAME_x1 = "D:/data_software/github_desktop/FFT-s900/src/recover_2n_point_FFT/case_8004_0/decode_s2/cfft8192_decode_x1_golden.txt";
    localparam FILE_NAME_x2 = "D:/data_software/github_desktop/FFT-s900/src/recover_2n_point_FFT/case_8004_0/decode_s2/cfft8192_decode_x2_golden.txt";
    localparam DECODE_GOLDEN = "D:/data_software/github_desktop/FFT-s900/src/recover_2n_point_FFT/case_8004_0/decode_s2/rfft16384_decode_golden.txt";

    // localparam INDEX_COL_1 = "D:/data_software/github_desktop/FFT-s900/src/recover_2n_point_FFT/index_col1.txt";
    // localparam INDEX_COL_2 = "D:/data_software/github_desktop/FFT-s900/src/recover_2n_point_FFT/index_col2.txt";

    localparam clk_period = 10;
    logic clk;
    logic rst_n;
    logic valid;
    logic ready;
    // logic [13:0] lable;

    logic [3:0][DATA_WIDTH - 1:0] x1_col1_r;
    logic [3:0][DATA_WIDTH - 1:0] x1_col1_i;
    logic [3:0][DATA_WIDTH - 1:0] x2_col1_r;
    logic [3:0][DATA_WIDTH - 1:0] x2_col1_i;
    logic [10:0]index_col_1;
    logic [3:0][DATA_WIDTH - 1:0] x1_col2_r;
    logic [3:0][DATA_WIDTH - 1:0] x1_col2_i;
    logic [3:0][DATA_WIDTH - 1:0] x2_col2_r;
    logic [3:0][DATA_WIDTH - 1:0] x2_col2_i;
    logic [10:0]index_col_2;

    logic [63:0] rom_1[8191:0];
    logic [63:0] rom_2[8191:0]; 
    logic [63:0] rom_3[8191:0];  
         
    logic [63:0] input_x1[8191:0];
    logic [63:0] input_x2[8191:0];

    logic [3:0][31:0] dataout_col1_r;
    logic [3:0][31:0] dataout_col1_i;
    logic [3:0][31:0] dataout_col2_r;
    logic [3:0][31:0] dataout_col2_i;

    // logic [31:0] rom_index_col_1[1024:0];
    // logic [31:0] rom_index_col_2[1024:0];
    // int  index_1[1024:0];
    // int  index_2[1024:0];

//read txt file

initial begin
    $readmemh(FILE_NAME_x1, rom_1); 
    for (int i = 0;i < 8192 ;i++ ) begin
        input_x1[i] = rom_1[i];
    end
    $readmemh(FILE_NAME_x2, rom_2); 
    for (int i = 0;i < 8192 ;i++ ) begin
        input_x2[i] = rom_2[i];
    end
    $readmemh(DECODE_GOLDEN, rom_3); 
    

    // $readmemh(INDEX_COL_1, rom_index_col_1); 
    // for (int i = 0;i < 1025 ;i++ ) begin
    //     index_1[i] = rom_index_col_1[i];
    // end
    // $readmemh(INDEX_COL_2, rom_index_col_2); 
    // for (int i = 0;i < 1025 ;i++ ) begin
    //     index_2[i] = rom_index_col_2[i];
    // end

end


always #(clk_period/2) clk = ~clk;
initial begin
    clk = 0;
    rst_n = 0;
    valid =0;
    #clk_period rst_n = 1;

    for (int i = 0;i < 1025 ;i++ ) begin
        if (i==0 || i==1) begin
            x1_col1_r[0] = input_x1[i*4+0][63:32];
            x1_col1_i[0] = input_x1[i*4+0][31: 0];
            x1_col1_r[1] = input_x1[i*4+1][63:32];
            x1_col1_i[1] = input_x1[i*4+1][31: 0];
            x1_col1_r[2] = input_x1[i*4+2][63:32];
            x1_col1_i[2] = input_x1[i*4+2][31: 0];
            x1_col1_r[3] = input_x1[i*4+3][63:32];
            x1_col1_i[3] = input_x1[i*4+3][31: 0];

            x2_col1_r[0] = input_x2[i*4+0][63:32];
            x2_col1_i[0] = input_x2[i*4+0][31: 0];
            x2_col1_r[1] = input_x2[i*4+1][63:32];
            x2_col1_i[1] = input_x2[i*4+1][31: 0];
            x2_col1_r[2] = input_x2[i*4+2][63:32];
            x2_col1_i[2] = input_x2[i*4+2][31: 0];
            x2_col1_r[3] = input_x2[i*4+3][63:32];
            x2_col1_i[3] = input_x2[i*4+3][31: 0];
            index_col_1 = i;
            //index_col_2 = i;
            valid =1;
            #clk_period;
        end else begin

            x1_col1_r[0] = input_x1[(i-1)*8+0][63:32];
            x1_col1_i[0] = input_x1[(i-1)*8+0][31: 0];
            x1_col1_r[1] = input_x1[(i-1)*8+1][63:32];
            x1_col1_i[1] = input_x1[(i-1)*8+1][31: 0];
            x1_col1_r[2] = input_x1[(i-1)*8+2][63:32];
            x1_col1_i[2] = input_x1[(i-1)*8+2][31: 0];
            x1_col1_r[3] = input_x1[(i-1)*8+3][63:32];
            x1_col1_i[3] = input_x1[(i-1)*8+3][31: 0];

            x2_col1_r[0] = input_x2[(i-1)*8+0][63:32];
            x2_col1_i[0] = input_x2[(i-1)*8+0][31: 0];
            x2_col1_r[1] = input_x2[(i-1)*8+1][63:32];
            x2_col1_i[1] = input_x2[(i-1)*8+1][31: 0];
            x2_col1_r[2] = input_x2[(i-1)*8+2][63:32];
            x2_col1_i[2] = input_x2[(i-1)*8+2][31: 0];
            x2_col1_r[3] = input_x2[(i-1)*8+3][63:32];
            x2_col1_i[3] = input_x2[(i-1)*8+3][31: 0];

            x1_col2_r[0] = input_x1[(i-1)*8+4][63:32];
            x1_col2_i[0] = input_x1[(i-1)*8+4][31: 0];
            x1_col2_r[1] = input_x1[(i-1)*8+5][63:32];
            x1_col2_i[1] = input_x1[(i-1)*8+5][31: 0];
            x1_col2_r[2] = input_x1[(i-1)*8+6][63:32];
            x1_col2_i[2] = input_x1[(i-1)*8+6][31: 0];
            x1_col2_r[3] = input_x1[(i-1)*8+7][63:32];
            x1_col2_i[3] = input_x1[(i-1)*8+7][31: 0];

            x2_col2_r[0] = input_x2[(i-1)*8+4][63:32];
            x2_col2_i[0] = input_x2[(i-1)*8+4][31: 0];
            x2_col2_r[1] = input_x2[(i-1)*8+5][63:32];
            x2_col2_i[1] = input_x2[(i-1)*8+5][31: 0];
            x2_col2_r[2] = input_x2[(i-1)*8+6][63:32];
            x2_col2_i[2] = input_x2[(i-1)*8+6][31: 0];
            x2_col2_r[3] = input_x2[(i-1)*8+7][63:32];
            x2_col2_i[3] = input_x2[(i-1)*8+7][31: 0];
            index_col_1 = (i-1)*2;
            index_col_2 = (i-1)*2+1;
            valid =1;
            #clk_period;
        end
    end

    valid = 0;
    if(valid == 0)begin
        for (int i = 0;i < 4;i++ ) begin
            x1_col1_r[i] ='b0;
            x1_col1_i[i] ='b0;
            x2_col1_r[i] ='b0;
            x2_col1_i[i] ='b0;
            x1_col2_r[i] ='b0;
            x1_col2_i[i] ='b0;
            x2_col2_r[i] ='b0;
            x2_col2_i[i] ='b0;
        end
    end
    #(10000*clk_period)
    $finish;
end

//compare output with golden
// logic [63:0]result[8191:0];

// initial begin 

//     for (int i = 0;i < 8192;i++ ) begin
//             result[i] <= 0;
//         end 

//     #80;

//         for (int i = 0;i < 8192 ;i=i+8 ) begin
//             @(posedge clk)
//             #5;
//                 result[i+0] = {dataout_0_r,dataout_0_i,dataout_1_r,dataout_1_i};
//                 result[i+1] = {dataout_2_r,dataout_2_i,dataout_3_r,dataout_3_i};
//                 result[i+2] = {dataout_4_r,dataout_4_i,dataout_5_r,dataout_5_i};
//                 result[i+3] = {dataout_6_r,dataout_6_i,dataout_7_r,dataout_7_i};
//                 result[i+4] = {dataout_8_r,dataout_8_i,dataout_9_r,dataout_9_i};
//                 result[i+5] = {dataout_10_r,dataout_10_i,dataout_11_r,dataout_11_i};
//                 result[i+6] = {dataout_12_r,dataout_12_i,dataout_13_r,dataout_13_i};
//                 result[i+7] = {dataout_14_r,dataout_14_i,dataout_15_r,dataout_15_i};
            
//         end

    
    
// end


// initial begin
//     @(posedge ready)
//     $display("start to output");
//     @(negedge ready)
//     $display("start to compare");
//     for (int i = 0;i < 8192 ;i=i+1 ) begin
//             if(result[i] == rom_3[i])
//             $display("****** '%d'_right! ******",i);
//              else
//             $display("****** '%d'_wrong! ******",i);
//     end
// end


recover_2n_FFT 
#(
    .DATA_WIDTH (DATA_WIDTH ),
    .TWID_WIDTH (TWID_WIDTH ),
    .LSB_CUTOFF (LSB_CUTOFF ),
    .SHIFT      (SHIFT      )
)
u_recover_2n_FFT(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .valid          (valid          ),
    .ready          (ready          ),

    .x1_col1_r      (x1_col1_r      ),
    .x1_col1_i      (x1_col1_i      ),
    .x2_col1_r      (x2_col1_r      ),
    .x2_col1_i      (x2_col1_i      ),
    .index_col_1    (index_col_1    ),

    .x1_col2_r      (x1_col2_r      ),
    .x1_col2_i      (x1_col2_i      ),
    .x2_col2_r      (x2_col2_r      ),
    .x2_col2_i      (x2_col2_i      ),
    .index_col_2    (index_col_2    ),

    .dataout_col1_r (dataout_col1_r ),
    .dataout_col1_i (dataout_col1_i ),
    .dataout_col2_r (dataout_col2_r ),
    .dataout_col2_i (dataout_col2_i )
);


    
endmodule