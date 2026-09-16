/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* Top-level module for CSCE611 RISC-V CPU, for running under simulation.  In
 * this case, the I/Os and clock are driven by the simulator. */

module simtop;

	logic clk;
	logic [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;

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
		.KEY(),

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

	// simple task to check one HEX output against an expected pattern
	task check(input [6:0] actual, input[6:0] expected, input string label);
		actual !== expected 
		? $display("FAIL: %s expected %b got %b, label, expected, actual") 
		: $display("PASS: %s", label);
	endtask

	initial begin

		SW = 18'b0;

		// Check all HEX for 0
		SW[17:0] = 18'd0;
		#10; 
		check(HEX0, 7'b100_0000, "HEX0 = 0");
		#10; 
		check(HEX1, 7'b100_0000, "HEX1 = 0");
		#10; 
		check(HEX2, 7'b100_0000, "HEX2 = 0");
		#10; 
		check(HEX3, 7'b100_0000, "HEX3 = 0");
		#10; 
		check(HEX4, 7'b100_0000, "HEX4 = 0");

		// Check all HEX for F
		SW[17:0] = {18{1'b1}};
		#10; 
		check(HEX0, 7'b000_1110, "HEX0 = F");
		#10; 
		check(HEX1, 7'b000_1110, "HEX1 = F");
		#10; 
		check(HEX2, 7'b000_1110, "HEX2 = F");
		#10; 
		check(HEX3, 7'b000_1110, "HEX3 = F");
		#10; 
		check(HEX4, 7'b000_1110, "HEX4 = F");


	end

endmodule

