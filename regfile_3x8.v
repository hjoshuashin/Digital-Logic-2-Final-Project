module regfile_3x8(
    input [2:0] WADDR,
    input WEN,
    input [7:0] DATA_IN,
    input CLK,
    input [2:0] XADDR,
    input [2:0] YADDR,
    input [2:0] ZADDR,
    output [7:0] DATA_X,
    output [7:0] DATA_Y,
    output [7:0] DATA_Z
);

    wire [7:0] ACT;
    wire [7:0] RQ0, RQ1, RQ2;

    dec3to8 dec(WADDR, WEN, ACT);

    reg_8b r0(ACT[0], DATA_IN, CLK, 1, 1, RQ0);
    reg_8b r1(ACT[1], DATA_IN, CLK, 1, 1, RQ1);
    reg_8b r2(ACT[2], DATA_IN, CLK, 1, 1, RQ2);

    mux3to1_8b mux_x(XADDR, RQ0, RQ1, RQ2, DATA_X);
    mux3to1_8b mux_y(YADDR, RQ0, RQ1, RQ2, DATA_Y);
    mux3to1_8b mux_z(ZADDR, RQ0, RQ1, RQ2, DATA_Z);
endmodule
