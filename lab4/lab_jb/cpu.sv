module cpu(input logic clk, input logic rst_n, input logic [17:0] io0_in, output logic [31:0] io2_out);
    //get program from memory
    logic [31:0] inst_ram [4095:0];
    initial $readmemh("instmem.dat",inst_ram);

    //Fetch stage variables
    logic stall_FETCH;
    logic [11:0] PC_FETCH; 
    
    //Execution stage variables
    logic alusrc_EX, GPIO_we_EX, regwrite_EX, zero_EX, stall_EX;
    logic [1:0] regsel_EX, pcsrc_EX;
    logic [2:0] funct3_EX;
    logic [3:0] aluop_EX;
    logic [4:0] rd_EX, rs1_EX, rs2_EX;
    logic [6:0] opcode_EX, funct7_EX;
    logic [11:0] immi_EX, PC_EX, jalr_offset_EX, branch_addr_EX, jal_addr_EX, jalr_addr_EX;
    logic [12:0] branch_offset_EX;
    logic [19:0] immu_EX;
    logic [20:0] jal_offset_EX;
    logic [31:0] instruction_EX, readdata1_EX, readdata2_EX, alu_result_EX, immi_signext_EX, alu_B_EX, jalr_target_EX;
    
    //Writeback stage variables
    logic regwrite_WB;
    logic [1:0] regsel_WB;
    logic [4:0] rd_WB;
    logic [11:0] PC_WB;
    logic [17:0] io0_in_WB;
    logic [19:0] immu_WB;
    logic [31:0] writedata_WB, alu_result_WB;

    //sign extends immi for alu selection
    assign immi_signext_EX = {{20{immi_EX[11]}}, immi_EX};
    
    //assign addr for pc address
    assign branch_addr_EX = PC_EX + {branch_offset_EX[12],branch_offset_EX[12:2]};
    assign jal_addr_EX = PC_EX + jal_offset_EX[13:2];
    assign jalr_target_EX = readdata1_EX + {{20{jalr_offset_EX[11]}}, jalr_offset_EX};
    assign jalr_addr_EX = jalr_target_EX[13:2];  // drop last two bits means dividing by 4, converting to word address

    //Put fetched instruction to instruction in ex stage
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            PC_FETCH <= 12'd0;
            PC_EX <= 12'd0;
            instruction_EX <= 32'd0;
            stall_EX <= 1'b0;
        end else begin
            PC_EX <= PC_FETCH;
            stall_EX <= stall_FETCH;
           
            case (pcsrc_EX)
                2'b00: PC_FETCH <= PC_FETCH + 12'd1;
                2'b01: PC_FETCH <= branch_addr_EX;
                2'b10: PC_FETCH <= jal_addr_EX;
                2'b11: PC_FETCH <= jalr_addr_EX;
            endcase

            if (stall_FETCH)
                instruction_EX <= 32'd0;
            else
                instruction_EX <= inst_ram[PC_FETCH];
        end
    end

    //delays needed ex signals to wb
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            rd_WB <= 5'd0;
            regwrite_WB <= 1'b0;
            regsel_WB <= 2'b0;
            io0_in_WB <= 18'b0;
            immu_WB <= 20'b0;
            alu_result_WB <= 32'b0;
            PC_WB <= 12'd0;
        end else begin
            rd_WB <= rd_EX;
            regwrite_WB <= regwrite_EX;
            regsel_WB <= regsel_EX;
            io0_in_WB <= io0_in;
            immu_WB <= immu_EX;
            alu_result_WB <= alu_result_EX;
            PC_WB <= PC_EX + 12'd1;
        end
    end

     //io2_out mux w/ GPIO_we enable
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            io2_out <= 32'd0;
        end else if (GPIO_we_EX) begin
            io2_out <= readdata1_EX;
        end
    end

    //ALU mux
    assign alu_B_EX = alusrc_EX ? immi_signext_EX : readdata2_EX;

    //Register file write data mux
    always_comb begin
        case (regsel_WB)
            2'd0: writedata_WB = {14'b0, io0_in_WB};
            2'd1: writedata_WB = {immu_WB, 12'b0};
            2'd2: writedata_WB = alu_result_WB;
            2'd3: writedata_WB = {18'b0, PC_WB, 2'b00};
            default: writedata_WB = 32'd0;
        endcase
    end

    //Wiring for decoder
    instruction_decoder decode (
        .instruction_EX (instruction_EX),
        .opcode_EX (opcode_EX),
        .funct7_EX (funct7_EX),
        .rd_EX (rd_EX),
        .rs1_EX (rs1_EX),
        .rs2_EX (rs2_EX),
        .funct3_EX (funct3_EX),
        .immi_EX (immi_EX),
        .immu_EX (immu_EX),
        .branch_offset_EX(branch_offset_EX),
        .jal_offset_EX(jal_offset_EX),
        .jalr_offset_EX(jalr_offset_EX)
    );

    //Wiring for control unit
    controlunit control (
        .opcode_EX (opcode_EX),
        .funct7_EX (funct7_EX),
        .funct3_EX (funct3_EX),
        .alusrc_EX (alusrc_EX),
        .GPIO_we_EX (GPIO_we_EX),
        .regwrite_EX (regwrite_EX),
        .regsel_EX (regsel_EX),
        .aluop_EX (aluop_EX),
        .csr (immi_EX),
        .stall_EX(stall_EX),
        .R_EX(alu_result_EX),
        .pcsrc_EX(pcsrc_EX),
        .stall_FETCH(stall_FETCH)
    );

    //Wiring for regfile
    regfile registers (
        .clk (clk),
        .we (regwrite_WB),
        .readaddr1 (rs1_EX),
        .readaddr2 (rs2_EX),
        .writeaddr (rd_WB),
        .writedata (writedata_WB),
        .readdata1 (readdata1_EX),
        .readdata2 (readdata2_EX)
    );

    //Wiring for ALU
    alu do_math (
        .A (readdata1_EX),
        .B (alu_B_EX),
        .op (aluop_EX),
        .R (alu_result_EX),
        .zero(zero_EX) 
    );
endmodule