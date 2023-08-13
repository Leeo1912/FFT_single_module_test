module recover_2n_FFT #(
    parameter DATA_WIDTH = 27,
    parameter TWID_WIDTH = 16,
    //Truncate at bit MSB_CUTOFF
    parameter LSB_CUTOFF = 12,                   // [DATA_WIDTH + TWID_WIDTH +1 : 0] temp_dataout_r[15:0];
    //parameter MSB_CUTOFF = 31,                   // [DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF : 0] temp_cut_tail_r[3:0];
    parameter SHIFT = 15
) (
    input logic clk,
    input logic rst_n,

    input logic valid,
    output logic ready,
    
    input logic [3:0][DATA_WIDTH - 1:0] x1_col1_r,
    input logic [3:0][DATA_WIDTH - 1:0] x1_col1_i,
    input logic [3:0][DATA_WIDTH - 1:0] x2_col1_r,
    input logic [3:0][DATA_WIDTH - 1:0] x2_col1_i,
    input logic [10:0] index_col_1,

    input logic [3:0][DATA_WIDTH - 1:0] x1_col2_r,
    input logic [3:0][DATA_WIDTH - 1:0] x1_col2_i,
    input logic [3:0][DATA_WIDTH - 1:0] x2_col2_r,
    input logic [3:0][DATA_WIDTH - 1:0] x2_col2_i,
    input logic [10:0] index_col_2,

    output logic [3:0][31:0] dataout_col1_r,
    output logic [3:0][31:0] dataout_col1_i,
    output logic [3:0][31:0] dataout_col2_r,
    output logic [3:0][31:0] dataout_col2_i,

    output logic [10:0] output_index_col1,
    output logic [10:0] output_index_col2

);

// logic signed [DATA_WIDTH - 1 : 0] temp_x1_r_beat[7:0];
// logic signed [DATA_WIDTH - 1 : 0] temp_x1_i_beat[7:0];
// logic signed [DATA_WIDTH - 1 : 0] temp_x2_r_beat[7:0];
// logic signed [DATA_WIDTH - 1 : 0] temp_x2_i_beat[7:0];

logic signed [DATA_WIDTH - 1 : 0] temp_x1_r[7:0];
logic signed [DATA_WIDTH - 1 : 0] temp_x1_i[7:0];
logic signed [DATA_WIDTH - 1 : 0] temp_x2_r[7:0];
logic signed [DATA_WIDTH - 1 : 0] temp_x2_i[7:0];


logic signed [TWID_WIDTH - 1 : 0] temp_wn_r[7:0];
logic signed [TWID_WIDTH - 1 : 0] temp_wn_i[7:0];

logic signed [DATA_WIDTH + TWID_WIDTH : 0] temp_dataout_r[15:0];
logic signed [DATA_WIDTH + TWID_WIDTH : 0] temp_dataout_i[15:0];

logic [63:0] twiddle_col1[3:0];
logic [63:0] twiddle_col2[3:0];


//Get the twiddle factor from rom
  //bit reverse
logic [10:0] reverse_1;
logic [10:0] reverse_2;
always_comb begin 
    reverse_1 = {index_col_1[0],index_col_1[1],index_col_1[2],index_col_1[3],index_col_1[4],index_col_1[5],index_col_1[6],index_col_1[7],index_col_1[8],index_col_1[9],index_col_1[10]};
    reverse_2 = {index_col_2[0],index_col_2[1],index_col_2[2],index_col_2[3],index_col_2[4],index_col_2[5],index_col_2[6],index_col_2[7],index_col_2[8],index_col_2[9],index_col_2[10]};
end

logic [10:0] reverse_1_reg;
logic [10:0] reverse_2_reg;
logic valid_reg;

always_ff @( posedge clk,negedge rst_n ) begin
    if (!rst_n) begin
        reverse_1_reg <= 0;
        reverse_2_reg <= 0;
        valid_reg <= 0;
    end else begin
        reverse_1_reg <= reverse_1;
        reverse_2_reg <= reverse_2;
        valid_reg <= valid;
    end
end

rom_read_4_twiddle u_rom_read_4_twiddle(
    .clk         (clk             ),
    .rst_n       (rst_n           ),
    .valid       (valid_reg       ),
    .addr_col1   (reverse_1_reg   ),
    .addr_col2   (reverse_2_reg   ),
    .data_o_col1 (twiddle_col1    ),
    .data_o_col2 (twiddle_col2    )
);

