module pcX (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] PCXdatain, // Entrada de datos
    output reg [31:0] PCXout
);

always @(negedge clk) begin
    if (reset == 1) begin
        PCXout <= 32'b00000000000000000000000000000000;
    end
    else begin
        PCXout <= PCXdatain;
    end
end

endmodule