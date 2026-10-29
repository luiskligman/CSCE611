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
	// initial begin
	// 	KEY <= 4'he;
	// 	#10;
	// 	KEY <= 4'hf;
	// end

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

	// Hold the CPU in reset, load a program, then let it run.
	// Reset does not clear the register file, so each program must set every register it checks.
	task automatic run_program (input string file, input integer cycles);
		KEY[0] = 1'b0;
		for (i = 0; i < 4096; i = i + 1)
			dut.cpu.inst_ram[i] = 32'h00000000;
		$readmemh(file, dut.cpu.inst_ram);
		repeat (2) @(posedge clk);  // reset is synchronous, so it needs clock edges
		KEY[0] = 1'b1;
		repeat (cycles) @(posedge clk);
		#1;
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
		KEY = 4'hf;
		#1;

		run_program("cpu_test.dat", 45);

		// ===== Professor-provided instruction tests =====
		check32("t1 x1",  dut.cpu.registers.mem[1],  32'h0000000c); // addi
		check32("t1 x2",  dut.cpu.registers.mem[2],  32'h00000011); // addi
		check32("t1 x3",  dut.cpu.registers.mem[3],  32'h88000000); // add, sub, slli
		check32("t1 x4",  dut.cpu.registers.mem[4],  32'h08000000); // mul
		check32("t1 x5",  dut.cpu.registers.mem[5],  32'hfffffff8); // mulh
		check32("t1 x6",  dut.cpu.registers.mem[6],  32'h00000009); // mulhu
		check32("t1 x7",  dut.cpu.registers.mem[7],  32'h00000001); // slt
		check32("t1 x8",  dut.cpu.registers.mem[8],  32'h00000000); // sltu
		check32("t1 x9",  dut.cpu.registers.mem[9],  32'h00000008); // and
		check32("t1 x10", dut.cpu.registers.mem[10], 32'hfffffffc); // or
		check32("t1 x11", dut.cpu.registers.mem[11], 32'h0000001d); // xor
		check32("t1 x12", dut.cpu.registers.mem[12], 32'h88000000); // andi
		check32("t1 x13", dut.cpu.registers.mem[13], 32'hfffff811); // ori
		check32("t1 x14", dut.cpu.registers.mem[14], 32'h0000001f); // xori
		check32("t1 x15", dut.cpu.registers.mem[15], 32'h00011000); // sll
		check32("t1 x16", dut.cpu.registers.mem[16], 32'h00004400); // srl
		check32("t1 x17", dut.cpu.registers.mem[17], 32'hffffc400); // sra
		check32("t1 x18", dut.cpu.registers.mem[18], 32'h00000018); // slli
		check32("t1 x19", dut.cpu.registers.mem[19], 32'h00000008); // srli
		check32("t1 x20", dut.cpu.registers.mem[20], 32'hc4000000); // srai
		check32("t1 x21", dut.cpu.registers.mem[21], 32'hdbeef000); // lui
		// check32("x22", dut.cpu.registers.mem[22], 32'h00000000); // csrrw io2: reading io2 returns 0
		check32("x23", dut.cpu.registers.mem[23], 32'd12345);    // csrrw io0: reads SW

		// csrrw x22, 0xf02, x3 writes x3 to io2 / HEX displays.
		check32("t1 io2_out", dut.io2_out, 32'h88000000);

		// ===== Extra edge-case tests (added beyond the professor-provided tests) =====
		check32("t1 x24", dut.cpu.registers.mem[24], 32'h00000000); // x0 stays 0 after addi x0, x0, 5
		check32("t1 x25", dut.cpu.registers.mem[25], 32'h7fffffff); // lui + addi builds the largest positive
		check32("t1 x26", dut.cpu.registers.mem[26], 32'h80000000); // add overflow wraps
		check32("t1 x27", dut.cpu.registers.mem[27], 32'h00000021); // addi 33
		check32("t1 x28", dut.cpu.registers.mem[28], 32'h00000022); // sll by 33 uses only the low 5 bits
		check32("t1 x29", dut.cpu.registers.mem[29], 32'h38400000); // mulh, both operands negative
		check32("t1 x30", dut.cpu.registers.mem[30], 32'h000007ff); // largest 12-bit immediate
		check32("t1 x31", dut.cpu.registers.mem[31], 32'hfffff800); // smallest 12-bit immediate

		// ==== Program 2: branch and jump tests (test2.asm) ====
		run_program("cpu_test2.dat", 300);

		// Taken branches end at 11 (0x0b), not-taken branches at 21 (0x15).
		check32("t2 x4", dut.cpu.registers.mem[4], 32'h0000000b);
		check32("t2 x5",  dut.cpu.registers.mem[5],  32'h00000015); // beq not taken
		check32("t2 x6",  dut.cpu.registers.mem[6],  32'h0000000b); // bne taken
		check32("t2 x7",  dut.cpu.registers.mem[7],  32'h00000015); // bne not taken
		check32("t2 x8",  dut.cpu.registers.mem[8],  32'h0000000b); // blt taken: -1 < 1 signed
		check32("t2 x9",  dut.cpu.registers.mem[9],  32'h00000015); // blt not taken: equal operands
		check32("t2 x10", dut.cpu.registers.mem[10], 32'h00000015); // bltu not taken: 0xffffffff < 1 unsigned
		check32("t2 x11", dut.cpu.registers.mem[11], 32'h0000000b); // bltu taken: 1 < 0xffffffff 
		check32("t2 x12", dut.cpu.registers.mem[12], 32'h0000000b); // bge taken: equal operands
		check32("t2 x13", dut.cpu.registers.mem[13], 32'h00000015); // bge not taken: -1 >= 1 signed
		check32("t2 x14", dut.cpu.registers.mem[14], 32'h0000000b); // bgeu taken: 0xffffffff >= 1
		check32("t2 x15", dut.cpu.registers.mem[15], 32'h00000015); // bgeu not taken: 1 >= 0xffffffff
                  
		check32("t2 x16", dut.cpu.registers.mem[16], 32'h00000005); // backward branch loop ran 5 times
		check32("t2 x18", dut.cpu.registers.mem[18], 32'h00000001); // wrong path after the loop branch never ran
                  
        check32("t2 x19", dut.cpu.registers.mem[19], 32'h000000d4); // jal forward: return address
		check32("t2 x20", dut.cpu.registers.mem[20], 32'h0000000b); // jal forward: skipped the wrong path
		check32("t2 x21", dut.cpu.registers.mem[21], 32'h0000000b); // jal backward: landed on the target
		check32("t2 x22", dut.cpu.registers.mem[22], 32'h000000f0); // jal backward: return address
                  
        check32("t2 x24", dut.cpu.registers.mem[24], 32'h0000006f); // call and return (jal + jalr)
		check32("t2 x25", dut.cpu.registers.mem[25], 32'h000000fc); // call: return address 
                  
		check32("t2 x26", dut.cpu.registers.mem[26], 32'h0000000b); // jalr with offset 12
        check32("t2 x27", dut.cpu.registers.mem[27], 32'h00000118); // jal to the very next instruction
        check32("t2 x28", dut.cpu.registers.mem[28], 32'h0000011c); // jalr: return address 
                  
        check32("t2 x29", dut.cpu.registers.mem[29], 32'h00000140); // address built with addi
        check32("t2 x23", dut.cpu.registers.mem[23], 32'h0000000b); // jalr to that address (via bypass)
                  
        check32("t2 x30", dut.cpu.registers.mem[30], 32'h0000000b); // branch in the cancelled slot ignored
        check32("t2 x31", dut.cpu.registers.mem[31], 32'h000004d2); // program reached the end 

		if (errors == 0)
			$display("PASS: CPU test completed with 0 errors.");
		else
			$fatal(1, "FAIL: CPU test completed with %0d errors.", errors);

		$finish;
	end

endmodule