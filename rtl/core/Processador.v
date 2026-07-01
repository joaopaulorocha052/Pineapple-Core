module Processador (CLOCK_50, _mem_clock,teste, reset, halt_flag, reset_config_flag, input_value, output_value, config_value, teste_end, teste, input_debug, teste_apocal, sp_test, fp_test);

// `include "../params/opcodes.vh"

wire [31:0] _mem_output;
input _mem_clock;
wire clk, div_clock;
wire [9:0] end_instrucao;
wire [31:0] wjal_current_inst;
wire [31:0] instrucao, ULA_result, ula_1, ula_2, wim, wim_ex, wula_im;
wire [4:0] type, wselect, wdest, wsrc1, wsrc2, wshift, wi_jump, wsign_extend, wtype;
wire [9:0] wend_jump;
input CLOCK_50, reset, halt_flag, reset_config_flag;
input [31:0] input_value;
output [31:0] output_value, config_value, teste, input_debug, teste_apocal, sp_test, fp_test;
wire wreg_write, wram_write, _mem_to_reg, wis_jal;
output [8:0] teste_end;


unidade_de_controle control(.instrucao(instrucao), 
                            .reg_write(wreg_write), 
                            .select(wselect), 
                            .dest(wdest), 
                            .src1(wsrc1), 
                            .src2(wsrc2), 
                            .shiftAmnt(wshift), 
                            .instr_type(type), 
                            .end_jump(wend_jump), 
                            .i_jump(wi_jump),
                            .sign_extend(wsign_extend),
                            .extended_immediate(wim),
                            .ram_write(wram_write),
                            .mem_to_reg(_mem_to_reg),
									 .is_jal(wis_jal)
                            );
// TODO: revisar essa parte
wire [4:0]wpc_mult_select;
wire wupdated;

assign teste_end = end_instrucao;
// DESCOMENTAR ESSA PARTE!!!!!!!!

assign wpc_mult_select = (type == 5'b00011) ? (ULA_result == 1) ? type : 5'b0 : type;
assign wupdated = wpc_mult_select ? 1'b0 : 1'b1;


wire [4:0] _inst_type;
multiplexer2 halt_check(.in1(wpc_mult_select),
                        .in2(5'b11111),
                        .select(halt_flag),
                        .out(_inst_type)
);

wire wis_jr;
assign wis_jr = (instrucao[31:26] == 5'b00010) ?  1'b1 : 1'b0;

wire [9:0] wjump_val;

multiplexer2 reg_or_im(
								.in1(wend_jump),
								.in2(ula_1),
								.select(wis_jr),
								.out(wjump_val)
);
pc pc(.end_jump(wjump_val), 
		.i_jump(5'b0), //jump instr
		.tipo(_inst_type), 
		.destino_instrucao(end_instrucao), 
		.clock(CLOCK_50),
        .reset(reset),
		  .jal_current_inst(wjal_current_inst));
		  


memoria_instrucao_arquivo mem_instr (.clk(CLOCK_50), .endereco(end_instrucao), .saida(instrucao), .reset(reset));

// REIMPLEMENTACAO DO JAL: antes, dois multiplexer2 em cascata decidiam
// o valor final escrito no banco de registradores (ULA-vs-memoria,
// depois isso-vs-JAL) -- dois estagios combinacionais em serie. Agora
// um unico multiplexer3 resolve as 3 possibilidades de uma vez,
// reduzindo a profundidade logica e centralizando a decisao num so
// lugar. wis_jal tem prioridade sobre _mem_to_reg (JAL nunca le
// memoria, entao essa prioridade nunca causa ambiguidade real).
wire [2:0] wfinal_select;
assign wfinal_select = wis_jal ? 3'b010 : (_mem_to_reg ? 3'b001 : 3'b000);

wire [31:0] wfinal_value;
multiplexer3 valor_final(
                            .in1(ULA_result),
                            .in2(_mem_output),
                            .in3(wjal_current_inst),
                            .select(wfinal_select),
                            .out(wfinal_value)
                            );

registradores registradores(.src1(wsrc1), //1
                            .src2(wsrc2), //0
                            .dest(wdest), //0
                            .wrt_data(wfinal_value),
                            .out1(ula_1),
                            .out2(ula_2),
                            .clk(CLOCK_50),
                            .reg_write(wreg_write),
                            .input_value(input_value),
                            .output_value(output_value), 
                            .config_value(config_value),
                            .input_debug(input_debug),
									 .sp(sp_test),
									 .fp(fp_test)
                            );
									 

SignExtend SignExtend(.imediato(wim), 
							 .imediato_extendido(wim_ex));

multiplexer2 ula_mult(.in1(ula_2), 
						 .in2(wim_ex), 
						 .select(wsign_extend), 
						 .out(wula_im));

ULA ULA (.op1(ula_1), 
			.op2(wula_im), 
			.select(wselect), 
			.shiftAmnt(wshift), 
			.out(ULA_result));


memoria_ram ram(.data(ula_2),
                .read_addr(ULA_result),
                .write_addr(ULA_result),
                .we(wram_write),
                .read_clock(_mem_clock),
                .write_clock(CLOCK_50),
                .q(_mem_output)
                );

endmodule