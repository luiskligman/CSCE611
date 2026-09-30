module instruction_decoder (
    input [31:0] instruction_EX,

    // R-Type
    output logic [6:0] funct7_EX,
    output logic [4:0] rs2_EX,
    output logic [4:0] rs1_EX,
    output logic [2:0] funct3_EX,
    output logic [4:0] rd_EX,
    output logic [6:0] opcode_EX,
    
    // I-Type
    output logic [11:0] immi_EX,
    // output logic [4:0] rs1_EX,
    // output logic [2:0] funct3_EX,
    // output logic [4:0] rd_EX,
    // output logic [6:0] opcode_EX,

    // U-Type
    output logic [19:0] immu_EX
    // output logic [4:0] rd_EX,
    // output logic [6:0] opcode_EX,
    );

    always_comb begin 
        opcode_EX = instruction_EX[6:0];
        rd_EX     = instruction_EX[11:7];

        // R-Type
        funct3_EX = insturction_EX[14:12];
        rs1_EX    = instruction_EX[19:15];
        rs2_EX    = instruction_EX[24:20];
        funct7_EX = instruction_EX[31:25];

        // I-Type
        immi_EX   = instruction_EX[31:20];

        // U-Type
        immu_EX   = instruction_EX[31:12];

    end

endmodule