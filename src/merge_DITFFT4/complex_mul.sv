// 2 clk;
module complex_mul #(
    parameter DATA_WIDTH = 21,
    parameter TWID_WIDTH = 16,
    //Truncate at bit MSB_CUTOFF

    parameter SHIFT = 0
) (
    input logic clk,
    input logic rst_n,

    input logic [DATA_WIDTH - 1 : 0] a_r,
    input logic [DATA_WIDTH - 1 : 0] a_i,
    input logic [TWID_WIDTH - 1 : 0] b_r,
    input logic [TWID_WIDTH - 1 : 0] b_i,

    output logic [DATA_WIDTH + TWID_WIDTH : 0] c_r,
    output logic [DATA_WIDTH + TWID_WIDTH : 0] c_i

);

logic signed [DATA_WIDTH - 1 : 0] a_r_s;
logic signed [DATA_WIDTH - 1 : 0] a_i_s;

logic signed [TWID_WIDTH - 1 : 0] b_r_s;
logic signed [TWID_WIDTH - 1 : 0] b_i_s;

logic signed [DATA_WIDTH + TWID_WIDTH - 1 : 0] temp_ar_br;
logic signed [DATA_WIDTH + TWID_WIDTH - 1 : 0] temp_ai_bi;
logic signed [DATA_WIDTH + TWID_WIDTH - 1 : 0] temp_ar_bi;
logic signed [DATA_WIDTH + TWID_WIDTH - 1 : 0] temp_ai_br;

logic signed [DATA_WIDTH + TWID_WIDTH : 0] c_i_s;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] c_r_s;

always_comb begin
    if(!rst_n)begin
        a_r_s = 'b0;
        a_i_s = 'b0;
        b_r_s = 'b0;
        b_i_s = 'b0;
    end else begin
        a_r_s = a_r;
        a_i_s = a_i;
        b_r_s = b_r;
        b_i_s = b_i;
    end
end

always_ff @( posedge clk,negedge rst_n ) begin
    if(!rst_n)begin
        temp_ar_br <= 'b0;
        temp_ai_bi <= 'b0;
        temp_ar_bi <= 'b0;
        temp_ai_br <= 'b0;        
    end else begin
        temp_ar_br <= a_r_s * b_r_s;
        temp_ai_bi <= a_i_s * b_i_s;
        temp_ar_bi <= a_r_s * b_i_s;
        temp_ai_br <= a_i_s * b_r_s;
    end
end

always_comb begin
        c_r_s = temp_ar_br - temp_ai_bi;
        c_i_s = temp_ar_bi + temp_ai_br;
end

always_ff @( posedge clk ,negedge rst_n ) begin
    if(!rst_n)begin
        c_r <= 'b0;
        c_i <= 'b0;     
    end else begin
        c_r <= c_r_s;
        c_i <= c_i_s;
    end
end

endmodule