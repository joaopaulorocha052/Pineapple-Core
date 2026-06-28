module pc (end_jump, i_jump, tipo, destino_instrucao, clock, reset, jal_current_inst
);


input  [4:0] i_jump, tipo;
input [9:0] end_jump;
output reg [8:0] destino_instrucao; 
// REIMPLEMENTACAO DO JAL: jal_current_inst agora e nativamente 32 bits,
// em vez de [7:0]. Antes, esse wire de 8 bits alimentava uma porta de
// 32 bits do multiplexer2 (jal_or_registers em Processador.v), exigindo
// zero-extensao implicita na conexao da instancia -- eliminamos essa
// extensao implicita calculando os 32 bits aqui mesmo, na origem.
output [31:0] jal_current_inst;
input clock, reset;

assign jal_current_inst = {24'b0, destino_instrucao} + 32'd1;

always @ (posedge clock or posedge reset) begin
      if (reset) begin

        destino_instrucao <= 8'b0;

      end else begin

        case (tipo)
            5'b00000: destino_instrucao <= destino_instrucao + 1; //Tipo R e I
          5'b01010: destino_instrucao <= destino_instrucao + 1; //Tipo R e I
          5'b01011: destino_instrucao <= destino_instrucao + 1; //Tipo R e I
          5'b00110: destino_instrucao <= destino_instrucao + 1; //Tipo R e I
          5'b00101: destino_instrucao <= destino_instrucao + 1; //LW -- antes caia no default, agora explicito
          5'b00001: destino_instrucao <=  end_jump; //Tipo J - end (JUMP comum E JR, ver unidade_de_controle.v: JR usa instr_type=5'b00001 tambem -- end_jump aqui ja recebe wjump_val, que o Processador.v ja seleciona corretamente entre o imediato e ula_1 via wis_jr)
          5'b00011: destino_instrucao <= end_jump; //BEQ caso seja igual
          5'b11111: destino_instrucao <= destino_instrucao;
			 5'b00100: destino_instrucao <= end_jump;
          default: destino_instrucao <= destino_instrucao + 1; //Tipo R
        endcase  
          
      end
      

    end
endmodule
