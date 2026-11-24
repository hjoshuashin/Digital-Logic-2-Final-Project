module controller_fsm(
    input [3:0] N,
    input GO,
    input RST_N,
    input BOARDCLK,

    output A, B, C, D, E, F, G,
    output [3:0] ONECOLD,
    output DONE
);

    wire [7:0] DATA_X;
    wire [7:0] DATA_Y;
    wire [7:0] DATA_Z;

    wire [7:0] SUM;
    wire COUT;

    wire [3:0] WADDR;
    wire [7:0] DATA_IN;
    wire WEN;

    wire [7:0] adder_a;
    wire [7:0] adder_b;

    wire SQUARE_DONE;
    wire HEX_DONE;

    wire [3:0] input_latched;
    wire [3:0] hex_lo;
    wire [3:0] hex_hi;

    wire [15:0] DISPLAY_DATA;

    regfile_3x8 registers(
        .WADDR(WADDR[2:0]),
        .WEN(WEN),
        .DATA_IN(DATA_IN),
        .CLK(BOARDCLK),

        .XADDR(3'd1),
        .YADDR(3'd0),
        .ZADDR(3'd2),

        .DATA_X(DATA_X),
        .DATA_Y(DATA_Y),
        .DATA_Z(DATA_Z)
    );

    RCA add_unit(
        .A(adder_a),
        .B(adder_b),
        .CIN(1'b0),
        .SUM(SUM),
        .COUT(COUT)
    );

    square_fsm square_unit(
        .CLK(BOARDCLK),
        .RST_N(RST_N),
        .GO(GO),
        .N(N),

        .DATA_X(DATA_X),
        .DATA_Y(DATA_Y),
        .DATA_Z(DATA_Z),
        .SUM(SUM),

        .HEX_DONE(HEX_DONE),

        .ADDER_A(adder_a),
        .ADDER_B(adder_b),

        .WADDR(WADDR),
        .WEN(WEN),
        .DATA_IN(DATA_IN),

        .SQUARE_DONE(SQUARE_DONE),
        .DONE(DONE),
        .INPUT_LATCHED(input_latched)
    );

    hex_fsm hex_unit(
        .CLK(BOARDCLK),
        .RST_N(RST_N),
        .SQUARE_DONE(SQUARE_DONE),
        .VALUE(DATA_X),

        .HEX_LO(hex_lo),
        .HEX_HI(hex_hi),
        .HEX_DONE(HEX_DONE)
    );

    assign DISPLAY_DATA = {
        input_latched,
        4'h0,
        hex_hi,
        hex_lo
    };

    wire [6:0] segments;
    wire [3:0] ONECOLD_RAW;

    illusion display(
        .BOARDCLK(BOARDCLK),
        .DATA(DISPLAY_DATA),
        .SEGMENTS(segments),
        .ONECOLD(ONECOLD_RAW)
    );

    assign {A, B, C, D, E, F, G} = segments;

endmodule
