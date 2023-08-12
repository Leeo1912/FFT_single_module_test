
//6 clk output
module  parallel_mul_twiddle_FFT4 #(
    parameter DATA_WIDTH = 21,
    parameter TWID_WIDTH = 16,
    //Truncate at bit MSB_CUTOFF
    parameter MSB_CUTOFF = 26,                   // [DATA_WIDTH + TWID_WIDTH + 1 - LSB_CUTOFF : 0] temp_cut_tail_r[3:0];
    parameter LSB_CUTOFF = 12,                   // [DATA_WIDTH + TWID_WIDTH +1 : 0] temp_add_r_res[3:0];
    parameter OUT_WIDTH = 27,
    parameter SHIFT = 15
) (
    input logic clk,
    input logic rst_n,
    input logic valid,

    input logic [10:0] lable,

    input logic [DATA_WIDTH-1:0] x0_r,
    input logic [DATA_WIDTH-1:0] x0_i,
    input logic [DATA_WIDTH-1:0] x1_r,
    input logic [DATA_WIDTH-1:0] x1_i,
    input logic [DATA_WIDTH-1:0] x2_r,
    input logic [DATA_WIDTH-1:0] x2_i,
    input logic [DATA_WIDTH-1:0] x3_r,
    input logic [DATA_WIDTH-1:0] x3_i,

    output logic [26:0] y0_r,
    output logic [26:0] y0_i,
    output logic [26:0] y1_r,
    output logic [26:0] y1_i,
    output logic [26:0] y2_r,
    output logic [26:0] y2_i,
    output logic [26:0] y3_r,
    output logic [26:0] y3_i,
    output logic [10:0] index,
    output logic ready
);

logic [255:0] twiddle[2:0];

logic signed [DATA_WIDTH-1:0] x_r_s[3:0];
logic signed [DATA_WIDTH-1:0] x_i_s[3:0];

logic signed [DATA_WIDTH-1:0] x_r_s_reg[3:0];
logic signed [DATA_WIDTH-1:0] x_i_s_reg[3:0];

logic signed [TWID_WIDTH-1:0] twi_r_s[2:0][3:0];
logic signed [TWID_WIDTH-1:0] twi_i_s[2:0][3:0];

logic signed [DATA_WIDTH + TWID_WIDTH : 0] temp_mul_r_res[3:0][3:0];
logic signed [DATA_WIDTH + TWID_WIDTH : 0] temp_mul_i_res[3:0][3:0];

logic signed [DATA_WIDTH + TWID_WIDTH + 2 : 0] temp_add_r_res[3:0];
logic signed [DATA_WIDTH + TWID_WIDTH + 2 : 0] temp_add_i_res[3:0];

logic signed [26 : 0] res_r_cut[3:0];
logic signed [26 : 0] res_i_cut[3:0];

//first clk
logic [10:0] lable_reg;
logic valid_reg;
always_ff @( posedge clk,negedge rst_n ) begin
    if (!rst_n) begin
        lable_reg <= 0;
        valid_reg <= 0;
    end else begin
        lable_reg <= lable;
        valid_reg <= valid;
    end
end

rom_twiddle u_rom_twiddle(
    .clk    (clk        ),
    .rst_n  (rst_n      ),
    .valid  (valid_reg      ),
    .addr_i (lable_reg  ),
    .data_o (twiddle    )
);

always_ff @( posedge clk,negedge rst_n ) begin  
   if (!rst_n) begin
        x_r_s_reg[0] <= 'b0;
        x_i_s_reg[0] <= 'b0;
        x_r_s_reg[1] <= 'b0;
        x_i_s_reg[1] <= 'b0;
        x_r_s_reg[2] <= 'b0;
        x_i_s_reg[2] <= 'b0;
        x_r_s_reg[3] <= 'b0;
        x_i_s_reg[3] <= 'b0;
   end else begin
        x_r_s_reg[0] <= x0_r;
        x_i_s_reg[0] <= x0_i;
        x_r_s_reg[1] <= x1_r;
        x_i_s_reg[1] <= x1_i;
        x_r_s_reg[2] <= x2_r;
        x_i_s_reg[2] <= x2_i;
        x_r_s_reg[3] <= x3_r;
        x_i_s_reg[3] <= x3_i;
   end
end

always_ff @( posedge clk,negedge rst_n ) begin  
   if (!rst_n) begin
        x_r_s[0] <= 'b0;
        x_i_s[0] <= 'b0;
        x_r_s[1] <= 'b0;
        x_i_s[1] <= 'b0;
        x_r_s[2] <= 'b0;
        x_i_s[2] <= 'b0;
        x_r_s[3] <= 'b0;
        x_i_s[3] <= 'b0;
   end else begin
        x_r_s[0] <= x_r_s_reg[0];
        x_i_s[0] <= x_i_s_reg[0];
        x_r_s[1] <= x_r_s_reg[1];
        x_i_s[1] <= x_i_s_reg[1];
        x_r_s[2] <= x_r_s_reg[2];
        x_i_s[2] <= x_i_s_reg[2];
        x_r_s[3] <= x_r_s_reg[3];
        x_i_s[3] <= x_i_s_reg[3];
   end
