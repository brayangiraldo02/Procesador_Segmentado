module cuM (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [6:0] CUMopcodeInput, // Entrada de opcode
    input wire [2:0] CUMfunc3Input,  // Entrada de func3
    output reg [6:0] CUMopcode, // Salida de opcode
    output reg [2:0] CUMfunc3   // Salida de func3
);

always @(negedge clk) begin
    if (reset == 1) begin
        CUMopcode <= 7'b0000000;
        CUMfunc3 <= 3'b000;
    end
    else begin
        CUMopcode <= CUMopcodeInput;
        CUMfunc3 <= CUMfunc3Input;
    end
end

endmodule