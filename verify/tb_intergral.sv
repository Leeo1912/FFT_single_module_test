`timescale 1ns/1ps
module tb_intergral ();
    
    parameter IN_DATA_WIDTH = 32;
    parameter OUT_DATA_WIDTH = 52;
    //Truncate at bit MSB_CUTOFF
    parameter LSB_CUTOFF = 11;                   // rounding basing add_square_col1
    parameter MSB_CUTOFF = 51;                   // clamp(after rounding) basing temp_cut_tail_col1

    localparam FILE_NAME_x1 = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/case_8010/case_8010_9/decode_s2/rfft16384_decode_golden.txt";
    localparam GOLDEN = "D:/data_software/github_desktop/FFT_single_module_test/verify/case/case_8010/case_8010_9/decode_s2/rfft16384_power_golden.txt";

    // localparam INDEX_COL_1 = "D:/data_software/github_desktop/FFT-s900/src/recover_2n_point_FFT/index_col1.txt";
    // localparam INDEX_COL_2 = "D:/data_software/github_desktop/FFT-s900/src/recover_2n_point_FFT/index_col2.txt";

    localparam clk_period = 10;
    logic clk;
    logic rst_n;
    logic valid;
    logic ready;
    // logic [13:0] lable;

    logic [3:0][IN_DATA_WIDTH - 1:0] col1_r;
    logic [3:0][IN_DATA_WIDTH - 1:0] col1_i;
    logic [3:0][IN_DATA_WIDTH - 1:0] col2_r;
    logic [3:0][IN_DATA_WIDTH - 1:0] col2_i;

    logic [3:0][OUT_DATA_WIDTH - 1:0] col_1;
    logic [3:0][OUT_DATA_WIDTH - 1:0] col_2;

    logic [63:0] rom[8191:0];
    logic [OUT_DATA_WIDTH - 1:0] golden_rom[8191:0];
         
    logic [63:0] input_x[8191:0];

//read txt file

initial begin
    $readmemh(FILE_NAME_x1, rom); 
    for (int i = 0;i < 8192 ;i++ ) begin
        input_x[i] = rom[i];
    end
    $readmemh(GOLDEN, golden_rom); 

end

logic [10:0] index_col_1;
logic [10:0] index_col_2;

logic [10:0] out_index_col1;
logic [10:0] out_index_col2;

always #(clk_period/2) clk = ~clk;
initial begin
    clk = 0;
    rst_n = 0;
    valid =0;
    index_col_1 = 0;
    index_col_2 = 3;
    #clk_period rst_n = 1;
    valid = 1;

    index_col_1 = 0;
    for (int k = 0;k < 4;k++ ) begin
                col1_r[k] =input_x[k][63:32];
                col1_i[k] =input_x[k][31: 0];                   
            end
    #clk_period;

    index_col_1 = 1;
    for (int k = 0;k < 4;k++ ) begin
                col1_r[k] =input_x[k+4][63:32];
                col1_i[k] =input_x[k+4][31: 0];
            end
    #clk_period;

    for (int i = 2;i < 2048 ;i=i+2 ) begin
            for (int k = 0;k < 4;k++ ) begin
                col1_r[k] =input_x[i*4 + k][63:32];
                col1_i[k] =input_x[i*4 + k][31: 0];   
            end
            index_col_1 = i;
            #clk_period;
    end

    valid = 0;
    if(valid == 0)begin
        for (int i = 0;i < 4;i++ ) begin
            col1_r[i] ='b0;
            col1_i[i] ='b0;
            col2_r[i] ='b0;
            col2_i[i] ='b0;
        end
    end
    #(10000*clk_period);
end

initial begin
    #(3*clk_period);
    for (int i = 3;i < 2048 ;i=i+2 ) begin
            for (int k = 0;k < 4;k++ ) begin
                col2_r[k] =input_x[i*4 + k][63:32];
                col2_i[k] =input_x[i*4 + k][31: 0];                
            end
            index_col_2 = i;
            #clk_period;
    end
end

//compare output with golden
logic [OUT_DATA_WIDTH - 1:0] result [8191:0];

logic signed [OUT_DATA_WIDTH - 1:0] col1_s[3:0];
logic signed [OUT_DATA_WIDTH - 1:0] col2_s[3:0];


initial begin 

    for (int i = 0;i < 8192;i++ ) begin
            result[i] <= 0;
        end 
    @(posedge ready)
        #2;
        for (int i = 0;i < 4 ;i++ ) begin
                col1_s[i] = col_1[i];

            end
        #3;
        for (int i = 0;i < 4 ;i++ ) begin
            result[i] = col_1[i]; 
        end

        @(posedge clk)
        #2;
        for (int i = 0;i < 4 ;i++ ) begin
                col1_s[i] = col_1[i];

            end
        #3;
        for (int i = 0;i < 4 ;i++ ) begin
            result[i+4] = col_1[i]; 
        end

        for (int i = 8;i < 8192 ;i=i+8 ) begin
            @(posedge clk)
            #2;
            for (int i = 0;i<4 ;i++ ) begin
                col1_s[i] = col_1[i];
                col2_s[i] = col_2[i];
            end
            #3;
            for(int k=0;k<4;k++)begin
                result[i+k] = col1_s[k];
                result[i+4+k] = col2_s[k];
            end

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
        $finish;

    $display("compare end!");
    #100;
end



intergral 
#(
    .IN_DATA_WIDTH  (IN_DATA_WIDTH  ),
    .OUT_DATA_WIDTH (OUT_DATA_WIDTH ),
    .LSB_CUTOFF     (LSB_CUTOFF     ),
    .MSB_CUTOFF     (MSB_CUTOFF     )
)
u_intergral(
    .clk            (clk            ),
    .rst_n          (rst_n          ),

    .valid          (valid          ),
    .ready          (ready          ),

    .col1_r         (col1_r         ),
    .col1_i         (col1_i         ),
    .col2_r         (col2_r         ),
    .col2_i         (col2_i         ),

    .col_1          (col_1          ),
    .col_2          (col_2          ),

    .index_col_1    (index_col_1    ),
    .index_col_2    (index_col_2    ),

    .out_index_col1 (out_index_col1 ),
    .out_index_col2 (out_index_col2 )
);





    
endmodule