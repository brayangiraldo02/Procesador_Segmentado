module cuWB (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [6:0] CUWBopcodeInput, // Entrada de opcode
    output reg [6:0] CUWBopcode // Salida de opcode
);

always @(negedge clk) begin
    if (reset == 1) begin
        CUWBopcode <= 7'b0000000;
    end
    else begin
        CUWBopcode <= CUWBopcodeInput;
    end
end

endmodule