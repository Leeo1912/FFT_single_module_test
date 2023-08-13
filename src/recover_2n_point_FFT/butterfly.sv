module butterfly #(
    parameter DATA_WIDTH = 27,
    parameter TWID_WIDTH = 16,
    parameter SHIFT = 15
) (
    input logic clk,
    input logic rst_n,

    input logic [DATA_WIDTH - 1 : 0] xp_r,
    input logic [DATA_WIDTH - 1 : 0] xp_i,
    input logic [DATA_WIDTH - 1 : 0] xq_r,
    input logic [DATA_WIDTH - 1 : 0] xq_i,

    input logic [TWID_WIDTH - 1 : 0] wn_r,
    input logic [TWID_WIDTH - 1 : 0] wn_i,

    output logic [DATA_WIDTH + TWID_WIDTH : 0] yp_r,
    output logic [DATA_WIDTH + TWID_WIDTH : 0] yp_i,
    output logic [DATA_WIDTH + TWID_WIDTH : 0] yq_r,
    output logic [DATA_WIDTH + TWID_WIDTH : 0] yq_i
);

logic signed [DATA_WIDTH - 1 : 0] xp_r_s;
logic signed [DATA_WIDTH - 1 : 0] xp_i_s;
logic signed [DATA_WIDTH - 1 : 0] xq_r_s;
logic signed [DATA_WIDTH - 1 : 0] xq_i_s;
// logic signed [DATA_WIDTH - 1 : 0] yp_r_s;
// logic signed [DATA_WIDTH - 1 : 0] yp_i_s;
// logic signed [DATA_WIDTH - 1 : 0] yq_r_s;
// logic signed [DATA_WIDTH - 1 : 0] yq_i_s;

logic signed [TWID_WIDTH - 1 : 0] wn_r_s;
logic signed [TWID_WIDTH - 1 : 0] wn_i_s;

always_comb begin
        xp_r_s = xp_r;
        xp_i_s = xp_i;
        xq_r_s = xq_r;
        xq_i_s = xq_i;

        wn_r_s = wn_r;
        wn_i_s = wn_i;
end

logic signed [DATA_WIDTH + TWID_WIDTH - 2 : 0] temp_ac;
logic signed [DATA_WIDTH + TWID_WIDTH - 2 : 0] temp_bd;
logic signed [DATA_WIDTH + TWID_WIDTH - 2 : 0] temp_ad;
logic signed [DATA_WIDTH + TWID_WIDTH - 2 : 0] temp_bc;
logic signed [DATA_WIDTH + TWID_WIDTH - 2 : 0] xp_r_d;
logic signed [DATA_WIDTH + TWID_WIDTH - 2 : 0] xp_i_d;


always_ff @( posedge clk,negedge rst_n ) begin 
    if(!rst_n)begin
        temp_ac <= 'b0;
        temp_bd <= 'b0;
        temp_ad <= 'b0;
        temp_bc <= 'b0;
        xp_r_d <= 'b0;
        xp_i_d <= 'b0;
    end else begin
        temp_ac <= xq_r_s * wn_r_s;
        temp_bd <= xq_i_s * wn_i_s;
        temp_ad <= xq_r_s * wn_i_s;
        temp_bc <= xq_i_s * wn_r_s;
        xp_r_d <= (xp_r_s << SHIFT);
        xp_i_d <= (xp_i_s << SHIFT);
    end
end

logic signed [DATA_WIDTH + TWID_WIDTH - 1 : 0] temp_ac_bd;
logic signed [DATA_WIDTH + TWID_WIDTH - 1 : 0] temp_ad_bc;
logic signed [DATA_WIDTH + TWID_WIDTH - 1 : 0] xp_r_d1;
logic signed [DATA_WIDTH + TWID_WIDTH - 1 : 0] xp_i_d1;

always_ff @( posedge clk,negedge rst_n ) begin
    if(!rst_n)begin
        temp_ac_bd <= 'b0;
        temp_ad_bc <= 'b0;
        xp_r_d1 <= 'b0;
        xp_i_d1 <= 'b0;
    end else begin
        temp_ac_bd <= temp_ac - temp_bd;
        temp_ad_bc <= temp_ad + temp_bc;
        xp_r_d1 <= xp_r_d;
        xp_i_d1 <= xp_i_d;
    end
end

logic signed [DATA_WIDTH + TWID_WIDTH : 0] temp_yp_r;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] temp_yp_i;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] temp_yq_r;
logic signed [DATA_WIDTH + TWID_WIDTH : 0] temp_yq_i;

always_ff @( posedge clk,negedge rst_n ) begin
    if(!rst_n)begin
        temp_yp_r <= 'b0;
        temp_yp_i <= 'b0;
        temp_yq_r <= 'b0;
        temp_yq_i <= 'b0;
    end else begin
        temp_yp_r <= xp_r_d1 + temp_ac_bd;
        temp_yp_i <= xp_i_d1 + temp_ad_bc;
        temp_yq_r <= xp_r_d1 - temp_ac_bd;
        temp_yq_i <= xp_i_d1 - temp_ad_bc;
    end
end

//output
    always_ff @( posedge clk,negedge rst_n ) begin
        if(!rst_n)begin
            yp_r <= 'b0;
            yp_i <= 'b0;
            yq_r <= 'b0;
            yq_i <= 'b0;
        end else begin
            yp_r <= temp_yp_r;
            yp_i <= temp_yp_i;
            yq_r <= temp_yq_r;
            yq_i <= temp_yq_i;
        end
    end


endmodule