end

always_comb begin
    if(!rst_n)begin
        twi_r_s[0][0] = 'b0;
        twi_i_s[0][0] = 'b0;
        twi_r_s[0][1] = 'b0;
        twi_i_s[0][1] = 'b0;
        twi_r_s[0][2] = 'b0;
        twi_i_s[0][2] = 'b0;
        twi_r_s[0][3] = 'b0;
        twi_i_s[0][3] = 'b0;

        twi_r_s[1][0] = 'b0;
        twi_i_s[1][0] = 'b0;
        twi_r_s[1][1] = 'b0;
        twi_i_s[1][1] = 'b0;
        twi_r_s[1][2] = 'b0;
        twi_i_s[1][2] = 'b0;
        twi_r_s[1][3] = 'b0;
        twi_i_s[1][3] = 'b0;

        twi_r_s[2][0] = 'b0;
        twi_i_s[2][0] = 'b0;
        twi_r_s[2][1] = 'b0;
        twi_i_s[2][1] = 'b0;
        twi_r_s[2][2] = 'b0;
        twi_i_s[2][2] = 'b0;
        twi_r_s[2][3] = 'b0;
        twi_i_s[2][3] = 'b0;

    end else begin
        twi_r_s[0][0] = twiddle[0][255:224];
        twi_i_s[0][0] = twiddle[0][223:192];
        twi_r_s[0][1] = twiddle[0][191:160];
        twi_i_s[0][1] = twiddle[0][159:128];
        twi_r_s[0][2] = twiddle[0][127:96];
        twi_i_s[0][2] = twiddle[0][95 :64];
        twi_r_s[0][3] = twiddle[0][63 :32];
        twi_i_s[0][3] = twiddle[0][31 : 0];

        twi_r_s[1][0] = twiddle[1][255:224];
        twi_i_s[1][0] = twiddle[1][223:192];
        twi_r_s[1][1] = twiddle[1][191:160];
        twi_i_s[1][1] = twiddle[1][159:128];
        twi_r_s[1][2] = twiddle[1][127:96];
        twi_i_s[1][2] = twiddle[1][95 :64];
        twi_r_s[1][3] = twiddle[1][63 :32];
        twi_i_s[1][3] = twiddle[1][31 : 0];

        twi_r_s[2][0] = twiddle[2][255:224];
        twi_i_s[2][0] = twiddle[2][223:192];
        twi_r_s[2][1] = twiddle[2][191:160];
        twi_i_s[2][1] = twiddle[2][159:128];
        twi_r_s[2][2] = twiddle[2][127:96];
        twi_i_s[2][2] = twiddle[2][95 :64];
        twi_r_s[2][3] = twiddle[2][63 :32];
        twi_i_s[2][3] = twiddle[2][31 : 0];
    end
end

//x0  +  x1*rom1[lable]  +  x2*rom2[lable]  +  x2*rom2[lable] = X(output)

    //mul
generate
    genvar k , i;
    for (k = 0;k < 4 ;k++ ) begin
        for (i = 0;i < 4 ;i++ ) begin
            if (k == 0) begin
                X0_shift 
                #(
                    .DATA_WIDTH (DATA_WIDTH ),
                    .TWID_WIDTH (TWID_WIDTH ),
                    .SHIFT (SHIFT)
                )
                u_X0_shift(
                    .clk   (clk   ),
                    .rst_n (rst_n ),
                    .a_r   (x_r_s[0]  ),
                    .a_i   (x_i_s[0]  ),
                    .b_r   (temp_mul_r_res[k][i]    ),
                    .b_i   (temp_mul_i_res[k][i]    )
                );
            end else begin
                complex_mul 
                #(
                    .DATA_WIDTH (DATA_WIDTH ),
                    .TWID_WIDTH (TWID_WIDTH ),
                    .SHIFT      (SHIFT      )
                )
                u_complex_mul(
                    .clk   (clk   ),
                    .rst_n (rst_n ),
                    .a_r   (x_r_s[k]   ),
                    .a_i   (x_i_s[k]   ),
                    .b_r   (twi_r_s[k-1][i]   ),
                    .b_i   (twi_i_s[k-1][i]   ),
                    .c_r   (temp_mul_r_res[k][i]   ),
                    .c_i   (temp_mul_i_res[k][i]   )
                    
                );
            end
        end    
    end
endgenerate

