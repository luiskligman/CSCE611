module controlunit (
    input logic stall_EX,
    input logic [2:0] funct3_EX,
    input logic [6:0] opcode_EX, funct7_EX,
    input logic [11:0] csr,
    input logic [31:0] R_EX,
    output logic alusrc_EX, GPIO_we_EX, regwrite_EX, stall_FETCH,
    output logic [1:0] regsel_EX, pcsrc_EX,
    output logic [3:0] aluop_EX );

    always_comb begin
        alusrc_EX = 1'b0;
        GPIO_we_EX = 1'b0;
        regwrite_EX = 1'b0;
        regsel_EX = 2'b00;
        aluop_EX = 4'b0000;
        pcsrc_EX = 2'b00;
        stall_FETCH = 1'b0;
        if (!stall_EX) begin
            //R-Type
            if (opcode_EX == 7'b0110011) begin 
                if (funct3_EX == 3'b000) begin
                    if (funct7_EX == 7'b0000000) begin // add 
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b0011;
                    end
                    if (funct7_EX == 7'b0000001) begin // mul
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b0101;
                    end
                    if (funct7_EX == 7'b0100000) begin // sub
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b0100;
                    end
                end
                if (funct3_EX == 3'b001) begin
                    if (funct7_EX == 7'b0000000) begin // sll
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b1000;
                    end
                    if (funct7_EX == 7'b0000001) begin // mulh
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b0110;
                    end
                end
                if (funct3_EX == 3'b010) begin
                    if (funct7_EX == 7'b0000000) begin // slt
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b1100;
                    end
                end
                if (funct3_EX == 3'b011) begin
                    if (funct7_EX == 7'b0000000) begin // sltu
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b1101;
                    end
                    if (funct7_EX == 7'b0000001) begin // mulhu
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b0111;
                    end
                end
                if (funct3_EX == 3'b100) begin
                    if (funct7_EX == 7'b0000000) begin // xor
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b0010;
                    end
                end
                if (funct3_EX == 3'b101) begin
                    if (funct7_EX == 7'b0000000) begin // srl
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b1001;
                    end
                    if (funct7_EX == 7'b0100000) begin // sra
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b1010;
                    end
                end
                if (funct3_EX == 3'b110) begin
                    if (funct7_EX == 7'b0000000) begin // or
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b0001;
                    end
                end
                if (funct3_EX == 3'b111) begin
                    if (funct7_EX == 7'b0000000) begin // and
                        alusrc_EX = 1'b0;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b0000;
                    end
                end
            end
            //I-Type
            if (opcode_EX == 7'b0010011) begin 
                if (funct3_EX == 3'b000) begin // addi
                    alusrc_EX = 1'b1;
                    GPIO_we_EX = 1'b0;
                    regwrite_EX = 1'b1;
                    regsel_EX = 2'b10;
                    aluop_EX = 4'b0011;
                end
                if (funct3_EX == 3'b001) begin // slli
                    alusrc_EX = 1'b1;
                    GPIO_we_EX = 1'b0;
                    regwrite_EX = 1'b1;
                    regsel_EX = 2'b10;
                    aluop_EX = 4'b1000;
                end
                if (funct3_EX == 3'b100) begin // xori
                    alusrc_EX = 1'b1;
                    GPIO_we_EX = 1'b0;
                    regwrite_EX = 1'b1;
                    regsel_EX = 2'b10;
                    aluop_EX = 4'b0010;
                end
                if (funct3_EX == 3'b101) begin
                    if (funct7_EX == 7'b0000000) begin // srli
                        alusrc_EX = 1'b1;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b1001;
                    end
                    if (funct7_EX == 7'b0100000) begin // srai
                        alusrc_EX = 1'b1;
                        GPIO_we_EX = 1'b0;
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b10;
                        aluop_EX = 4'b1010;
                    end
                end
                if (funct3_EX == 3'b110) begin // ori
                    alusrc_EX = 1'b1;
                    GPIO_we_EX = 1'b0;
                    regwrite_EX = 1'b1;
                    regsel_EX = 2'b10;
                    aluop_EX = 4'b0001;
                end
                if (funct3_EX == 3'b111) begin // andi
                    alusrc_EX = 1'b1;
                    GPIO_we_EX = 1'b0;
                    regwrite_EX = 1'b1;
                    regsel_EX = 2'b10;
                    aluop_EX = 4'b0000;
                end
            end
            //U-type
            if (opcode_EX == 7'b0110111) begin // lui
                alusrc_EX = 1'bX;
                GPIO_we_EX = 1'b0;
                regwrite_EX = 1'b1;
                regsel_EX = 2'b01;
                aluop_EX = 4'bX;
            end
            //CSSRW
            if (opcode_EX == 7'b1110011) begin 
                if (funct3_EX == 3'b001) begin
                    if (csr == 12'hf00) begin  // SW -> rd
                        regwrite_EX = 1'b1;
                        regsel_EX = 2'b00;
                    end
                    if (csr == 12'hf02) begin  // rs1 -> HEX
                        regwrite_EX = 1'b1;
                        GPIO_we_EX = 1'b1;
                    end
                end
            end
            // Jump instructions
            //I-Type
            if (opcode_EX == 7'b1100111) begin  // jalr
                if(funct3_EX == 3'b000) begin
                   regwrite_EX = 1'b1;
                    regsel_EX = 2'b11;
                    pcsrc_EX = 2'b11; 
                    stall_FETCH = 1'b1; 
                end
            end
            //B-Type
            if (opcode_EX == 7'b1100011) begin
                if(funct3_EX == 3'b000) begin // beq
                    aluop_EX = 4'b0100;
                    if (R_EX == 32'd0) begin
                        pcsrc_EX = 2'b01;
                        stall_FETCH = 1'b1;
                    end
                end
                if(funct3_EX == 3'b001) begin // bne
                    aluop_EX = 4'b0100;
                    if (R_EX != 32'd0) begin
                        pcsrc_EX = 2'b01;
                        stall_FETCH = 1'b1;
                    end
                end
                if(funct3_EX == 3'b100) begin // blt
                    aluop_EX = 4'b1100;
                    if (R_EX == 32'd1) begin
                        pcsrc_EX = 2'b01;
                        stall_FETCH = 1'b1;
                    end
                end
                if(funct3_EX == 3'b101) begin // bge
                    aluop_EX = 4'b1100;
                    if (R_EX == 32'd0) begin
                        pcsrc_EX = 2'b01;
                        stall_FETCH = 1'b1;
                    end
                end
                if(funct3_EX == 3'b110) begin // bltu
                    aluop_EX = 4'b1101;
                    if (R_EX == 32'd1) begin
                        pcsrc_EX = 2'b01;
                        stall_FETCH = 1'b1;
                    end
                end
                if(funct3_EX == 3'b111) begin // bgeu
                    aluop_EX = 4'b1101;
                    if (R_EX == 32'd0) begin
                        pcsrc_EX = 2'b01;
                        stall_FETCH = 1'b1;
                    end
                end
            end
            //J-Type
            if (opcode_EX == 7'b1101111) begin //jal
                regwrite_EX = 1'b1;
                regsel_EX = 2'b11;
                pcsrc_EX = 2'b10; 
                stall_FETCH = 1'b1;
            end
            
        end
    end
endmodule


