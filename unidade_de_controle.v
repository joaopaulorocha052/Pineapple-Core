module unidade_de_controle(
    instrucao, reg_write, select, dest, src1, src2, shiftAmnt, instr_type, end_jump, i_jump, sign_extend, extended_immediate, ram_write, mem_to_reg, is_jal
);

// `include "../params/opcodes.vh"

input [31:0] instrucao;

output reg reg_write, sign_extend, ram_write, mem_to_reg, is_jal;

output reg [4:0] dest, src1, src2, select, shiftAmnt, instr_type;

output reg [25:0] end_jump, i_jump; 

output reg [15:0] extended_immediate;

	always @ (instrucao) begin
		 case(instrucao[31:26])
			//   5'b00000 : // Tipo R
			6'b000000:
				begin
					select =instrucao[5:0];
					src1 =instrucao[25:21];
					src2 =instrucao[20:16];
					dest =instrucao[15:11];
					shiftAmnt =instrucao[10:6];
					instr_type =6'b000000;
					reg_write =1'b1;
					end_jump =5'b0;
					i_jump =5'b0;
					sign_extend=1'b0;
					extended_immediate=16'b0;
					ram_write = 1'b0;
					mem_to_reg = 1'b0;
					is_jal = 1'b0;
				end
			6'b000001: //Tipo Jump
				begin
					select =6'b0;
					src1 =6'b0;
					src2 =6'b0;
					shiftAmnt =6'b0;
					dest =6'b0;
					instr_type =6'b000001;
					reg_write =1'b0;
					end_jump =instrucao[25:0];
					i_jump =5'b0;
					sign_extend=1'b0;
					extended_immediate=16'b0;
					ram_write = 1'b0;
					mem_to_reg = 1'b0;
					is_jal = 1'b0;
				end
					
			6'b000010: //JR
				begin
					select =6'b0;
					src1 =instrucao[4:0];
					src2 =6'b0;
					shiftAmnt =6'b0;
					dest =6'b0;
					instr_type =6'b000001;
					reg_write =1'b0;
					end_jump =5'b0;
					i_jump =5'b0;
					sign_extend=1'b0;
					extended_immediate=16'b0;
					ram_write = 1'b0;
					mem_to_reg = 1'b0;
					is_jal = 1'b0;
				end
				
			6'b000100: //is_jal
				begin
					select =6'b0;
					src1 =6'b0;
					src2 =6'b0;
					shiftAmnt =6'b0;
					// CORRECAO: era dest=6'd24, mas todo o compilador
					// (asm_gen.h: RETURN_ADDRESS_POINTER=31) e o assembly
					// gerado (SW RA,FP(1) apos o JAL) esperam que o
					// endereco de retorno seja gravado em R31 (RA), nao
					// em R24 -- ninguem nunca lia R24 de volta, entao RA
					// ficava sempre no valor de reset (0).
					dest =6'd31;
					instr_type =6'b000100;
					reg_write =1'b1;
					end_jump =instrucao[25:0];
					i_jump =5'b0;
					sign_extend=1'b0;
					extended_immediate=16'b0;
					ram_write = 1'b0;
					mem_to_reg = 1'b0;
					is_jal = 1'b1;
				end

			6'b000101: //LW
				begin
					select =5'b0;
					src1 =instrucao[20:16];
					src2 =5'b0;
					dest =instrucao[25:21];
					shiftAmnt =instrucao[10:6];
					instr_type =6'b000101;
					reg_write =1'b1;
					end_jump =5'b0;
					i_jump =5'b0;
					sign_extend=1'b1;
					extended_immediate=instrucao[15:0];
					ram_write = 1'b0;
					mem_to_reg = 1'b1;
					is_jal = 1'b0;
				end
			6'b000110: //Tipo Store
				begin
					select =5'b0;
					src1 =instrucao[20:16];
					src2 =instrucao[25:21];
					dest =5'b0;
					shiftAmnt =instrucao[10:6];
					instr_type =6'b000110;
					reg_write =1'b0;
					end_jump =5'b0;
					i_jump =5'b0;
					sign_extend=1'b1;
					extended_immediate=instrucao[15:0];
					ram_write = 1'b1;
					mem_to_reg = 1'b0;
					is_jal = 1'b0;
				end
			6'b000011: //beq
				begin
					select =5'b111;
					src1 =instrucao[25:21];
					src2 =instrucao[20:16];
					dest =5'b0;
					shiftAmnt =instrucao[10:6];
					instr_type =6'b00011;
					reg_write =1'b0;
					end_jump =instrucao[15:0];
					i_jump =5'b0;
					sign_extend=1'b0;
					extended_immediate=16'b0;	
					ram_write = 1'b0;
					mem_to_reg = 1'b0;
					is_jal = 1'b0;
				end
			6'b001010: //addi
				begin
					select =6'b0;
					src1 =instrucao[25:21];
					src2 =5'b0;
					shiftAmnt =instrucao[10:6];
					dest =instrucao[20:16];
					instr_type =5'b01010;
					reg_write =1'b1;
					end_jump =5'b0;
					i_jump =5'b0;
					sign_extend=1'b1;
					extended_immediate=instrucao[15:0];
					ram_write = 1'b0;
					mem_to_reg = 1'b0;
					is_jal = 1'b0;
				end
			6'b001011: //subi
				begin
					select =6'b1;
					src1 =instrucao[25:21];
					src2 =5'b0;
					dest =instrucao[20:16];
					shiftAmnt =instrucao[10:6];
					instr_type =5'b01011;
					reg_write =1'b1;
					end_jump =5'b0;
					i_jump =5'b0;
					sign_extend=1'b1;
					extended_immediate=instrucao[15:0];
					ram_write = 1'b0;
					mem_to_reg = 1'b0;
					is_jal = 1'b0;
				end
			default: 
				begin
					select =5'b0;
					src1 =5'b0;
					src2 =5'b0;
					shiftAmnt =5'b0;
					dest =5'b0;
					instr_type =5'b11111;
					reg_write =5'b0;
					end_jump =5'b0;
					i_jump =5'b0;
					sign_extend=1'b0;
					ram_write = 1'b0;
					mem_to_reg = 1'b0;
					is_jal = 1'b0;

				end
		 endcase
		 
	end

endmodule