// `timescale 1ns/1ps
module rom_read_4_twiddle
(
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic                            valid,
    input  logic [10:0]                     addr_col1,
    input  logic [10:0]                     addr_col2,
    output logic [63:0]                     data_o_col1[3:0],
    output logic [63:0]                     data_o_col2[3:0]
);

rom_1_rfft_data64 u_rom_1_rfft_data64(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .valid       (valid       ),
    .addr_col1   (addr_col1   ),
    .addr_col2   (addr_col2   ),
    .data_o_col1 (data_o_col1[0] ),
    .data_o_col2 (data_o_col2[0] )
);

rom_2_rfft_data64 u_rom_2_rfft_data64(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .valid       (valid       ),
    .addr_col1   (addr_col1   ),
    .addr_col2   (addr_col2   ),
    .data_o_col1 (data_o_col1[1] ),
    .data_o_col2 (data_o_col2[1] )
);

rom_3_rfft_data64 u_rom_3_rfft_data64(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .valid       (valid       ),
    .addr_col1   (addr_col1   ),
    .addr_col2   (addr_col2   ),
    .data_o_col1 (data_o_col1[2] ),
    .data_o_col2 (data_o_col2[2] )
);

rom_4_rfft_data64 u_rom_4_rfft_data64(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .valid       (valid       ),
    .addr_col1   (addr_col1   ),
    .addr_col2   (addr_col2   ),
    .data_o_col1 (data_o_col1[3] ),
    .data_o_col2 (data_o_col2[3] )
);



endmodule