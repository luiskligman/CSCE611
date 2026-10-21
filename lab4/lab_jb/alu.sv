/** RISC-V ALU for CSCE611 Fall 2020
*
* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels
*/


module alu(
	input logic  [31:0] A,
	input logic  [31:0] B,
	input logic  [ 3:0] op,
	output logic [31:0] R,
	output logic zero
);

logic [31:0] mulls, mullu, mulhu, mulhs;
logic [ 4:0] shamt;
logic [31:0] shifted;

assign zero = R==32'd0 ? 1'b1 : 1'b0;

assign {mulhu, mullu}  = A*B;
assign {mulhs, mulls}  = $signed(A)*$signed(B);
assign shamt = B[4:0];

// Arithmetic right shift does not work under ModelSim, so we we work
// around this by implementing our own shift. Notice the blocking assignments.
always_comb begin
	shifted = A;
	if (shamt[0]) shifted = {{1{A[31]}},shifted[31:1]};
	if (shamt[1]) shifted = {{2{A[31]}},shifted[31:2]};
	if (shamt[2]) shifted = {{4{A[31]}},shifted[31:4]};
	if (shamt[3]) shifted = {{8{A[31]}},shifted[31:8]};
	if (shamt[4]) shifted = {{16{A[31]}},shifted[31:16]};
end


assign R =
	(op == 4'b0000) ? A & B :
	(op == 4'b0001) ? A | B :
	(op == 4'b0010) ? A ^ B :
	(op == 4'b0011) ? A + B :
	(op == 4'b0100) ? A - B :
	(op == 4'b0101) ? mulls :
	(op == 4'b0110) ? mulhs :
	(op == 4'b0111) ? mulhu :
	(op == 4'b1000) ? A << shamt :
	(op == 4'b1001) ? A >> shamt :
	(op == 4'b1010) ? shifted :
	(op == 4'b1011) ? shifted :
	(op == 4'b1100) ? ($signed(A) < $signed(B)) :
	(op == 4'b1101) ? (A < B) :
	(op == 4'b1110) ? (A < B) : (A < B);

endmodule
