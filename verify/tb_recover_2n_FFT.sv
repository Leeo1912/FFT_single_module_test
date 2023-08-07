`timescale 1ns/1ps
module tb_recover_2n_FFT ();
    
parameter DATA_WIDTH = 27;
parameter TWID_WIDTH = 16;
parameter LSB_CUTOFF = 12;   // [DATA_WIDTH + TWID_WIDTH +1 : 0] temp_add_r_res[3:0];
parameter SHIFT = 15;

    localparam FILE_NAME_x1 = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/case_8004_0/decode_s2/cfft8192_decode_x1_golden.txt";
    localparam FILE_NAME_x2 = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/case_8004_0/decode_s2/cfft8192_decode_x2_golden.txt";
    localparam DECODE_GOLDEN = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/case_8004_0/decode_s2/rfft16384_decode_golden.txt";

    localparam INDEX_COL1 = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/case_8004_0/decode_s2/index_col1.txt";
    localparam INDEX_COL2 = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/case_8004_0/decode_s2/index_col2.txt";
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

    logic [10:0] output_index_col1;
    logic [10:0] output_index_col2;

    logic [63:0] rom_1[8191:0];
    logic [63:0] rom_2[8191:0]; 
    logic [63:0] golden_rom[8191:0];
    logic [10:0] rom_index_col1[1024:0]; 
    logic [10:0] rom_index_col2[1024:0];   
         
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
    $readmemh(DECODE_GOLDEN, golden_rom); 

    $readmemh(INDEX_COL1, rom_index_col1); 
    $readmemh(INDEX_COL2, rom_index_col2); 

    // $readmemh(INDEX_COL_1, rom_index_col_1); 
    // for (int i = 0;i < 1025 ;i++ ) begin
    //     index_1[i] = rom_index_col_1[i];
    // end
    // $readmemh(INDEX_COL_2, rom_index_col_2); 
    // for (int i = 0;i < 1025 ;i++ ) begin
    //     index_2[i] = rom_index_col_2[i];
    // end

end

  //bit reverse
logic [10:0] reverse_1;
logic [10:0] reverse_2;
always_comb begin 
    if (!rst_n) begin
        reverse_1 = 0;
        reverse_2 = 0;
    end else begin
        reverse_1 = {index_col_1[0],index_col_1[1],index_col_1[2],index_col_1[3],index_col_1[4],index_col_1[5],index_col_1[6],index_col_1[7],index_col_1[8],index_col_1[9],index_col_1[10]};
        reverse_2 = {index_col_2[0],index_col_2[1],index_col_2[2],index_col_2[3],index_col_2[4],index_col_2[5],index_col_2[6],index_col_2[7],index_col_2[8],index_col_2[9],index_col_2[10]};
    end
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
            index_col_1 = rom_index_col1[i];
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
            index_col_1 = rom_index_col1[i];
            index_col_2 = rom_index_col2[i];
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
end

//compare output with golden
logic [63:0]result[8191:0];

initial begin 

    for (int i = 0;i < 8192;i++ ) begin
            result[i] <= 0;
        end 

    @(posedge ready);
    #5;
        result[0] = {dataout_col1_r[0],dataout_col1_i[0]};
        result[1] = {dataout_col1_r[1],dataout_col1_i[1]};
        result[2] = {dataout_col1_r[2],dataout_col1_i[2]};
        result[3] = {dataout_col1_r[3],dataout_col1_i[3]};

    @(posedge clk);
    #5;
        result[4] = {dataout_col1_r[0],dataout_col1_i[0]};
        result[5] = {dataout_col1_r[1],dataout_col1_i[1]};
        result[6] = {dataout_col1_r[2],dataout_col1_i[2]};
        result[7] = {dataout_col1_r[3],dataout_col1_i[3]};

    for (int i = 8;i < 8192 ;i=i+8 ) begin
        @(posedge clk)
        #5;
            result[i+0] = {dataout_col1_r[0],dataout_col1_i[0]};
            result[i+1] = {dataout_col1_r[1],dataout_col1_i[1]};
            result[i+2] = {dataout_col1_r[2],dataout_col1_i[2]};
            result[i+3] = {dataout_col1_r[3],dataout_col1_i[3]};
            result[i+4] = {dataout_col2_r[0],dataout_col2_i[0]};
            result[i+5] = {dataout_col2_r[1],dataout_col2_i[1]};
            result[i+6] = {dataout_col2_r[2],dataout_col2_i[2]};
            result[i+7] = {dataout_col2_r[3],dataout_col2_i[3]};
        
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
    .index_col_1    (reverse_1      ),

    .x1_col2_r      (x1_col2_r      ),
    .x1_col2_i      (x1_col2_i      ),
    .x2_col2_r      (x2_col2_r      ),
    .x2_col2_i      (x2_col2_i      ),
    .index_col_2    (reverse_2      ),

    .dataout_col1_r (dataout_col1_r ),
    .dataout_col1_i (dataout_col1_i ),
    .output_index_col1 (output_index_col1 ),

    .dataout_col2_r (dataout_col2_r ),
    .dataout_col2_i (dataout_col2_i ),
    .output_index_col2 (output_index_col2 )

);

    
endmodule