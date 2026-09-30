module controlunit (
    input logic [6:0] opcode_EX, funct7_EX;
    input logic [4:0] rd_EX, rs1_EX, rs2_EX;
    input logic [2:0] funct3_EX;
    input logic [11:0] immi_EX;
    input logic [19:0] immu_EX;
    output logic alusrc_EX,
    output logic GPIO_we_EX,
    output logic regwrite_EX,
    output logic [1:0] regsel_EX,
    output logic [3:0] aluop_EX
);

endmodule


