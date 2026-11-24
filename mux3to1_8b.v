module mux3to1_8b(
    input [2:0] S,
    input [7:0] I0,
    input [7:0] I1,
    input [7:0] I2,
    output reg [7:0] Y
);

    always @(*) begin
        case (S)
            3'b000: Y = I0;
            3'b001: Y = I1;
            3'b010: Y = I2;
            default: Y = 8'b00000000;
        endcase
    end
endmodule
