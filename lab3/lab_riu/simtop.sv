/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* Top-level module for CSCE611 RISC-V CPU, for running under simulation.  In
 * this case, the I/Os and clock are driven by the simulator. */

module simtop;

	logic clk;
	logic [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
	logic [3:0] KEY;
	logic [17:0] SW;

	integer errors;
	integer i;

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
			$display("FAIL %s got = %h, expected = %h",
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

		// Clear all instruction memory left over from instmem.dat.
		for (i = 0; i < 4096; i = i + 1)
			dut.cpu.inst_ram[i] = 32'h00000000;

		// Load only the simulation test program.
		$readmemh("cpu_test.dat", dut.cpu.inst_ram);
		// Wait for reset to be released.
		wait (KEY[0] == 1'b1);

		// The program has 35 instructions: 25 professor-provided tests
		// followed by 10 extra edge-case tests.
		// Allow extra clocks for the Fetch -> EX -> WB pipeline.
		repeat (45) @(posedge clk);
		#1;

		// ===== Professor-provided instruction tests =====
		check32("x1", dut.cpu.registers.mem[1],  32'h0000000c); // addi
		check32("x2",  dut.cpu.registers.mem[2],  32'h00000011); // addi
		check32("x3",  dut.cpu.registers.mem[3],  32'h88000000); // add, sub, slli
		check32("x4",  dut.cpu.registers.mem[4],  32'h08000000); // mul
		check32("x5",  dut.cpu.registers.mem[5],  32'hfffffff8); // mulh
		check32("x6",  dut.cpu.registers.mem[6],  32'h00000009); // mulhu
		check32("x7",  dut.cpu.registers.mem[7],  32'h00000001); // slt
		check32("x8",  dut.cpu.registers.mem[8],  32'h00000000); // sltu
		check32("x9",  dut.cpu.registers.mem[9],  32'h00000008); // and
		check32("x10", dut.cpu.registers.mem[10], 32'hfffffffc); // or
		check32("x11", dut.cpu.registers.mem[11], 32'h0000001d); // xor
		check32("x12", dut.cpu.registers.mem[12], 32'h88000000); // andi
		check32("x13", dut.cpu.registers.mem[13], 32'hfffff811); // ori
		check32("x14", dut.cpu.registers.mem[14], 32'h0000001f); // xori
		check32("x15", dut.cpu.registers.mem[15], 32'h00011000); // sll
		check32("x16", dut.cpu.registers.mem[16], 32'h00004400); // srl
		check32("x17", dut.cpu.registers.mem[17], 32'hffffc400); // sra
		check32("x18", dut.cpu.registers.mem[18], 32'h00000018); // slli
		check32("x19", dut.cpu.registers.mem[19], 32'h00000008); // srli
		check32("x20", dut.cpu.registers.mem[20], 32'hc4000000); // srai
		check32("x21", dut.cpu.registers.mem[21], 32'hdbeef000); // lui
		check32("x22", dut.cpu.registers.mem[22], 32'h00000000); // csrrw io2: reading io2 returns 0
		check32("x23", dut.cpu.registers.mem[23], 32'd12345);    // csrrw io0: reads SW

		// csrrw x22, 0xf02, x3 writes x3 to io2 / HEX displays.
		check32("io2_out", dut.io2_out, 32'h88000000);

		// ===== Extra edge-case tests (added beyond the professor-provided tests) =====
		check32("x24", dut.cpu.registers.mem[24], 32'h00000000); // x0 stays 0 after addi x0, x0, 5
		check32("x25", dut.cpu.registers.mem[25], 32'h7fffffff); // lui + addi builds the largest positive
		check32("x26", dut.cpu.registers.mem[26], 32'h80000000); // add overflow wraps
		check32("x27", dut.cpu.registers.mem[27], 32'h00000021); // addi 33
		check32("x28", dut.cpu.registers.mem[28], 32'h00000022); // sll by 33 uses only the low 5 bits
		check32("x29", dut.cpu.registers.mem[29], 32'h38400000); // mulh, both operands negative
		check32("x30", dut.cpu.registers.mem[30], 32'h000007ff); // largest 12-bit immediate
		check32("x31", dut.cpu.registers.mem[31], 32'hfffff800); // smallest 12-bit immediate

		if (errors == 0)
			$display("PASS: CPU test completed with 0 errors.");
		else
			$fatal(1, "FAIL: CPU test completed with %0d errors.", errors);

		$finish;
	end

endmodule