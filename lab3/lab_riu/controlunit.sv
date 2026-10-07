module controlunit (
    input logic [2:0] funct3_EX,
    input logic [6:0] opcode_EX, funct7_EX,
    input logic [11:0] csr,
    output logic alusrc_EX,
    output logic GPIO_we_EX,
    output logic regwrite_EX,
    output logic [1:0] regsel_EX,
    output logic [3:0] aluop_EX );

    always_comb begin
        alusrc_EX = 1'b0;
        GPIO_we_EX = 1'b0;
        regwrite_EX = 1'b0;
        regsel_EX = 2'b00;
         aluop_EX = 4'b0000;
            if (opcode_EX == 7'b0110011) begin // R-Type
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
            if (opcode_EX == 7'b0010011) begin // I-Type
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
            if (opcode_EX == 7'b0110111) begin // U-Type - lui
                alusrc_EX = 1'bX;
                GPIO_we_EX = 1'b0;
                regwrite_EX = 1'b1;
                regsel_EX = 2'b01;
                aluop_EX = 4'bX;
            end
            if (opcode_EX == 7'b1110011) begin // csrrw
                if (funct3_EX == 3'b001) begin
                    regwrite_EX = 1'b1;
                    regsel_EX = 2'b110;
                    if (csr == 12'hf00) // SW
                        regsel_EX = 2'b00;
                    if (csr == 12'hf02) // Hex
                        GPIO_we_EX = 1'b1; 
                end
            end
        end
endmodule


