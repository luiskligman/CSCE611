module instruction_decoder (
    input [31:0] instruction_EX,

    // R-Type
    output logic [6:0] funct7,
    output logic [4:0] rs2,
    output logic [2:0] funct3,
    output logic [4:0] rd,
    output logic [6:0] opcode,
    
    // I-Type
    output logic [11:0] immi,
    output logic [4:0] rs1,
    output logic [2:0] funct3,
    // output logic [4:0] rd,
    // output logic [6:0] opcode,

    // U-Type
    output logic [19:0] immu,
    // output logic [4:0] rd,
    // output logic [6:0] opcode,
    );

    always_comb begin
        
        opcode = instruction_EX[6:0];
        rd     = instruction_EX[11:7];



    end


endmodule