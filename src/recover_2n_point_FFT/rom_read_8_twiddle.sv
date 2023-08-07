`timescale 1ns/1ps
module rom_read_8_twiddle
(
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic [13:0]                     addr_i,
    output logic [63:0]                     data_o[7:0]
);

rom_recover_2n_twiddle u_rom_recover_2n_twiddle_0(
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .addr_i (addr_i ),
    .data_o (data_o[0] )
);

rom_recover_2n_twiddle u_rom_recover_2n_twiddle_1(
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .addr_i (addr_i + 14'd1 ),
    .data_o (data_o[1] )
);

rom_recover_2n_twiddle u_rom_recover_2n_twiddle_2(
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .addr_i (addr_i + 14'd2 ),
    .data_o (data_o[2] )
);

rom_recover_2n_twiddle u_rom_recover_2n_twiddle_3(
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .addr_i (addr_i + 14'd3 ),
    .data_o (data_o[3] )
);

rom_recover_2n_twiddle u_rom_recover_2n_twiddle_4(
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .addr_i (addr_i + 14'd4 ),
    .data_o (data_o[4] )
);

rom_recover_2n_twiddle u_rom_recover_2n_twiddle_5(
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .addr_i (addr_i + 14'd5 ),
    .data_o (data_o[5] )
);

rom_recover_2n_twiddle u_rom_recover_2n_twiddle_6(
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .addr_i (addr_i + 14'd6 ),
    .data_o (data_o[6] )
);

rom_recover_2n_twiddle u_rom_recover_2n_twiddle_7(
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .addr_i (addr_i + 14'd7 ),
    .data_o (data_o[7] )
);


endmodule