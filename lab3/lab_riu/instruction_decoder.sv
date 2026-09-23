module instruction_decorder (
    input [31:0] instruction,

    // R-Type
    output logic [7:0] funct7,
    output logic [4:0] rs2,
    output logic [4:0] funct3,
    output logic [4:0] rd,
    output logic [6:0] opcode,
    
    // I-Type
    output logic [11:0] imm,
    output logic [4:0] rs1,
    output logic [2:0] funct3,
    // output logic [4:0] rd,
    // output logic [6:0] opcode,

    // U-Type
    output logic [19:0] imm,
    // output logic [4:0] rd,
    // output logic [6:0] opcode,
    );

    always_comb begin
        
        opcode = instruction[6:0];
        rd     = instruction[11:7];



    end


endmodule