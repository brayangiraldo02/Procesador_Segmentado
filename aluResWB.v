module aluResWB (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] ALURESWBdatain, // Entrada de datos
    output reg [31:0] ALURESWBout
);

always @(negedge clk) begin
    if (reset == 1) begin
        ALURESWBout <= 32'b00000000000000000000000000000000;
    end
    else begin
        ALURESWBout <= ALURESWBdatain;
    end
end

endmodule