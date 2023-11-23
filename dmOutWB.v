module dmOutWB (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] DMOUTWBdatain, // Entrada de datos
    output reg [31:0] DMOUTWBout
);

always @(negedge clk) begin
    if (reset == 1) begin
        DMOUTWBout <= 32'b00000000000000000000000000000000;
    end
    else begin
        DMOUTWBout <= DMOUTWBdatain;
    end
end

endmodule