// logic signed [DATA_WIDTH + TWID_WIDTH : 0] x_r_s_expend;
// logic signed [DATA_WIDTH + TWID_WIDTH : 0] x_i_s_expend;

// logic signed [DATA_WIDTH + TWID_WIDTH : 0] x_r_s_16_point;
// logic signed [DATA_WIDTH + TWID_WIDTH : 0] x_i_s_16_point;

// always_comb begin
//     x_r_s_expend = x_r_s[0];
//     x_i_s_expend = x_i_s[0]; 
// end

// always_comb begin
//     x_r_s_16_point = (x_r_s_expend << 1);
//     x_i_s_16_point = (x_i_s_expend << 1); 
// end

  //add
always_ff @( posedge clk , negedge rst_n ) begin
    if(!rst_n)begin
        temp_add_r_res[0] <= 'b0;
        temp_add_i_res[0] <= 'b0;
        temp_add_r_res[1] <= 'b0;
        temp_add_i_res[1] <= 'b0;
        temp_add_r_res[2] <= 'b0;
        temp_add_i_res[2] <= 'b0;
        temp_add_r_res[3] <= 'b0;
        temp_add_i_res[3] <= 'b0;
    end else begin
        for (int j = 0;j < 4 ;j++ ) begin
            temp_add_r_res[j] <= (temp_mul_r_res[0][j] + temp_mul_r_res[1][j] + temp_mul_r_res[2][j] + temp_mul_r_res[3][j]);//>>>SHIFT;
            temp_add_i_res[j] <= (temp_mul_i_res[0][j] + temp_mul_i_res[1][j] + temp_mul_i_res[2][j] + temp_mul_i_res[3][j]);//>>>SHIFT;
        end
    end
end

//rounding
logic signed [DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF : 0] temp_cut_tail_r[3:0];
logic signed [DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF : 0] temp_cut_tail_i[3:0];

always_comb begin : CUT_tail_r
    for (int n = 0;n < 4 ;n++ ) begin
        if (temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 2] == 0) begin
            if (temp_add_r_res[n][LSB_CUTOFF - 1] == 1) begin
                temp_cut_tail_r[n] =  temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 2 : LSB_CUTOFF] + 'b1;
            end else begin
                temp_cut_tail_r[n] =  temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 2 : LSB_CUTOFF];
            end
            
        end else if (temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 2] == 1) begin
            if (temp_add_r_res[n][LSB_CUTOFF - 1] == 1 && (|temp_add_r_res[n][LSB_CUTOFF - 2:0] == 1)) begin
                temp_cut_tail_r[n] =  temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 2 : LSB_CUTOFF] + 'b1;
            end else begin
                temp_cut_tail_r[n] =  temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 2 : LSB_CUTOFF];
            end
        end
    end 
end

always_comb begin : CUT_tail_i
    for (int n = 0;n < 4 ;n++ ) begin
        if (temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 2] == 0) begin
            if (temp_add_i_res[n][LSB_CUTOFF - 1] == 1) begin
                 temp_cut_tail_i[n] =  temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 2 : LSB_CUTOFF] + 'b1;
            end else begin
                 temp_cut_tail_i[n] =  temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 2 : LSB_CUTOFF];
            end
            
        end else if (temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 2] == 1) begin
            if (temp_add_i_res[n][LSB_CUTOFF - 1] == 1 && (|temp_add_i_res[n][LSB_CUTOFF - 2:0] == 1)) begin
                 temp_cut_tail_i[n] =  temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 2 : LSB_CUTOFF] + 'b1;
            end else begin
                 temp_cut_tail_i[n] =  temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 2 : LSB_CUTOFF];
            end
        end
    end 
end
  
//clamp
always_comb begin : CUT_head_r
    for (int n = 0;n < 4 ;n++ ) begin
        if ((temp_cut_tail_r[n][DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF] == 1) && (&temp_cut_tail_r[n][(DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF):(MSB_CUTOFF)] == 0)) begin
            res_r_cut[n] = {1'b1,{(OUT_WIDTH-1){1'b0}}};
        end else if ((temp_cut_tail_r[n][DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF] == 0) && (|temp_cut_tail_r[n][(DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF):(MSB_CUTOFF)] == 1)) begin
            res_r_cut[n] = {1'b0,{(OUT_WIDTH-1){1'b1}}};
        end else begin
            res_r_cut[n] = {temp_cut_tail_r[n][DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF],temp_cut_tail_r[n][MSB_CUTOFF - 1:0]};
        end
    end
end 
  
