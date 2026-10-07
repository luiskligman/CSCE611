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

	always @(posedge clk)
 		begin
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
				$stop;
			end
 		end

	// control unit sanity check
	logic [31:0] cu_instr;
	logic [6:0] cu_opcode, cu_fucnt7;
	logic [2:0] cu_funct3;
	logic [11:0] cu_immi;
	logic alusrc, gpio_we, regwrite;
	logic [1:0] regsel;
	logic [3:0] aluop;
	int cu_errors = 0;


	

endmodule