//Take two beats of the input data, synchronized with the twiddle factor
logic [3:0][DATA_WIDTH - 1:0] x1_col1_r_temp;
logic [3:0][DATA_WIDTH - 1:0] x1_col1_i_temp;
logic [3:0][DATA_WIDTH - 1:0] x2_col1_r_temp;
logic [3:0][DATA_WIDTH - 1:0] x2_col1_i_temp;
logic [3:0][DATA_WIDTH - 1:0] x1_col2_r_temp;
logic [3:0][DATA_WIDTH - 1:0] x1_col2_i_temp;
logic [3:0][DATA_WIDTH - 1:0] x2_col2_r_temp;
logic [3:0][DATA_WIDTH - 1:0] x2_col2_i_temp;

always_ff @( posedge clk , negedge rst_n ) begin 
    if(!rst_n)begin
        for (int i = 0;i < 4 ;i++ ) begin
            x1_col1_r_temp[i] <= 'b0;
            x1_col1_i_temp[i] <= 'b0;
            x2_col1_r_temp[i] <= 'b0;
            x2_col1_i_temp[i] <= 'b0;

            x1_col2_r_temp[i] <= 'b0;
            x1_col2_i_temp[i] <= 'b0;
            x2_col2_r_temp[i] <= 'b0;
            x2_col2_i_temp[i] <= 'b0;
        end
    end else begin
        for (int i = 0 ;i < 4;i++ ) begin
            x1_col1_r_temp[i] <= x1_col1_r[i];
            x1_col1_i_temp[i] <= x1_col1_i[i];
            x1_col2_r_temp[i] <= x1_col2_r[i];
            x1_col2_i_temp[i] <= x1_col2_i[i];

            x2_col1_r_temp[i] <= x2_col1_r[i];
            x2_col1_i_temp[i] <= x2_col1_i[i];
            x2_col2_r_temp[i] <= x2_col2_r[i];
            x2_col2_i_temp[i] <= x2_col2_i[i];
        end
    end
end

always_ff @( posedge clk , negedge rst_n ) begin 
    if(!rst_n)begin
        for (int i = 0;i < 8 ;i++ ) begin
            temp_x1_r[i] <= 'b0;
            temp_x1_i[i] <= 'b0;
            temp_x2_r[i] <= 'b0;
            temp_x2_i[i] <= 'b0;
        end
    end else begin
        for (int i = 0 ;i < 4;i++ ) begin
            temp_x1_r[i+0] <= x1_col1_r_temp[i];
            temp_x1_i[i+0] <= x1_col1_i_temp[i];
            temp_x1_r[i+4] <= x1_col2_r_temp[i];
            temp_x1_i[i+4] <= x1_col2_i_temp[i];

            temp_x2_r[i+0] <= x2_col1_r_temp[i];
            temp_x2_i[i+0] <= x2_col1_i_temp[i];
            temp_x2_r[i+4] <= x2_col2_r_temp[i];
            temp_x2_i[i+4] <= x2_col2_i_temp[i];
        end
    end
end

 always_comb begin 
            temp_wn_r[0] = twiddle_col1[0][63:32];
            temp_wn_i[0] = twiddle_col1[0][31:0 ];
            temp_wn_r[1] = twiddle_col1[1][63:32];
            temp_wn_i[1] = twiddle_col1[1][31:0 ];
            temp_wn_r[2] = twiddle_col1[2][63:32];
            temp_wn_i[2] = twiddle_col1[2][31:0 ];
            temp_wn_r[3] = twiddle_col1[3][63:32];
            temp_wn_i[3] = twiddle_col1[3][31:0 ];
            temp_wn_r[4] = twiddle_col2[0][63:32];
            temp_wn_i[4] = twiddle_col2[0][31:0 ];
            temp_wn_r[5] = twiddle_col2[1][63:32];
            temp_wn_i[5] = twiddle_col2[1][31:0 ];
            temp_wn_r[6] = twiddle_col2[2][63:32];
            temp_wn_i[6] = twiddle_col2[2][31:0 ];
            temp_wn_r[7] = twiddle_col2[3][63:32];
            temp_wn_i[7] = twiddle_col2[3][31:0 ];
