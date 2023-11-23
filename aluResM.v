module aluResM (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] ALURESMdatain, // Entrada de datos
    output reg [31:0] ALURESMout
);

always @(negedge clk) begin
    if (reset == 1) begin
        ALURESMout <= 32'b00000000000000000000000000000000;
    end
    else begin
        ALURESMout <= ALURESMdatain;
    end
end

endmodule