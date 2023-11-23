module pcIncD (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] PCINCDdatain, // Entrada de datos
    output reg [31:0] PCINCDout
);

always @(negedge clk) begin
    if (reset == 1) begin
        PCINCDout <= 32'b00000000000000000000000000000000;
    end
    else begin
        PCINCDout <= PCINCDdatain;
    end
end

endmodule