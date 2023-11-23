module rdWB (
    input wire clk,           // Señal de reloj
    input wire reset,         // Señal de reinicio
    input wire [4:0] RDWBdatain, // Entrada de datos
    output reg [4:0] RDWBout
);

always @(negedge clk) begin
    if (reset == 1) begin
        RDWBout <= 4'b0000;
    end
    else begin
        RDWBout <= RDWBdatain;
    end
end

endmodule