end

generate
    genvar i;
    for( i = 0;i < 8;i+=1)begin : butterfly
            butterfly
            #(
                .DATA_WIDTH (DATA_WIDTH ),
                .TWID_WIDTH (TWID_WIDTH ),
                .SHIFT      (SHIFT)
            )
            u_butterfly(
            	.clk   (clk            ),
                .rst_n (rst_n          ),
                .xp_r  (temp_x1_r[i]    ),
                .xp_i  (temp_x1_i[i]    ),
                .xq_r  (temp_x2_r[i]    ),
                .xq_i  (temp_x2_i[i]    ),
                
                .wn_r  (temp_wn_r[i]    ),
                .wn_i  (temp_wn_i[i]    ),

                .yp_r  (temp_dataout_r[i]      ),
                .yp_i  (temp_dataout_i[i]      ),
                .yq_r  (temp_dataout_r[i+8]    ),
                .yq_i  (temp_dataout_i[i+8]    )
            ); 
        end
endgenerate

//rounding
logic signed [31 : 0] temp_cut_tail_r[7:0];
logic signed [31 : 0] temp_cut_tail_i[7:0];

always_comb begin : CUT_tail_r
    for (int n = 0;n < 8 ;n++ ) begin
        if (temp_dataout_r[n][DATA_WIDTH + TWID_WIDTH] == 0) begin
            if (temp_dataout_r[n][LSB_CUTOFF - 1] == 1) begin
                temp_cut_tail_r[n] =  temp_dataout_r[n][DATA_WIDTH + TWID_WIDTH : LSB_CUTOFF] + 'b1;
            end else begin
                temp_cut_tail_r[n] =  temp_dataout_r[n][DATA_WIDTH + TWID_WIDTH : LSB_CUTOFF];
            end
            
        end else if (temp_dataout_r[n][DATA_WIDTH + TWID_WIDTH] == 1) begin
            if (temp_dataout_r[n][LSB_CUTOFF - 1] == 1 && (|temp_dataout_r[n][LSB_CUTOFF - 2:0] == 1)) begin
                temp_cut_tail_r[n] =  temp_dataout_r[n][DATA_WIDTH + TWID_WIDTH : LSB_CUTOFF] + 'b1;
            end else begin
                temp_cut_tail_r[n] =  temp_dataout_r[n][DATA_WIDTH + TWID_WIDTH : LSB_CUTOFF];
            end
        end
    end 
end

always_comb begin : CUT_tail_i
    for (int n = 0;n < 8 ;n++ ) begin
        if (temp_dataout_i[n][DATA_WIDTH + TWID_WIDTH] == 0) begin
            if (temp_dataout_i[n][LSB_CUTOFF - 1] == 1) begin
                temp_cut_tail_i[n] =  temp_dataout_i[n][DATA_WIDTH + TWID_WIDTH : LSB_CUTOFF] + 'b1;
            end else begin
                temp_cut_tail_i[n] =  temp_dataout_i[n][DATA_WIDTH + TWID_WIDTH : LSB_CUTOFF];
            end
            
        end else if (temp_dataout_i[n][DATA_WIDTH + TWID_WIDTH] == 1) begin
            if (temp_dataout_i[n][LSB_CUTOFF - 1] == 1 && (|temp_dataout_i[n][LSB_CUTOFF - 2:0] == 1)) begin
                temp_cut_tail_i[n] =  temp_dataout_i[n][DATA_WIDTH + TWID_WIDTH : LSB_CUTOFF] + 'b1;
            end else begin
                temp_cut_tail_i[n] =  temp_dataout_i[n][DATA_WIDTH + TWID_WIDTH : LSB_CUTOFF];
            end
        end
    end 
end
  
//clamp
// logic signed [DATA_WIDTH - 1 : 0] res_r_cut[15:0];
// logic signed [DATA_WIDTH - 1 : 0] res_i_cut[15:0];

