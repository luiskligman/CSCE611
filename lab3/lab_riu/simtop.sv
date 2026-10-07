/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* Top-level module for CSCE611 RISC-V CPU, for running under simulation.  In
 * this case, the I/Os and clock are driven by the simulator. */

module simtop;

	logic clk;
	logic [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
	logic [3:0] KEY;
	logic [17:0] SW;
	
	logic [63:0] testvectors [0:999];
	logic [31:0] instruction, expected;
	logic [31:0] vectornum, errors;
	logic reset;

	logic [6:0] opcode, funct7;
	logic [4:0] rs2, rs1, rd;
	logic [2:0] funct3;
	logic [11:0] immi;
	logic [19:0] immu;

	top dut
	(
		//////////// CLOCK //////////
		.CLOCK_50(clk),
		.CLOCK2_50(),
	    .CLOCK3_50(),

		//////////// LED //////////
		.LEDG(),
		.LEDR(),

		//////////// KEY //////////
		.KEY(KEY),

		//////////// SW //////////
		.SW(SW),

		//////////// SEG7 //////////
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5),
		.HEX6(HEX6),
		.HEX7(HEX7)
	);

	// pulse reset (active low)
	initial begin
		KEY <= 4'he;
		#10;
		KEY <= 4'hf;
	end
	
	// drive clock
	always begin
		clk <= 1'b0; #5;
		clk <= 1'b1; #5;
	end
	
	// assign simulated switch values
	assign SW = 18'd12345;

	// read in tests from testvectors.tv
	initial begin
 		$readmemb("testvectors.tv", testvectors);
		// note: use $readmemh() for ALU testbench
 		vectornum = 32'b0; errors = 32'b0;
 		reset = 1'b1; #27; reset = 1'b0;
 	end

	/* 
	 * input will be 64 bit binary strings
	 * first 32 bits will be the instruction
	 * second 32 bit will be the expected result

	 * might have to sign extend certain expect results
	 */


	// instantiate instruction decoder
	instruction_decoder dec (
		.instruction_EX(instruction),
		.funct7_EX(funct7),
		.rs2_EX(rs2),
		.rs1_EX(rs1),
		.funct3_EX(funct3),
		.rd_EX(rd),
		.opcode_EX(opcode),
		.immi_EX(immi),
		.immu_EX(immu)
	);
	
	logic dec_done = 1'b0;
	always @(posedge clk)
 		begin
		if (!dec_done) begin
				// instruction = [63:32], expected = [31:0]
				{instruction, expected} = testvectors[vectornum];
				#1;
				if ({funct7, rs2, rs1, funct3, rd, opcode} !== expected || // R-Type
					{immi, rs1, funct3, rd, opcode}        !== expected || // I-Type
					{immu, rd, opcode} 				   	   !== expected) // U-Type
				begin
					$display("vector %0d FAILED: instruction=%b", vectornum, instruction);
					errors = errors + 1;
				end

				vectornum = vectornum + 1;
				if (testvectors[vectornum] === 64'bx) 
				begin
					$display("%0d tests completed with %0d errors", vectornum, errors);
					dec_done = 1'b1;
				end
			end
 		end

	// control unit sanity check
	logic [31:0] cu_instr;
	logic [6:0] cu_opcode, cu_funct7;
	logic [2:0] cu_funct3;
	logic [11:0] cu_immi;
	logic alusrc, gpio_we, regwrite;
	logic [1:0] regsel;
	logic [3:0] aluop;
	int cu_errors = 0;

	instruction_decoder cu_dev (
		.instruction_EX(cu_instr),
		.opcode_EX(cu_opcode),
		.funct7_EX(cu_funct7),
		.funct3_EX(cu_funct3),
		.immi_EX(cu_immi),
		.rs2_EX(),
		.rs1_EX(),
		.rd_EX(),
		.immu_EX()
	);

	controlunit cu (
		.opcode_EX(cu_opcode),
		.funct7_EX(cu_funct7),
		.funct3_EX(cu_funct3),
		.csr(cu_immi),
		.alusrc_EX(alusrc),
		.GPIO_we_EX(gpio_we),
		.regwrite_EX(regwrite),
		.regsel_EX(regsel),
		.aluop_EX(aluop)
	);
	
	task check(input string name, 
			   input logic [31:0] instr, 
			   input logic [8:0] exp);
		cu_instr = instr;
		#1;
		if (({alusrc, gpio_we, regwrite, regsel, aluop} !=? exp) !== 1'b1) begin
			$display("CU FAIL %s: got %b, expected %b", name,
					 {alusrc, gpio_we, regwrite, regsel, aluop}, exp);
			cu_errors++;
		end
	endtask

	initial begin
		check("add", 	   32'h007302b3, 9'b0_0_1_10_0011);
		check("sub", 	   32'h407302b3, 9'b0_0_1_10_0100);
		check("addi",      32'hfff30293, 9'b1_0_1_10_0011);
      	check("srai",      32'h40335293, 9'b1_0_1_10_1010);
      	check("lui",       32'h800002b7, 9'bx_0_1_01_xxxx);
      	check("csrrw io0", 32'hf00012f3, 9'bx_0_1_00_xxxx);
      	check("csrrw io2", 32'hf0231073, 9'bx_1_1_11_xxxx);
      	check("all zeros", 32'h00000000, 9'bx_0_0_xx_xxxx);
		$display("control unit: %0d errors", cu_errors);
	end
		



	

endmodule

