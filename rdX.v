module rdX (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [4:0] RDXdatain, // Entrada de datos
    output reg [4:0] RDXout
);

always @(negedge clk) begin
    if (reset == 1) begin
        RDXout <= 4'b0000;
    end
    else begin
        RDXout <= RDXdatain;
    end
end

endmodule