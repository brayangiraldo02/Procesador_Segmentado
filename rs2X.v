module rs2X (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] RS2Xdatain, // Entrada de datos
    output reg [31:0] RS2Xout
);

always @(negedge clk) begin
    if (reset == 1) begin
        RS2Xout <= 32'b00000000000000000000000000000000;
    end
    else begin
        RS2Xout <= RS2Xdatain;
    end
end

endmodule