// always_comb begin : CUT_head_r
//     for (int n = 0;n < 16 ;n++ ) begin
//         if ((temp_cut_tail_r[n][DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF] == 1) && (&temp_cut_tail_r[n][(DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF):(MSB_CUTOFF)] == 0)) begin
//             res_r_cut[n] = {1'b1,{(DATA_WIDTH-1){1'b0}}};
//         end else if ((temp_cut_tail_r[n][DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF] == 0) && (|temp_cut_tail_r[n][(DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF):(MSB_CUTOFF)] == 1)) begin
//             res_r_cut[n] = {1'b0,{(DATA_WIDTH-1){1'b1}}};
//         end else begin
//             res_r_cut[n] = {temp_cut_tail_r[n][DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF],temp_cut_tail_r[n][MSB_CUTOFF - 1:0]};
//         end
//     end
// end 
  
// always_comb begin : CUT_head_i
//     for (int n = 0;n < 16 ;n++ ) begin
//         if ((temp_cut_tail_i[n][DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF] == 1) && (&temp_cut_tail_i[n][(DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF):(MSB_CUTOFF)] == 0)) begin
//             res_i_cut[n] = {1'b1,{(DATA_WIDTH-1){1'b0}}};
//         end else if ((temp_cut_tail_i[n][DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF] == 0) && (|temp_cut_tail_i[n][(DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF):(MSB_CUTOFF)] == 1)) begin
//             res_i_cut[n] = {1'b0,{(DATA_WIDTH-1){1'b1}}};
//         end else begin
//             res_i_cut[n] = {temp_cut_tail_i[n][DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF],temp_cut_tail_i[n][MSB_CUTOFF - 1:0]};
//         end
//     end
// end

//data_out
always_ff @( posedge clk,negedge rst_n ) begin
    if(!rst_n)begin
        for (int i = 0;i < 4;i++ ) begin
            dataout_col1_r[i] <= 'b0;
            dataout_col1_i[i] <= 'b0;
            dataout_col2_r[i] <= 'b0;
            dataout_col2_i[i] <= 'b0;
        end

    end else begin
        for (int i = 0;i < 4 ;i++ ) begin
            dataout_col1_r[i] <= temp_cut_tail_r[i];
            dataout_col1_i[i] <= temp_cut_tail_i[i];
            dataout_col2_r[i] <= temp_cut_tail_r[4+i];
            dataout_col2_i[i] <= temp_cut_tail_i[4+i];
        end            
    end
end

//input&output flag

logic valid0;
logic valid1;
logic valid2;
logic valid3;
logic valid4;
logic valid5;

always_ff @( posedge clk , negedge rst_n ) begin 
    if (!rst_n) begin
        ready <= 'd0;
        valid0 <= 'b0;
        valid1 <= 'b0;
        valid2 <= 'b0;
        valid3 <= 'b0;
        valid4 <= 'b0;
        valid5 <= 'b0;
    end else begin
        {ready,valid0,valid1,valid2,valid3,valid4,valid5} <= {valid0,valid1,valid2,valid3,valid4,valid5,valid};
    end
end
//output index_col_1 & index_col_2
logic [10:0] index_col1_0;
logic [10:0] index_col1_1;
logic [10:0] index_col1_2;
logic [10:0] index_col1_3;
logic [10:0] index_col1_4;
logic [10:0] index_col1_5;


logic [10:0] index_col2_0;
logic [10:0] index_col2_1;
logic [10:0] index_col2_2;
logic [10:0] index_col2_3;
logic [10:0] index_col2_4;
logic [10:0] index_col2_5;


always_ff @( posedge clk , negedge rst_n ) begin 
    if (!rst_n) begin
        index_col1_0 <= 'b0;
        index_col1_1 <= 'b0;
        index_col1_2 <= 'b0;
        index_col1_3 <= 'b0;
        index_col1_4 <= 'b0;
        index_col1_5 <= 'b0;


        index_col2_0 <= 'b0;
        index_col2_1 <= 'b0;
        index_col2_2 <= 'b0;
        index_col2_3 <= 'b0;
        index_col2_4 <= 'b0;
        index_col2_5 <= 'b0;
    end else begin
        {output_index_col1,index_col1_0,index_col1_1,index_col1_2,index_col1_3,index_col1_4,index_col1_5} <= {index_col1_0,index_col1_1,index_col1_2,index_col1_3,index_col1_4,index_col1_5,index_col_1};
        {output_index_col2,index_col2_0,index_col2_1,index_col2_2,index_col2_3,index_col2_4,index_col2_5} <= {index_col2_0,index_col2_1,index_col2_2,index_col2_3,index_col2_4,index_col2_5,index_col_2};
    end
end

endmodule