always_comb begin : CUT_head_i
    for (int n = 0;n < 4 ;n++ ) begin
        if ((temp_cut_tail_i[n][DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF] == 1) && (&temp_cut_tail_i[n][(DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF):(MSB_CUTOFF)] == 0)) begin
            res_i_cut[n] = {1'b1,{(OUT_WIDTH-1){1'b0}}};
        end else if ((temp_cut_tail_i[n][DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF] == 0) && (|temp_cut_tail_i[n][(DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF):(MSB_CUTOFF)] == 1)) begin
            res_i_cut[n] = {1'b0,{(OUT_WIDTH-1){1'b1}}};
        end else begin
            res_i_cut[n] = {temp_cut_tail_i[n][DATA_WIDTH + TWID_WIDTH + 2 - LSB_CUTOFF],temp_cut_tail_i[n][MSB_CUTOFF - 1:0]};
        end
    end
end

  //parameterized bit truncation
// always_comb begin :CUT_r
//     for (int n = 0;n < 4 ;n++ ) begin
//         if ((temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 1] == 1) && (&temp_add_r_res[n][(DATA_WIDTH + TWID_WIDTH + 1):MSB_CUTOFF] == 0)) begin
//             res_r_cut[n] = {1'b1,{(DATA_WIDTH-1){1'b0}}};
//         end else if ((temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 1] == 0) && (|temp_add_r_res[n][(DATA_WIDTH + TWID_WIDTH + 1):MSB_CUTOFF] == 1)) begin
//             res_r_cut[n] = {1'b0,{(DATA_WIDTH-1){1'b1}}};
//         end else begin
//             res_r_cut[n] = {temp_add_r_res[n][DATA_WIDTH + TWID_WIDTH + 1],temp_add_r_res[n][(MSB_CUTOFF-1):(MSB_CUTOFF - (DATA_WIDTH - 1))]};
//         end
//     end 
// end

// always_comb begin :CUT_i
//     for (int n = 0;n < 4 ;n++ ) begin
//         if ((temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 1] == 1) && (&temp_add_i_res[n][(DATA_WIDTH + TWID_WIDTH + 1):MSB_CUTOFF] == 0)) begin
//             res_i_cut[n] = {1'b1,{(DATA_WIDTH-1){1'b0}}};
//         end else if ((temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 1] == 0) && (|temp_add_i_res[n][(DATA_WIDTH + TWID_WIDTH + 1):MSB_CUTOFF] == 1)) begin
//             res_i_cut[n] = {1'b0,{(DATA_WIDTH-1){1'b1}}};
//         end else begin
//             res_i_cut[n] = {temp_add_i_res[n][DATA_WIDTH + TWID_WIDTH + 1],temp_add_i_res[n][(MSB_CUTOFF-1):(MSB_CUTOFF - (DATA_WIDTH - 1))]};
//         end
//     end 
// end

//output
always_ff @( posedge clk,negedge rst_n ) begin
    if(!rst_n)begin
        y0_r <= 'b0; 
        y0_i <= 'b0; 
        y1_r <= 'b0; 
        y1_i <= 'b0; 
        y2_r <= 'b0; 
        y2_i <= 'b0; 
        y3_r <= 'b0; 
        y3_i <= 'b0; 
    end else begin
        y0_r <= res_r_cut[0]; 
        y0_i <= res_i_cut[0]; 
        y1_r <= res_r_cut[1]; 
        y1_i <= res_i_cut[1]; 
        y2_r <= res_r_cut[2]; 
        y2_i <= res_i_cut[2]; 
        y3_r <= res_r_cut[3]; 
        y3_i <= res_i_cut[3]; 

    end
end

//output index
logic [10:0] index_0;
logic [10:0] index_1;
logic [10:0] index_2;
logic [10:0] index_3;
logic [10:0] index_4;
// logic [10:0] index_5;
always_ff @( posedge clk,negedge rst_n ) begin
    if (!rst_n) begin
        index_0 <= 'b0;
        index_1 <= 'b0;
        index_2 <= 'b0;
        index_3 <= 'b0;
        index_4 <= 'b0;
        // index_5 <= 'b0;
    end else if ((ready == 0) && (valid == 0)) begin
        index <= 'b0;
    end else begin
        {index,index_0,index_1,index_2,index_3,index_4} <= {index_0,index_1,index_2,index_3,index_4,lable};
    end
end





//input&output flag    
logic valid0;
logic valid1;
logic valid2;
logic valid3;
logic valid4;
// logic valid5;

always_ff @( posedge clk , negedge rst_n ) begin 
    if (!rst_n) begin
        ready <= 'd0;
        valid0 <= 'b0;
        valid1 <= 'b0;
        valid2 <= 'b0;
        valid3 <= 'b0;
        valid4 <= 'b0;
        // valid5 <= 'b0;

    end else begin
        {ready,valid0,valid1,valid2,valid3,valid4} <= {valid0,valid1,valid2,valid3,valid4,valid};
    end
end
endmodule