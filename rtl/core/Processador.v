module Processador (CLOCK_50, _mem_clock,teste, reset, halt_flag, reset_config_flag, input_value, output_value, config_value, teste_end, teste, input_debug, teste_apocal, sp_test, fp_test);

// `include "../params/opcodes.vh"

/*********************** MAPA DE MEMORIA ***********************
 * Fetch (PC, 10 bits):
 *   0x000 - 0x1FF : memoria de instrucao (iram, 512 palavras)
 *   0x200 - 0x3FF : BIOS ROM (bit 9 do PC = 1)
 *
 * Load/Store (endereco calculado pela ULA):
 *   0x000 - 0x1FF : escrita na iram
 *   0x200 - 0x2FF : reservado (escrita ignorada)
 *   0x300 - 0x4FF : RAM de dados (512 palavras, indice = addr - 0x300)
 *
 * O compilador deve usar -d 300 (ou outro valor em 0x300..0x4FF)
 * como endereco base de dados.
 ***************************************************************/
localparam [31:0] IRAM_END  = 32'h0000_0200; // primeiro endereco apos a iram
localparam [31:0] DRAM_BASE = 32'h0000_0300;
localparam [31:0] DRAM_END  = 32'h0000_0500; // primeiro endereco apos a dram

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
output [9:0] teste_end;



wire [8:0] fetch_local_addr;
wire [31:0] bios_instruction, iram_instruction;

addr_decoder fetch_instr_decoder(.instr_address(end_instrucao),
                                .bios_instr(bios_instruction),
                                .iram_instr(iram_instruction),
                                .local_addr(fetch_local_addr),
                                .fetch_instr(instrucao)
                                );

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
		   
bios_rom u_bios (.addr(fetch_local_addr),
                .clk(~CLOCK_50),
                .q(bios_instruction)
                );

/************************ Decodificacao de enables ************************/
// Faixas explicitas (antes: <= 0x200 e >= 0x300, sem limite superior).
wire iram_enable, dram_enable;

assign iram_enable = wram_write && (ULA_result <  IRAM_END);
assign dram_enable = wram_write && (ULA_result >= DRAM_BASE) && (ULA_result < DRAM_END);

/************************ Memoria de instrucao (iram) ************************/
// Dual-port: leitura pelo PC (fetch) e escrita pela ULA (sw).
// Antes, a iram era single-port e seu endereco era sempre ULA_result,
// entao o fetch nunca lia a instrucao apontada pelo PC.
// A leitura usa ~CLOCK_50, igual a BIOS ROM: o dado fica pronto na
// metade do ciclo, antes da decodificacao/ULA e do proximo posedge.
memoria_ram #(.DATA_WIDTH(32), .ADDR_WIDTH(9)) iram (
                     .data(ula_2),
                     .read_addr(fetch_local_addr),
                     .write_addr(ULA_result[8:0]),
                     .we(iram_enable),
                     .read_clock(~CLOCK_50),
                     .write_clock(CLOCK_50),
                     .q(iram_instruction));

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

/************************ Memoria de dados ************************/
// Indice = ULA_result - 0x300, usando os 9 bits (512 palavras).
// Antes: {0, ULA_result[7:0]} (concatenacao sem tamanho, so 256 palavras).
wire [31:0] dram_offset = ULA_result - DRAM_BASE;

memoria_ram #(.DATA_WIDTH(32), .ADDR_WIDTH(9)) ram(
                .data(ula_2),
                .read_addr(dram_offset[8:0]),
                .write_addr(dram_offset[8:0]),
                .we(dram_enable),
                .read_clock(_mem_clock),
                .write_clock(CLOCK_50),
                .q(_mem_output)
                );

endmodule