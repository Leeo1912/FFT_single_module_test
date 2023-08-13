module X0_shift #(
    parameter DATA_WIDTH = 21,
    parameter TWID_WIDTH = 16,
    parameter SHIFT = 15
) (
    input clk,
    input rst_n,
    input logic [DATA_WIDTH - 1:0] a_r,
    input logic [DATA_WIDTH - 1:0] a_i,
    output logic [DATA_WIDTH + TWID_WIDTH : 0] b_r,
    output logic [DATA_WIDTH + TWID_WIDTH : 0] b_i
);
    logic signed [DATA_WIDTH - 1:0] a_r_s;
    logic signed [DATA_WIDTH - 1:0] a_i_s;
    //logic signed [DATA_WIDTH + TWID_WIDTH : 0]b_r_s;
    //logic signed [DATA_WIDTH + TWID_WIDTH : 0]b_i_s;

    logic signed [DATA_WIDTH + TWID_WIDTH : 0] a_r_shift;
    logic signed [DATA_WIDTH + TWID_WIDTH : 0] a_i_shift;

    always_comb begin 

            a_r_s = a_r;
            a_i_s = a_i;

    end

    always_ff @( posedge clk,negedge rst_n ) begin 
        if(!rst_n)begin
            a_r_shift <= 'b0;
            a_i_shift <= 'b0;
        end else begin
            a_r_shift <= (a_r_s << SHIFT);
            a_i_shift <= (a_i_s << SHIFT);
        end
    end

    always_ff @( posedge clk,negedge rst_n ) begin 
        if(!rst_n)begin
            b_r <= 'b0;
            b_i <= 'b0;
        end else begin
            b_r <= a_r_shift;
            b_i <= a_i_shift;
        end
    end
endmodule