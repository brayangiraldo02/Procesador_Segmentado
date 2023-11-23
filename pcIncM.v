module pcIncM (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] PCINCMdatain, // Entrada de datos
    output reg [31:0] PCINCMout
);

always @(negedge clk) begin
    if (reset == 1) begin
        PCINCMout <= 32'b00000000000000000000000000000000;
    end
    else begin
        PCINCMout <= PCINCMdatain;
    end
end

endmodule