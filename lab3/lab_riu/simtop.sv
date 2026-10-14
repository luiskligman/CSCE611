/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* Top-level module for CSCE611 RISC-V CPU, for running under simulation.  In
 * this case, the I/Os and clock are driven by the simulator. */

module simtop;

	logic clk;
	logic [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
	logic [3:0] KEY;
	logic [17:0] SW;

	integer errors;

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

	// Check a 32-bit value and record an error if it is incorrect.
	task automatic check32 (
		input string       name,
		input logic [31:0] got,
		input logic [31:0] expected
	);
		if (got !== expected) begin
			$display("FAIL %-8s got = %h, expected = %h",
					 name, got, expected);
			errors = errors + 1;
		end
	endtask

	/* Self-checking end-to-end CPU test.
	 *
	 * cpu.sv initially loads instmem.dat as usual.  At time 1 ns, this
	 * testbench overwrites the simulated instruction memory with cpu_test.dat.
	 * The reset remains active until 10 ns, so no test instructions execute
	 * before cpu_test.dat is loaded.
	 */
	initial begin
		errors = 0;

		// Load the simulation-only instruction test program.
		#1;
		$readmemh("cpu_test.dat", dut.cpu.inst_ram);

		// Wait for reset to be released.
		wait (KEY[0] == 1'b1);

		// The supplied program has 25 instructions.
		// Allow extra clocks for the Fetch -> EX -> WB pipeline.
		repeat (35) @(posedge clk);
		#1;

		// Expected values from the supplied instruction test program.
		check32("x1",  dut.cpu.registers.mem[1],  32'h0000000c);
		check32("x2",  dut.cpu.registers.mem[2],  32'h00000011);
		check32("x3",  dut.cpu.registers.mem[3],  32'h88000000);
		check32("x4",  dut.cpu.registers.mem[4],  32'hfffffff8);
		check32("x5",  dut.cpu.registers.mem[5],  32'h00000009);
		check32("x6",  dut.cpu.registers.mem[6],  32'h00000000);
		check32("x7",  dut.cpu.registers.mem[7],  32'h00000008);
		check32("x8",  dut.cpu.registers.mem[8],  32'hfffffffc);
		check32("x9",  dut.cpu.registers.mem[9],  32'h0000001d);
		check32("x10", dut.cpu.registers.mem[10], 32'h88000000);
		check32("x11", dut.cpu.registers.mem[11], 32'hfffff811);
		check32("x12", dut.cpu.registers.mem[12], 32'h0000001f);
		check32("x13", dut.cpu.registers.mem[13], 32'h00011000);
		check32("x14", dut.cpu.registers.mem[14], 32'h00004400);
		check32("x15", dut.cpu.registers.mem[15], 32'hffffc400);
		check32("x16", dut.cpu.registers.mem[16], 32'h00000018);
		check32("x17", dut.cpu.registers.mem[17], 32'h00000008);
		check32("x18", dut.cpu.registers.mem[18], 32'hc4000000);
		check32("x19", dut.cpu.registers.mem[19], 32'hdbeef000);

		// csrrw x21, 0xf00, x3 reads io0, which is connected to SW.
		check32("x21", dut.cpu.registers.mem[21], 32'd12345);

		// csrrw x20, 0xf02, x3 writes x3 to io2 / HEX displays.
		check32("io2_out", dut.io2_out, 32'h88000000);

		if (errors == 0)
			$display("PASS: CPU test completed with 0 errors.");
		else
			$fatal(1, "FAIL: CPU test completed with %0d errors.", errors);

		$finish;
	end

endmodule