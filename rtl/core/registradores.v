/********************* Special Registers *************************

                    Register 0   ----> zero
                    Register 1  ----> output register
                    Register 2  ----> input register
                    Register 3  ----> config register

******************************************************************/

module registradores(
    src1, src2, dest, wrt_data, out1, out2, clk, reg_write, input_value, output_value, config_value, input_debug, sp, fp
);


input [4:0] src1, src2, dest;
input [31:0] wrt_data, input_value;
input clk, reg_write;

output [31:0] out1, out2, output_value, config_value, input_debug, sp, fp;
// voltar para 32 registradores
reg [31:0] registers [31:0] /* synthesis preserve */; 
integer i;
initial 
	begin
		for(i = 0; i<=31; i = i+1)begin
			registers[i] = 32'b0;
		end
		registers[1] = 32'b11101011111111;
	end

always @(posedge clk ) begin
    if(reg_write) 
        registers[dest] <= wrt_data;
    registers[2] <= input_value;

end

assign out1 = (src1 == 4'b0) ? 32'b0 : registers[src1];
assign out2 = (src2 == 4'b0) ? 32'b0 : registers[src2];

/******************** Output reserved Registers ***************************/
assign input_debug = registers[2];
assign output_value = registers[1];
assign config_value = registers[3];
assign sp = registers[30];
assign fp = registers[29];

endmodule //registradores