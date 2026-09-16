/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* Top-level module for CSCE611 RISC-V CPU, for running under simulation.  In
 * this case, the I/Os and clock are driven by the simulator. */

module simtop;

	logic clk;
	logic [17:0] SW;
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
		if (actual != expected) 
			$display("FAIL: %s expected %b got %b", label, expected, actual); 
		else
			$display("PASS: %s", label);
	endtask

	initial begin

		SW = 18'b0;

		SW[3:0] = 4'h0;
		#10; 
		check(HEX0, 7'b100_0000, "HEX0 = 0");
		SW[3:0] = 4'hB;
		#10; 
		check(HEX0, 7'b000_0011, "HEX0 = B");

		SW[7:4] = 4'h1;
		#10; 
		check(HEX1, 7'b111_1001, "HEX1 = 1");
		SW[7:4] = 4'hC;
		#10; 
		check(HEX1, 7'b100_0110, "HEX1 = C");

		SW[11:8] = 4'h2;
		#10; 
		check(HEX2, 7'b010_0100, "HEX2 = 2");
		SW[11:8] = 4'hA;
		#10; 
		check(HEX2, 7'b000_1000, "HEX2 = A");

		SW[15:12] = 4'hF;
		#10; 
		check(HEX3, 7'b000_1110, "HEX3 = F");
		SW[15:12] = 4'h9;
		#10; 
		check(HEX3, 7'b001_0000, "HEX3 = 9");

		SW[17:16] = 2'h3;
		#10; 
		check(HEX4, 7'b011_0000, "HEX4 = 3");
		SW[17:16] = 2'h1;
		#10; 
		check(HEX4, 7'b111_1001, "HEX4 = 1");


	$finish;

	end

endmodule

