module controlunit (
    input logic [6:0] opcode,
    input logic [4:0] rd,
    input logic [2:0] funct3,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [6:0] funct7,
    input logic [11:0] immi,
    input logic [19:0] immu,
    output logic alusrc_EX,
    output logic GPIO_we,
    output logic regwrite_EX,
    output logic [1:0] regsel_EX,
    output logic [3:0] aluop_EX
 

);

endmodule


