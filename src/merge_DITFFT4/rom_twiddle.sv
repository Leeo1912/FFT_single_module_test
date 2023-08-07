`timescale 1ns/1ps
module rom_twiddle
(
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic                            valid,
    input  logic [10:0]                     addr_i,
    output logic [255:0]               data_o[2:0]
);

rom_1 u_rom_1(
    .clk            (clk),
    .rst_n          (rst_n),
    .valid          (valid),
    .addr_i         (addr_i),
    .data_o         (data_o[0])
);

rom_2 u_rom_2(
    .clk            (clk),
    .rst_n          (rst_n),
    .valid          (valid),
    .addr_i         (addr_i),
    .data_o         (data_o[1])
);

rom_3 u_rom_3(
    .clk            (clk),
    .rst_n          (rst_n),
    .valid          (valid),
    .addr_i         (addr_i),
    .data_o         (data_o[2])
);

endmodule