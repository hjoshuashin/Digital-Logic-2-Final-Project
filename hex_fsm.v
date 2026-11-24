module hex_fsm(
    input CLK,
    input RST_N,
    input SQUARE_DONE,
    input [7:0] VALUE,

    output reg [3:0] HEX_LSB,
    output reg [3:0] HEX_MSB,
    output HEX_DONE
);

    reg [1:0] state;
    reg [1:0] next_state;

    assign HEX_DONE = (state == 2'b11);

    always @(*) begin

        next_state = state;

        case (state)

            2'b00: begin
                if (SQUARE_DONE)
                    next_state = 2'b01;
            end

            2'b01: begin
                next_state = 2'b10;
            end

            2'b10: begin
                next_state = 2'b11;
            end

            2'b11: begin
                if (!SQUARE_DONE)
                    next_state = 2'b00;
            end

            default: begin
                next_state = 2'b00;
            end

        endcase
    end

    always @(posedge CLK or negedge RST_N) begin

        if (!RST_N) begin
            state <= 2'b00;
            HEX_LSB <= 4'd0;
            HEX_MSB <= 4'd0;
        end

        else begin

            state <= next_state;

            if (state == 2'b01) begin
                HEX_LSB <= VALUE[3:0];
            end

            if (state == 2'b10) begin
                HEX_MSB <= VALUE[7:4];
            end

        end
    end
endmodule
