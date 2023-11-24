module cuX (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [6:0] CUXopcodeInput, // Entrada de opcode
    input wire [2:0] CUXfunc3Input,  // Entrada de func3
    input wire CUXsubsraInput,  // Entrada de subsra
    output reg [6:0] CUXopcode, // Salida de opcode
    output reg [2:0] CUXfunc3,   // Salida de func3
    output reg CUXsubsra  // Salida de subsra
);

always @(negedge clk) begin
    if (reset == 1) begin
        CUXopcode <= 7'b0000000;
        CUXfunc3 <= 3'b000;
        CUXsubsra <= 1'b0;
    end
    else begin
        CUXopcode <= CUXopcodeInput;
        CUXfunc3 <= CUXfunc3Input;
        CUXsubsra <= CUXsubsraInput;
    end
end

endmodule