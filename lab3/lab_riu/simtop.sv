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

	always @(posedge clk)
 		begin
			// instruction = [63:32], expected = [31:0]
 			{instruction, expected} = testvectors[vectornum];

 		end

endmodule

