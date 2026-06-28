module ULA (op1, op2, select, out, shiftAmnt);


input [31:0] op1, op2;
input [4:0] shiftAmnt;
input  [4:0] select;
reg [31:0] result;
output [31:0] out;


assign out = result;
always @(*) begin
    
    case(select)
            5'b00000 : result = op1 + op2;
            5'b00001 : result = op1 - op2;
            5'b00010 : result = op1 * op2;
            5'b00011 : result = op1 / op2;
            5'b00100 : result = op1 << shiftAmnt;
            5'b00101 : result = op1 && op2;
            5'b00110 : result = op1 || op2;
            5'b00111 : result = op1 == op2;
            5'b01000 : result = op1 != op2;
            5'b01001 : result = (op1 >  op2) ? 1 : 0; // MAIOR   (>)
            5'b01010 : result = (op1 >= op2) ? 1 : 0; // MAIOR_Q (>=)
            5'b01011 : result = (op1 <  op2) ? 1 : 0; // MENOR   (<)
            5'b01100 : result = (op1 <= op2) ? 1 : 0; // MENOR_Q (<=)
            default: result = 32'b0;
    endcase
    
   
end
endmodule