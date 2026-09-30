module cpu(input logic clk, input logic rst_n);

    logic [31:0] inst_ram [4095:0];
    initial $readmemh("program.rom",inst_ram);

    logic [11:0] PC_FETCH = 12'd0;
    logic [31:0] instruction_EX;

    //instruction decoder wires
    logic [6:0] opcode, funct7;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [11:0] immi;
    logic [19:0] immu;

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            PC_FETCH <= 12'd0;
            instruction_EX <= 32'd0;
        end else begin
            PC_FETCH <= PC_FETCH + 1'b1;
            instruction_EX <= inst_ram[PC_FETCH];
        end
    end

    instruction_decoder decode (
        .instruction_EX (instruction_EX),
        .opcode (opcode),
        .funct7 (funct7),
        .rd (rd),
        .rs1 (rs1),
        .rs2 (rs2),
        .funct3 (funct3),
        .immi (immi),
        .immu (immu)
    );

    controlunit control (
        .opcode (opcode),
        .funct7 (funct7),
        .rd (rd),
        .rs1 (rs1),
        .rs2 (rs2),
        .funct3 (funct3),
        .immi (immi),
        .immu (immu),
        .alusrc_EX (),
        .GPIO_we (),
        .regwrite_EX (),
        .regsel_EX (),
        .aluop_EX ()
    );
endmodule