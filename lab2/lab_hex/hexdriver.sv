module hexdriver (input [3:0] val, output logic [6:0] HEX);

	/*
		TOP = 0
		TOP RIGHT = 1
		BOTTOM RIGHT = 2
		BOTTOM = 3
		BOTTOM LEFT = 4
		TOP LEFT = 5
		MIDDLE = 6
	*/


	assign HEX  = (val == 4'hF) ? 7'0001110 :
				  (val == 4'hE) ? 7'0000110 :
				  (val == 4'hD) ? 7'0100001 :
				  (val == 4'hC) ? 7'1000110 :
				  (val == 4'hB) ? 7'0000011 :
				  (val == 4'hA) ? 7'0001000 :
				  (val == 4'h9) ? 7'0011000 : 
				  (val == 4'h8) ? 7'0000000 :
				  (val == 4'h7) ? 7'1111000 :
				  (val == 4'h6) ? 7'0000011 :
				  (val == 4'h5) ? 7'0010010 :
				  (val == 4'h4) ? 7'0011001 :
				  (val == 4'h3) ? 7'0110000 :
				  (val == 4'h2) ? 7'0100100 :
				  (val == 4'h1) ? 7'1111001 :
				  (val == 4'h0) ? 7'1000000 ;

endmodule
