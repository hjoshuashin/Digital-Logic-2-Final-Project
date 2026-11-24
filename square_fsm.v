module square_fsm(
    input CLK,
    input RST_N,
    input GO,
    input [3:0] N,

    input [7:0] DATA_X,
    input [7:0] DATA_Y,
    input [7:0] DATA_Z,
    input [7:0] SUM,

    input HEX_DONE,

    output [7:0] ADDER_A,
    output [7:0] ADDER_B,

    output [3:0] WADDR,
    output WEN,
    output [7:0] DATA_IN,

    output SQUARE_DONE,
    output DONE,
    output reg [3:0] INPUT_LATCHED
);

    reg [3:0] state;
    reg [3:0] next_state;

    reg go_prev;

    wire start_pulse;

    assign start_pulse = GO & ~go_prev;

    assign ADDER_A =
        (state == 4'b0101) ? DATA_X :
        (state == 4'b0110) ? DATA_Z :
                             8'd0;

    assign ADDER_B =
        (state == 4'b0101) ? DATA_Y :
        (state == 4'b0110) ? 8'hFF :
                             8'd0;

    assign WADDR =
        (state == 4'b0001) ? 4'd0 :
        (state == 4'b0010 || state == 4'b0101) ? 4'd1 :
        (state == 4'b0011 || state == 4'b0110) ? 4'd2 :
                                                  4'd0;

    assign WEN =
        (state == 4'b0001) ||
        (state == 4'b0010) ||
        (state == 4'b0011) ||
        (state == 4'b0101) ||
        (state == 4'b0110);

    assign DATA_IN =
        (state == 4'b0001) ? {4'b0000, INPUT_LATCHED} :
        (state == 4'b0010) ? 8'd0 :
        (state == 4'b0011) ? DATA_Y :
        (state == 4'b0101 || state == 4'b0110) ? SUM :
                                                  8'd0;

    assign SQUARE_DONE =
        (state == 4'b0111) ||
        (state == 4'b1000) ||
        (state == 4'b1001);

    assign DONE =
        (state == 4'b1000) ||
        (state == 4'b1001);

    always @(*) begin

        next_state = state;

        case (state)

            4'b0000: begin
                if (start_pulse)
                    next_state = 4'b0001;
            end

            4'b0001: begin
                next_state = 4'b0010;
            end

            4'b0010: begin
                next_state = 4'b0011;
            end

            4'b0011: begin
                next_state = 4'b0100;
            end

            4'b0100: begin
                if (DATA_Z == 8'd0)
                    next_state = 4'b0111;
                else
                    next_state = 4'b0101;
            end

            4'b0101: begin
                next_state = 4'b0110;
            end

            4'b0110: begin
                next_state = 4'b0100;
            end

            4'b0111: begin
                if (HEX_DONE)
                    next_state = 4'b1000;
            end

            4'b1000: begin
                if (!GO)
                    next_state = 4'b1001;
            end

            4'b1001: begin
                if (start_pulse)
                    next_state = 4'b0001;
            end

            default: begin
                next_state = 4'b0000;
            end

        endcase
    end

    always @(posedge CLK or negedge RST_N) begin

        if (!RST_N) begin
            state <= 4'b0000;
            INPUT_LATCHED <= 4'd0;
            go_prev <= 1'b0;
        end

        else begin

            state <= next_state;
            go_prev <= GO;

            if ((state == 4'b0000 ||
                 state == 4'b1001) && start_pulse) begin

                INPUT_LATCHED <= N;

            end

        end
    end
endmodule
