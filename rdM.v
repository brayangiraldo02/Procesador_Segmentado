module rdM (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [4:0] RDMdatain, // Entrada de datos
    output reg [4:0] RDMout
);

always @(negedge clk) begin
    if (reset == 1) begin
        RDMout <= 4'b0000;
    end
    else begin
        RDMout <= RDMdatain;
    end
end

endmodule