module instD (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] INSTDdatain, // Entrada de datos
    output reg [31:0] INSTDout
);

always @(negedge clk) begin
    if (reset == 1) begin
        INSTDout <= 32'b00000000000000000000000000000000;
    end
    else begin
        INSTDout <= INSTDdatain;
    end
end

endmodule