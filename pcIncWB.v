module pcIncWB (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] PCINCWBdatain, // Entrada de datos
    output reg [31:0] PCINCWBout
);

always @(negedge clk) begin
    if (reset == 1) begin
        PCINCWBout <= 32'b00000000000000000000000000000000;
    end
    else begin
        PCINCWBout <= PCINCWBdatain;
    end
end

endmodule