/* 32 x 32 register file implementation */

module regfile (

/**** inputs *****************************************************************/

	input [0:0 ] clk,		/* clock */
	input [0:0 ] we,		/* write enable */
	input [4:0 ] readaddr1,		/* read address 1 */
	input [4:0 ] readaddr2,		/* read address 2 */
	input [4:0 ] writeaddr,		/* write address */
	input [31:0] writedata,		/* write data */

/**** outputs ****************************************************************/

	output [31:0] readdata1,	/* read data 1 */
	output [31:0] readdata2		/* read data 2 */
);

logic [31:0] mem[31:0];

always_ff @(posedge clk) begin
	if (we) mem[writeaddr] <= writedata;
end

always_comb begin
	// $monitor("reg 6: %8h", mem[6]);
	// $monitor("reg 5: %8h", mem[5]);
	// $monitor("writeaddr: %8h, we: %1h", writeaddr, we);

	if (readaddr1 == 5'd0) readdata1 = 32'd0;
	else if (we && readaddr1 == writeaddr) readdata1 = writedata;
	else readdata1 = mem[readaddr1];

	if (readaddr2 == 5'd0) readdata2 = 32'd0;
	else if (we && readaddr2 == writeaddr) readdata2 = writedata;
	else readdata2 = mem[readaddr2];
end

endmodule
