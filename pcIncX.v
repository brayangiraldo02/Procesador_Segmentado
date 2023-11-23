module pcIncX (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] PCINCXdatain, // Entrada de datos
    output reg [31:0] PCINCXout
);

always @(negedge clk) begin
    if (reset == 1) begin
        PCINCXout <= 32'b00000000000000000000000000000000;
    end
    else begin
        PCINCXout <= PCINCXdatain;
    end
end

endmodule