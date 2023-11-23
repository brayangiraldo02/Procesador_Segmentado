module immX (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] IMMXdatain, // Entrada de datos
    output reg [31:0] IMMXout
);

always @(negedge clk) begin
    if (reset == 1) begin
        IMMXout <= 32'b00000000000000000000000000000000;
    end
    else begin
        IMMXout <= IMMXdatain;
    end
end

endmodule