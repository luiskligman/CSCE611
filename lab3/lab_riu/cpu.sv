module cpu(input logic clk, input logic rst_n);

    logic [31:0] inst_ram [4095:0];
    initial $readmemh("program.rom",inst_ram);

    logic [11:0] PC_FETCH = 12'd0;
    logic [31:0] instruction_EX;

    //instruction decoder wires
    logic [6:0] opcode_EX, funct7_EX;
    logic [4:0] rd_EX, rs1_EX, rs2_EX;
    logic [2:0] funct3_EX;
    logic [11:0] immi_EX;
    logic [19:0] immu_EX;

    //control unit wires ex
    logic alusrc_EX,
    logic GPIO_we_EX,
    logic regwrite_EX,
    logic [1:0] regsel_EX,
    logic [3:0] aluop_EX

    //control wires wb
    logic [4:0] rd_WB
    logic regwrite_WB


    always_ff @(poseede clk) begin
        if (~rst_n) begin
            rd_WB <= 5'd0;
        end else begin
            rd_WB <= rd_WB;
        end
    end
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
        .opcode_EX (opcode_EX),
        .funct7_EX (funct7_EX),
        .rd_EX (rd_EX),
        .rs1_EX (rs1_EX),
        .rs2_EX (rs2_EX),
        .funct3_EX (funct3_EX),
        .immi_EX (immi_EX),
        .immu_EX (immu_EX)
    );

    controlunit control (
        .opcode_EX (opcode_EX),
        .funct7_EX (funct7_EX),
        .rd_EX (rd_EX),
        .rs1_EX (rs1_EX),
        .rs2_EX (rs2_EX),
        .funct3_EX (funct3_EX),
        .immi_EX (immi_EX),
        .immu_EX (immu_EX),
        .alusrc_EX (alusrc_EX),
        .GPIO_we_EX (GPIO_we_EX),
        .regwrite_EX (regwrite_EX),
        .regsel_EX (regsel_EX),
        .aluop_EX (aluop_EX)
    );

    regfile registers (
        .clock (clk),
        .we (regwrite_WB),
        .readaddr1 (rs1_EX),
        .readaddr2 (rs2_EX),
        .writeaddr (),
        .writedata ()
    );
endmodule