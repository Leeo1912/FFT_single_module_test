//4clk
module intergral #(
    parameter IN_DATA_WIDTH = 32,
    parameter OUT_DATA_WIDTH = 52,
    //Truncate at bit MSB_CUTOFF
    parameter LSB_CUTOFF = 11,                   // rounding basing add_square_col1
    parameter MSB_CUTOFF = 51                   // clamp(after rounding) basing temp_cut_tail_col1
) (
    input logic clk,
    input logic rst_n,
    input logic valid,
    input logic [10:0] index_col_1,
    input logic [10:0] index_col_2,

    output logic ready,

    input logic [3:0][IN_DATA_WIDTH - 1:0] col1_r,
    input logic [3:0][IN_DATA_WIDTH - 1:0] col1_i,
    input logic [3:0][IN_DATA_WIDTH - 1:0] col2_r,
    input logic [3:0][IN_DATA_WIDTH - 1:0] col2_i,

    output logic [3:0][OUT_DATA_WIDTH - 1:0] col_1,
    output logic [3:0][OUT_DATA_WIDTH - 1:0] col_2,

    output logic [10:0] out_index_col1,
    output logic [10:0] out_index_col2
);
    logic signed [IN_DATA_WIDTH - 1 : 0] col1_r_s[3:0];
    logic signed [IN_DATA_WIDTH - 1 : 0] col1_i_s[3:0];
    logic signed [IN_DATA_WIDTH - 1 : 0] col2_r_s[3:0];
    logic signed [IN_DATA_WIDTH - 1 : 0] col2_i_s[3:0];

    always_ff @( posedge clk,negedge rst_n ) begin
        if(!rst_n)begin
            for (int i = 0;i < 4 ;i++ ) begin
                col1_r_s[i] <= 'b0;
                col1_i_s[i] <= 'b0;
                col2_r_s[i] <= 'b0;
                col2_i_s[i] <= 'b0;
            end
        end else if(valid == 1) begin
            if (index_col_1 == 'd0 || index_col_1 =='d1) begin
                for (int i = 0;i < 4 ;i++ ) begin
                    col1_r_s[i] <= col1_r[i];
                    col1_i_s[i] <= col1_i[i];
                    col2_r_s[i] <= 'b0;
                    col2_i_s[i] <= 'b0;
            end
            end else
                for (int i = 0;i < 4 ;i++ ) begin
                    col1_r_s[i] <= col1_r[i];
                    col1_i_s[i] <= col1_i[i];
                    col2_r_s[i] <= col2_r[i];
                    col2_i_s[i] <= col2_i[i];
                end
        end else begin
            for (int i = 0;i < 4 ;i++ ) begin
                col1_r_s[i] <= 'b0;
                col1_i_s[i] <= 'b0;
                col2_r_s[i] <= 'b0;
                col2_i_s[i] <= 'b0;
            end
        end
    end
//square
    logic signed [IN_DATA_WIDTH * 2 -1 : 0] square_col1_r[3:0];
    logic signed [IN_DATA_WIDTH * 2 -1 : 0] square_col1_i[3:0];
    logic signed [IN_DATA_WIDTH * 2 -1 : 0] square_col2_r[3:0];
    logic signed [IN_DATA_WIDTH * 2 -1 : 0] square_col2_i[3:0];

    always_ff @( posedge clk,negedge rst_n ) begin
        if (!rst_n) begin
            for (int i = 0;i < 4 ;i++ ) begin
                square_col1_r[i] <= 'b0;
                square_col1_i[i] <= 'b0;
                square_col2_r[i] <= 'b0;
                square_col2_i[i] <= 'b0;
            end
        end else begin
            for (int i = 0;i < 4 ;i++ ) begin
                square_col1_r[i] <= col1_r_s[i] * col1_r_s[i];
                square_col1_i[i] <= col1_i_s[i] * col1_i_s[i];
                square_col2_r[i] <= col2_r_s[i] * col2_r_s[i];
                square_col2_i[i] <= col2_i_s[i] * col2_i_s[i];
            end
        end
    end

//add
    logic [IN_DATA_WIDTH * 2 : 0] add_square_col1[3:0];
    logic [IN_DATA_WIDTH * 2 : 0] add_square_col2[3:0];

    always_ff @( posedge clk,negedge rst_n ) begin
        if (!rst_n) begin
            for (int i = 0;i < 4 ;i++ ) begin
                add_square_col1[i] <= 'b0;
                add_square_col2[i] <= 'b0;
            end
        end else begin
            for (int i = 0;i < 4 ;i++ ) begin
                add_square_col1[i] <= square_col1_r[i] + square_col1_i[i];
                add_square_col2[i] <= square_col2_r[i] + square_col2_i[i];
            end
        end
    end

