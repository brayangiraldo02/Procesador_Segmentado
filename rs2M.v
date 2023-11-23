module rs2M (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [31:0] RS2Mdatain, // Entrada de datos
    output reg [31:0] RS2Mout
);

always @(negedge clk) begin
    if (reset == 1) begin
        RS2Mout <= 32'b00000000000000000000000000000000;
    end
    else begin
        RS2Mout <= RS2Mdatain;
    end
end

endmodule