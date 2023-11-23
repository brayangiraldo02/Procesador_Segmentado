module rs1X (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] RS1Xdatain, // Entrada de datos
    output reg [31:0] RS1Xout
);

always @(negedge clk) begin
    if (reset == 1) begin
        RS1Xout <= 32'b00000000000000000000000000000000;
    end
    else begin
        RS1Xout <= RS1Xdatain;
    end
end

endmodule