module SignExtend (input [15:0] imediato, output [31:0] imediato_extendido);


	assign imediato_extendido = {16'b0, imediato};
endmodule