//rounding
logic [IN_DATA_WIDTH * 2 - LSB_CUTOFF : 0] temp_cut_tail_col1[3:0];
logic [IN_DATA_WIDTH * 2 - LSB_CUTOFF : 0] temp_cut_tail_col2[3:0];

    always_comb begin : CUT_tail_add_square_col1
        for (int n = 0;n < 4 ;n++ ) begin
            if (add_square_col1[n][IN_DATA_WIDTH * 2] == 0) begin
                if (add_square_col1[n][LSB_CUTOFF - 1] == 1) begin

                    if (&add_square_col1[n][IN_DATA_WIDTH * 2 - 1 : LSB_CUTOFF]) begin
                        temp_cut_tail_col1[n] = {1'b0,{(IN_DATA_WIDTH * 2 - LSB_CUTOFF){1'b0}}};
                    end else begin
                        temp_cut_tail_col1[n] =  add_square_col1[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF] + 'b1;   
                    end

                    //temp_cut_tail_col1[n] =  add_square_col1[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF] + 'b1;
                end else begin
                    temp_cut_tail_col1[n] =  add_square_col1[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF];
                end
                
            end else begin
                if (add_square_col1[n][LSB_CUTOFF - 1] == 1 && (|add_square_col1[n][LSB_CUTOFF - 2:0] == 1)) begin
                    temp_cut_tail_col1[n] =  add_square_col1[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF] + 'b1;
                end else begin
                    temp_cut_tail_col1[n] =  add_square_col1[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF];
                end
            end
        end 
    end

    always_comb begin : CUT_tail_add_square_col2
        for (int n = 0;n < 4 ;n++ ) begin
            if (add_square_col2[n][IN_DATA_WIDTH * 2] == 0) begin
                if (add_square_col2[n][LSB_CUTOFF - 1] == 1) begin

                    if (&add_square_col2[n][IN_DATA_WIDTH * 2 - 1 : LSB_CUTOFF]) begin
                        temp_cut_tail_col2[n] = {1'b0,{(IN_DATA_WIDTH * 2 - LSB_CUTOFF){1'b0}}};
                    end else begin
                        temp_cut_tail_col2[n] = add_square_col2[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF] + 'b1;   
                    end
                    
                    //temp_cut_tail_col2[n] = add_square_col2[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF] + 'b1;
                end else begin
                    temp_cut_tail_col2[n] = add_square_col2[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF];
                end
                
            end else begin
                if (add_square_col2[n][LSB_CUTOFF - 1] == 1 && (|add_square_col2[n][LSB_CUTOFF - 2:0] == 1)) begin
                    temp_cut_tail_col2[n] = add_square_col2[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF] + 'b1;
                end else begin
                    temp_cut_tail_col2[n] = add_square_col2[n][IN_DATA_WIDTH * 2 : LSB_CUTOFF];
                end
            end
        end 
    end
  
//clamp
logic [OUT_DATA_WIDTH - 1 : 0] res_col1_cut[3:0];
logic [OUT_DATA_WIDTH - 1 : 0] res_col2_cut[3:0];

    always_comb begin : CUT_head_add_square_col1
        for (int n = 0;n < 4 ;n++ ) begin
            if (|temp_cut_tail_col1[n][(IN_DATA_WIDTH * 2 - LSB_CUTOFF):(MSB_CUTOFF+1)] == 1) begin
                res_col1_cut[n] = {OUT_DATA_WIDTH{1'b1}};
            end else begin
                res_col1_cut[n] = {temp_cut_tail_col1[n][MSB_CUTOFF : 0]};
            end
        end
    end 
    
    always_comb begin : CUT_head_add_square_col2
        for (int n = 0;n < 4 ;n++ ) begin
            if (|temp_cut_tail_col2[n][(IN_DATA_WIDTH * 2 - LSB_CUTOFF):(MSB_CUTOFF+1)] == 1) begin
                res_col2_cut[n] = {OUT_DATA_WIDTH{1'b1}};
            end else begin
                res_col2_cut[n] = {temp_cut_tail_col2[n][MSB_CUTOFF : 0]};
            end
        end
    end

//data_out
always_ff @( posedge clk,negedge rst_n ) begin
    if(!rst_n)begin
        for (int i = 0;i < 4;i++ ) begin
            col_1[i] <= 'b0;
            col_2[i] <= 'b0;
        end
    end else begin
        for (int i = 0;i < 4 ;i++ ) begin
            col_1[i] <= res_col1_cut[i];
            col_2[i] <= res_col2_cut[i];
        end           
    end
end

//input&output flag
logic valid0;
logic valid1;
logic valid2;

always_ff @( posedge clk , negedge rst_n ) begin 
    if (!rst_n) begin
        ready <= 'd0;
        valid0 <= 'b0;
        valid1 <= 'b0;
        valid2 <= 'b0;

    end else begin
        {ready,valid0,valid1,valid2} <= {valid0,valid1,valid2,valid};
    end
end

//output index_col_1&index_col_2
logic [10:0] index_col1_0;
logic [10:0] index_col1_1;
logic [10:0] index_col1_2;

logic [10:0] index_col2_0;
logic [10:0] index_col2_1;
logic [10:0] index_col2_2;

always_ff @( posedge clk , negedge rst_n ) begin 
    if (!rst_n) begin
        index_col1_0 <= 'b0;
        index_col1_1 <= 'b0;
        index_col1_2 <= 'b0;
        out_index_col1 <= 'b0;

        index_col2_0 <= 'b0;
        index_col2_1 <= 'b0;
        index_col2_2 <= 'b0;
        out_index_col2 <= 'b0;
    
    end else begin
        {out_index_col1,index_col1_0,index_col1_1,index_col1_2} <= {index_col1_0,index_col1_1,index_col1_2,index_col_1};
        {out_index_col2,index_col2_0,index_col2_1,index_col2_2} <= {index_col2_0,index_col2_1,index_col2_2,index_col_2};
    end
end


endmodule