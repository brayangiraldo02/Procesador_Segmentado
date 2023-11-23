module pcD (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] PCDdatain, // Entrada de datos
    output reg [31:0] PCDout
);

always @(negedge clk) begin
    if (reset == 1) begin
        PCDout <= 32'b00000000000000000000000000000000;
    end
    else begin
        PCDout <= PCDdatain;
    end
end

endmodule