module multiplexer3(in1, in2, in3, select, out);
	input[31:0] in1, in2, in3;
	input [2:0] select;
	output reg [31:0] out;
	
	always@(*)
		begin
			case(select)
				
					3'b000: out = in1;
					3'b001: out = in2;
					3'b010: out = in3;
					default:out = in1;
			endcase
		end	
	

endmodule