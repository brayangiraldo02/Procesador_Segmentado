`include "alu.v"
`include "dm.v"
`include "imm.v"
`include "instructionmemory.v"
`include "mux_alu_sum.v"
`include "mux_dm_alu_sum.v"
`include "mux_reg1_pc.v"
`include "mux_reg2_imm.v"
`include "pc.v"
`include "register_file.v"
`include "sum.v"
`include "Branch.v"
`include "pcD.v"
`include "pcIncD.v"
`include "instD.v"
`include "pcX.v"
`include "cuX.v"
`include "pcIncX.v"
`include "rs1X.v"
`include "rs2X.v"
`include "immX.v"
`include "rdX.v"
`include "pcIncM.v"
`include "cuM.v"
`include "aluResM.v"
`include "rs2M.v"
`include "rdM.v"
`include "pcIncWB.v"
`include "cuWB.v"
`include "dmOutWB.v"
`include "aluResWB.v"
`include "rdWB.v"

module cu(
    input wire clk,
    input wire reset
    
);

    wire [31:0] IMinstruction;
    reg [6:0] CUopcode;
    wire [31:0] ALUresult;
    wire [31:0] PCout;
    wire [31:0] SUMout;
    wire [31:0] MUX1out;
    wire [31:0] RFdata1;
    wire [31:0] RFdata2;
    wire [31:0] IMMout;
    wire [31:0] MUX2out;
    wire [31:0] MUX3out;
    wire [31:0] DMDataOut;
    wire [31:0] MUX4out;
    wire branch_next;

    // Etapa de Decode 
    wire [31:0] PCDout;
    wire [31:0] INSTDout;
    wire [31:0] PCINCDout;

    // Etapa de Execute
    wire [31:0] PCXout;
    wire [31:0] PCINCXout;
    wire [31:0] RS1Xout;
    wire [31:0] RS2Xout;
    wire [31:0] IMMXout;
    wire [4:0] RDXout;
    wire [6:0] CUXopcode;
    wire [2:0] CUXfunc3;
    wire CUXsubsra;

    //Etapa de Memory
    wire [31:0] PCINCMout;
    wire [31:0] ALURESMout;
    wire [31:0] RS2Mout;
    wire [4:0] RDMout;
    wire [6:0] CUMopcode;
    wire [2:0] CUMfunc3;

    //Etapa de Write Back
    wire [31:0] PCINCWBout;
    wire [31:0] DMOUTWBout;
    wire [31:0] ALURESWBout;
    wire [4:0] RDWBout;
    wire [6:0] CUWBopcode;

    reg [1:0] MUX4control;
    reg MUX2control;
    reg MUX3control;
    reg [4:0] CUrs1;
    reg [4:0] CUrs2;
    reg [4:0] CUrd;
    reg [2:0] CUfunc3;
    reg [4:0] BRopcode;
    reg CUrenable;
    reg CUdenable;
    reg CUsubsra;

    //Instanciación de los módulos

    //MUX alu and sum
    mux_alu_sum mux1(
        .MUX1alu(ALUresult), //Entrada del resultado de la ALU
        .MUX1sum(SUMout), //Entrada del contador de programa
        .MUX1control(branch_next), //Entrada de señal de control del mux 1 que indica si se debe saltar o no
        .MUX1out(MUX1out) //Salida del MUX 1
    );

    //Program Counter
    pc pc(
        .PCout(PCout), //Salida del contador de programa
        .PCdatain(MUX1out), //Entrada del número de instrucción
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    ); 

    //SUM
    sum sum(
        .SUMdatain(PCout), //Entrada del contador de programa
        .SUMout(SUMout) //Salida de la suma
    );

    //Instruction memory
    instructionmemory im(
        .IMaddress(PCout), //Entrada del contador de programa
        .IMinstruction(IMinstruction) //Salida de la instrucción
    );

    //Register file
    register_file rf(
        .RFr1(CUrs1), //Entrada del registro 1
        .RFr2(CUrs2), //Entrada del registro 2
        .RFrd(RDWBout), //Entrada del registro de destino
        .RFwr(MUX4out), //Entrada de los datos a escribir del mux 4
        .RFwenable(CUrenable), //Entrada de la señal de escritura
        .clk(clk), //Entrada de la señal de reloj 
        .RFdata1(RFdata1), //Salida del dato 1
        .RFdata2(RFdata2) //Salida del dato 2
    );

    //Unidad de inmediatos
    imm imm(
        .IMMins(INSTDout), //Entrada de la instrucción
        .IMMout(IMMout) //Salida del inmediato
    );

    //MUX pc and reg1
    mux_reg1_pc mux2(
        .MUX2pc(PCXout), //Entrada del contador de programa
        .MUX2reg1(RS1Xout), //Entrada del dato 1 del RegisterFile
        .MUX2control(MUX2control), //Entrada de la señal de control de la operación del MUX 2
        .MUX2out(MUX2out) //Salida del MUX 2
    );

    //MUX reg2 and imm
    mux_reg2_imm mux3(
        .MUX3reg2(RS2Xout), //Entrada del dato 2 del RegisterFile
        .MUX3imm(IMMXout), //Entrada del inmediato
        .MUX3control(MUX3control), //Entrada de la señal de control de la operación del MUX 3
        .MUX3out(MUX3out) //Salida del MUX 3
    );

    //BRANCH
    Branch branch(
        .BRreg1(RS1Xout), //Entrada del dato 1 del RegisterFile
        .BRreg2(RS2Xout), //Entrada del dato 2 del RegisterFile
        .BRopcode(BRopcode), //Entrada del opcode
        .branch_next(branch_next) //Salida de la señal de salto
    );  
    //ALU
    alu alu(
        .ALUop1(MUX2out), //Entrada del operando 1 del MUX 2
        .ALUop2(MUX3out), //Entrada del operando 2 del MUX 3
        .ALUfunc3(CUXfunc3), //Entrada de la señal de control func3 de la operación de la ALU
        .ALUsubsra(CUXsubsra), //Entrada de la señal de control func7 de la operación de la ALU
        .ALUresult(ALUresult) //Salida del resultado de la ALU
    );

    //Data memory
    DataMemory dm(
        .DMAddress(ALURESMout), //Entrada de la dirección de memoria
        .DMDataIn(RS2Mout), //Entrada de los datos a escribir
        .DMCtrl(CUMfunc3), //Entrada de la señal de control de la DM
        .DMWrEnable(CUdenable), //Entrada de la señal de escritura habilitada
        .DMDataOut(DMDataOut) //Salida de los datos leídos de la DM
    );

    //MUX alu and dm and sum
    mux_dm_alu_sum mux4(
        .MUX4alu(ALURESWBout), //Entrada del resultado de la ALU
        .MUX4dm(DMOUTWBout), //Entrada de los datos leídos de la DM
        .MUX4sum(PCINCWBout), //Entrada del contador de programa
        .MUX4control(MUX4control), //Entrada de la señal de control de la operación del MUX 4
        .MUX4out(MUX4out) //Salida del MUX 4
    );

    //Etapa de Decode

    //Program Counter Decode
    pcD pcD(
        .PCDout(PCDout), //Salida del contador de programa
        .PCDdatain(PCout), //Entrada del contador de programa
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Instruction memory Decode
    instD instD(
        .INSTDout(INSTDout), //Salida de la instrucción
        .INSTDdatain(IMinstruction), //Entrada de la instrucción
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Program Counter Increment Decode
    pcIncD pcIncD(
        .PCINCDout(PCINCDout), //Salida del contador de programa
        .PCINCDdatain(PCout), //Entrada del contador de programa
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Etapa de Execute

    //Program Counter Execute
    pcX pcX(
        .PCXout(PCXout), //Salida del contador de programa
        .PCXdatain(PCDout), //Entrada del contador de programa
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Program Counter Increment Execute
    pcIncX pcIncX(
        .PCINCXout(PCINCXout), //Salida del contador de programa
        .PCINCXdatain(PCINCDout), //Entrada del contador de programa
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Register 1 Execute
    rs1X rs1X(
        .RS1Xout(RS1Xout), //Salida del registro 1
        .RS1Xdatain(RFdata1), //Entrada del dato 1 del RegisterFile
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Register 2 Execute
    rs2X rs2X(
        .RS2Xout(RS2Xout), //Salida del registro 2
        .RS2Xdatain(RFdata2), //Entrada del dato 2 del RegisterFile
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Immediate Execute
    immX immX(
        .IMMXout(IMMXout), //Salida del inmediato
        .IMMXdatain(IMMout), //Entrada de la instrucción
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Register destination Execute
    rdX rdX(
        .RDXout(RDXout), //Salida del registro de destino
        .RDXdatain(CUrd), //Entrada del registro de destino
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    //Control unit Execute
    cuX cuX(
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset), //Entrada de la señal de reinicio
        .CUXopcodeInput(CUopcode), //Entrada del opcode
        .CUXfunc3Input(CUfunc3), //Entrada de func3
        .CUXsubsraInput(CUsubsra), //Entrada de subsra
        .CUXopcode(CUXopcode), //Salida del opcode
        .CUXfunc3(CUXfunc3), //Salida de func3
        .CUXsubsra(CUXsubsra) //Salida de subsra
    );

    // Etapa de Memory

    //Program Counter Increment Memory
    pcIncM pcIncM(
        .PCINCMout(PCINCMout), //Salida del contador de programa
        .PCINCMdatain(PCINCXout), //Entrada del contador de programa
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    aluResM aluResM(
        .ALURESMout(ALURESMout), //Salida del resultado de la ALU
        .ALURESMdatain(ALUresult), //Entrada del resultado de la ALU
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio
    );

    rs2M rs2M(
        .RS2Mout(RS2Mout), //Salida del registro 2
        .RS2Mdatain(RS2Xout), //Entrada del dato 2 del RegisterFile
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio 
    );

    rdM rdM(
        .RDMout(RDMout), //Salida del registro de destino
        .RDMdatain(RDXout), //Entrada del registro de destino
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio 
    );

    cuM cuM(
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset), //Entrada de la señal de reinicio
        .CUMopcodeInput(CUXopcode), //Entrada del opcode
        .CUMfunc3Input(CUXfunc3), //Entrada de func3
        .CUMopcode(CUMopcode), //Salida del opcode
        .CUMfunc3(CUMfunc3) //Salida de func3
    );

    // Etapa de Write Back

    //Program Counter Increment Write Back
    pcIncWB pcIncWB(
        .PCINCWBout(PCINCWBout), //Salida del contador de programa
        .PCINCWBdatain(PCINCMout), //Entrada del contador de programa
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio 
    );

    //Data memory Write Back
    dmOutWB dmOutWB(
        .DMOUTWBout(DMOUTWBout), //Salida de los datos leídos de la DM
        .DMOUTWBdatain(DMDataOut), //Entrada de los datos leídos de la DM
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio 
    );

    //ALU Write Back
    aluResWB aluResWB(
        .ALURESWBout(ALURESWBout), //Salida del resultado de la ALU
        .ALURESWBdatain(ALURESMout), //Entrada del resultado de la ALU
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio 
    );

    //Register destination Write Back
    rdWB rdWB(
        .RDWBout(RDWBout), //Salida del registro de destino
        .RDWBdatain(RDMout), //Entrada del registro de destino
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset) //Entrada de la señal de reinicio 
    );

    cuWB cuWB(
        .clk(clk), //Entrada de la señal de reloj
        .reset(reset), //Entrada de la señal de reinicio
        .CUWBopcodeInput(CUMopcode), //Entrada del opcode
        .CUWBopcode(CUWBopcode) //Salida del opcode
    );

    //Always para la etapa del Decode
    always @(posedge clk) begin
        CUopcode = INSTDout[6:0];
        CUfunc3 = INSTDout[14:12];
        CUsubsra = INSTDout[30];
        CUrd = INSTDout[11:7];

        case(CUopcode)
            7'b0110011: begin //INSTRUCCION TIPO R
                CUrs1 = INSTDout[19:15];
                CUrs2 = INSTDout[24:20];
            end

            7'b0010011: begin //INSTRUCCION TIPO I      
                CUrs1 = INSTDout[19:15];
                CUrs2 = 5'b0;
            end

            7'b0000011: begin          //INSTRUCCION TIPO I (OPCODE = 0000011)
                CUrs1 = INSTDout[19:15];
                CUrs2 = 5'b0;
            end

            7'b0100011: begin       //INSTRUCCION TIPO S (OPCODE = 0100011)
                CUrs1 = INSTDout[19:15];
                CUrs2 = INSTDout[24:20];
            end
            
            7'b1100011: begin       //INSTRUCCION TIPO SB (OPCODE = 1100011)
                CUrs1 = INSTDout[19:15];
                CUrs2 = INSTDout[24:20];
            end

            7'b1100111: begin       //INSTRUCCION TIPO JALR (OPCODE = 1100111)
                CUrs1 = INSTDout[19:15];
                CUrs2 = 5'b0;
            end

            7'b1101111: begin       //INSTRUCCION TIPO JAL(OPCODE = 1101111)
                CUrs1 = 5'b0;
                CUrs2 = 5'b0;
            end

            7'b0110111: begin       //INSTRUCCION TIPO U LUI (OPCODE = 0110111)
                CUrs1 = 5'b0;
                CUrs2 = 5'b0;
            end

            7'b0010111: begin       //INSTRUCCION TIPO U AUIPC (OPCODE = 0010111)
                CUrs1 = 5'b0;
                CUrs2 = 5'b0;
            end

            7'b1100111: begin      //INSTRUCCION TIPO I (OPCODE = 1100111)
                CUrs1 = INSTDout[19:15];
                CUrs2 = 5'b0;
            end

            7'b1101111: begin      //INSTRUCCION TIPO J (OPCODE = 1101111)
                CUrs1 = 5'b0;
                CUrs2 = 5'b0;
            end
        endcase
    end

    //Always para la etapa del Execute
    always @(posedge clk) begin
        case(CUXopcode)
            7'b0110011: begin //INSTRUCCION TIPO R
                BRopcode = 5'b11111;
                MUX2control = 1'b1;
                MUX3control = 1'b0;
            end

            7'b0010011: begin //INSTRUCCION TIPO I      
                BRopcode = 5'b11111;
                MUX2control = 1'b1;
                MUX3control = 1'b1;
            end

            7'b0000011: begin          //INSTRUCCION TIPO I (OPCODE = 0000011)
                BRopcode = 5'b11111;
                MUX2control = 1'b1;
                MUX3control = 1'b1;
            end

            7'b0100011: begin       //INSTRUCCION TIPO S (OPCODE = 0100011)
                BRopcode = 5'b11111;
                MUX2control = 1'b1;
                MUX3control = 1'b1;
            end
            
            7'b1100011: begin       //INSTRUCCION TIPO SB (OPCODE = 1100011)
                BRopcode = CUXfunc3;
                MUX2control = 1'b0;
                MUX3control = 1'b1;
            end

            7'b1100111: begin       //INSTRUCCION TIPO JALR (OPCODE = 1100111)
                BRopcode = 5'b01111;
                MUX2control = 1'b1;
                MUX3control = 1'b1;
            end

            7'b1101111: begin       //INSTRUCCION TIPO JAL(OPCODE = 1101111)
                BRopcode = 5'b01111;
                MUX2control = 1'b0;
                MUX3control = 1'b1;
            end

            7'b0110111: begin       //INSTRUCCION TIPO U LUI (OPCODE = 0110111)
                BRopcode = 5'b11111;
                MUX2control = 1'b0;
                MUX3control = 1'b1;
            end

            7'b0010111: begin       //INSTRUCCION TIPO U AUIPC (OPCODE = 0010111)
                BRopcode = 5'b11111;
                MUX2control = 1'b0;
                MUX3control = 1'b1;
            end

            7'b1100111: begin      //INSTRUCCION TIPO I (OPCODE = 1100111)
                BRopcode = 5'b01111;
                MUX2control = 1'b1;
                MUX3control = 1'b1;
            end

            7'b1101111: begin      //INSTRUCCION TIPO J (OPCODE = 1101111)
                BRopcode = 5'b01111;
                MUX2control = 1'b0;
                MUX3control = 1'b1;
            end
        endcase
    end

    //Always para la etapa de Memory
    always @(posedge clk) begin
        case(CUMopcode)
            7'b0110011: begin //INSTRUCCION TIPO R
                CUdenable = 1'b0;
            end

            7'b0010011: begin //INSTRUCCION TIPO I      
                CUdenable = 1'b0;
            end

            7'b0000011: begin          //INSTRUCCION TIPO I (OPCODE = 0000011)
                CUdenable = 1'b0;
            end

            7'b0100011: begin       //INSTRUCCION TIPO S (OPCODE = 0100011)
                CUdenable = 1'b1;
            end
            
            7'b1100011: begin       //INSTRUCCION TIPO SB (OPCODE = 1100011)
                CUdenable = 1'b0;
            end

            7'b1100111: begin       //INSTRUCCION TIPO JALR (OPCODE = 1100111)
                CUdenable = 1'b0;
            end

            7'b1101111: begin       //INSTRUCCION TIPO JAL(OPCODE = 1101111)
                CUdenable = 1'b0;
            end

            7'b0110111: begin       //INSTRUCCION TIPO U LUI (OPCODE = 0110111)
                CUdenable = 1'b0;
            end

            7'b0010111: begin       //INSTRUCCION TIPO U AUIPC (OPCODE = 0010111)
                CUdenable = 1'b0;
            end

            7'b1100111: begin      //INSTRUCCION TIPO I (OPCODE = 1100111)
                CUdenable = 1'b0;
            end

            7'b1101111: begin      //INSTRUCCION TIPO J (OPCODE = 1101111)
                CUdenable = 1'b0;
            end

            7'b0000000: begin
                CUdenable = 1'b0;
        end
        endcase
    end
    
    //Always para la etapa de Write Back
    always @(posedge clk) begin
        case(CUWBopcode)
            7'b0110011: begin //INSTRUCCION TIPO R
                CUrenable = 1'b1;
                MUX4control = 2'b01;
            end

            7'b0010011: begin //INSTRUCCION TIPO I      
                CUrenable = 1'b1;
                MUX4control = 2'b01;
            end

            7'b0000011: begin          //INSTRUCCION TIPO I (OPCODE = 0000011)
                CUrenable = 1'b1;
                MUX4control = 2'b00;
            end

            7'b0100011: begin       //INSTRUCCION TIPO S (OPCODE = 0100011)
                CUrenable = 1'b0;
                MUX4control = 2'b00;
            end
            
            7'b1100011: begin       //INSTRUCCION TIPO SB (OPCODE = 1100011)
                CUrenable = 1'b0;
                MUX4control = 2'b01;
            end

            7'b1100111: begin       //INSTRUCCION TIPO JALR (OPCODE = 1100111)
                CUrenable = 1'b1;
                MUX4control = 2'b10;
            end

            7'b1101111: begin       //INSTRUCCION TIPO JAL(OPCODE = 1101111)
                CUrenable = 1'b1;
                MUX4control = 2'b10;
            end

            7'b0110111: begin       //INSTRUCCION TIPO U LUI (OPCODE = 0110111)
                CUrenable = 1'b1;
                MUX4control = 2'b01;
            end

            7'b0010111: begin       //INSTRUCCION TIPO U AUIPC (OPCODE = 0010111)
                CUrenable = 1'b1;
                MUX4control = 2'b01;
            end

            7'b1100111: begin      //INSTRUCCION TIPO I (OPCODE = 1100111)
                CUrenable = 1'b1;
                MUX4control = 2'b10;
            end

            7'b1101111: begin      //INSTRUCCION TIPO J (OPCODE = 1101111)
                CUrenable = 1'b1;
                MUX4control = 2'b10;
            end

            7'b0000000: begin
                CUrenable = 1'b0;
        end
        endcase
    end
    //Control unit
//     always @(posedge clk) begin        // Cambiar a sensibilidad de flanco de subida
//     CUopcode = INSTDout[6:0];
//     case(CUopcode)
//         7'b0110011: begin          //INSTRUCCION TIPO R (OPCODE = 0110011)
//             CUrs1 = INSTDout[19:15];
//             CUrs2 = INSTDout[24:20];
//             CUrd = INSTDout[11:7];
//             CUfunc3 = INSTDout[14:12];
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = INSTDout[30];
//             MUX2control = 1'b1;
//             MUX3control = 1'b0;
//             MUX4control = 2'b01;
//             BRopcode = 5'b11111;
//         end

//         7'b0010011: begin          //INSTRUCCION TIPO I (OPCODE = 0010011)
//             CUrs1 = INSTDout[19:15];
//             CUrs2 = 5'b0;
//             CUrd = INSTDout[11:7];
//             CUfunc3 = INSTDout[14:12];
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b1;
//             MUX3control = 1'b1;
//             MUX4control = 2'b01;
//             BRopcode = 5'b11111;
//         end

//         7'b0000011: begin          //INSTRUCCION TIPO I (OPCODE = 0000011)
//             CUrs1 = INSTDout[19:15];
//             CUrs2 = 5'b0;
//             CUrd = INSTDout[11:7];
//             CUfunc3 = INSTDout[14:12];
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b1;
//             MUX3control = 1'b1;
//             MUX4control = 2'b00;
//             BRopcode = 5'b11111;
//         end

//         7'b0100011: begin       //INSTRUCCION TIPO S (OPCODE = 0100011)
//             CUrs1 = INSTDout[19:15];
//             CUrs2 = INSTDout[24:20];
//             CUrd = 5'b0;
//             CUfunc3 = INSTDout[14:12];
//             CUrenable = 1'b0;
//             CUdenable = 1'b1;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b1;
//             MUX3control = 1'b1;
//             MUX4control = 2'b00;
//             BRopcode = 5'b11111;
//         end

//         7'b1100011: begin       //INSTRUCCION TIPO SB (OPCODE = 1100011)
//             CUrs1 = INSTDout[19:15];
//             CUrs2 = INSTDout[24:20];
//             CUrd = 5'b0;
//             CUfunc3 = INSTDout[14:12];
//             CUrenable = 1'b0;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b0;
//             MUX3control = 1'b1;
//             MUX4control = 2'b01;
//             BRopcode = INSTDout[14:12];
//             // case (CUfunc3)
//             //     3'b000: begin
//             //         BRopcode = 5'b00000;
//             //     end
//             //     3'b001: begin
//             //         BRopcode = 5'b00001;
//             //     end
//             //     3'b100: begin
//             //         BRopcode = 5'b00100;
//             //     end
//             //     3'b101: begin
//             //         BRopcode = 5'b00101;
//             //     end
//             //     3'b110: begin
//             //         BRopcode = 5'b00110;
//             //     end
//             //     3'b111: begin
//             //         BRopcode = 5'b00111;
//             //     end
//             // endcase
//         end
//         7'b1100111: begin       //INSTRUCCION TIPO JALR (OPCODE = 1100111)
//             CUrs1 = INSTDout[19:15];
//             CUrs2 = 5'b0;
//             CUrd = INSTDout[11:7];
//             CUfunc3 = 3'b0;    
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b1;
//             MUX3control = 1'b1;
//             MUX4control = 2'b10;
//             BRopcode = 5'b01111;
//         end
//         7'b1101111: begin       //INSTRUCCION TIPO JAL(OPCODE = 1101111)
//             CUrs1 = 5'b0;
//             CUrs2 = 5'b0;
//             CUrd = INSTDout[11:7];
//             CUfunc3 = 3'b0;    
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b0;
//             MUX3control = 1'b1;
//             MUX4control = 2'b10;
//             BRopcode = 5'b01111;
//         end
//         7'b0110111: begin       //INSTRUCCION TIPO U LUI (OPCODE = 0110111)
//             CUrs1 = 5'b0;
//             CUrs2 = 5'b0;
//             CUrd = INSTDout[11:7];
//             CUfunc3 = 3'b0;    
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b0;
//             MUX3control = 1'b1;
//             MUX4control = 2'b01;
//             BRopcode = 5'b11111;
//         end
//         7'b0010111: begin       //INSTRUCCION TIPO U AUIPC (OPCODE = 0010111)
//             CUrs1 = 5'b0;
//             CUrs2 = 5'b0;
//             CUrd = INSTDout[11:7];
//             CUfunc3 = 3'b0;    
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b0;
//             MUX3control = 1'b1;
//             MUX4control = 2'b01;
//             BRopcode = 5'b11111;
//         end

//         7'b1100111: begin      //INSTRUCCION TIPO I (OPCODE = 1100111)
//             CUrs1 = INSTDout[19:15];
//             CUrs2 = 5'b0;
//             CUrd = INSTDout[11:7];
//             CUfunc3 = INSTDout[14:12];
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b1;
//             MUX3control = 1'b1;
//             MUX4control = 2'b10;
//             BRopcode = 5'b01111;
//         end

//         7'b1101111: begin      //INSTRUCCION TIPO J (OPCODE = 1101111)
//             CUrs1 = 5'b0;
//             CUrs2 = 5'b0;
//             CUrd = INSTDout[11:7];
//             CUfunc3 = 3'b0;
//             CUrenable = 1'b1;
//             CUdenable = 1'b0;
//             CUsubsra = 1'b0;
//             MUX2control = 1'b0;
//             MUX3control = 1'b1;
//             MUX4control = 2'b10;
//             BRopcode = 5'b01111;
//         end

//         7'b0000000: begin
//             CUrenable = 1'b0;
//             CUdenable = 1'b0;
//         end
//     endcase 
// end

endmodule