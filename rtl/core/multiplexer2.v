module multiplexer2(in1, in2, select, out);
	input[31:0] in1, in2;
	input select;
	output reg [31:0] out;
	
	always@(*)
		begin
			if(select == 1'b0)
				out = in1;
			else
				out = in2;
		end	
	

endmodule