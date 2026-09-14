`include "constants.vh"

/* Funcionamento do ADDR_DECODER */
/* O addr decoder identifica qual memória está sendo utilizada a partir dos bits mais significativos */
/* do endereço. */
/* Possui duas operacoes disitintas: */
/* 1) Decodificar o endereco de fetch entre BIOS ROM e Memoria de Instrucao */
/* 2) Decoficar memoria de leitura e escrita entre os outros periféricos de memória */

module addr_decoder (
    // fetch related data
    input [`INST_ADDR_WIDTH-1:0] instr_address,
    input [31:0] bios_instr,
    input [31:0] iram_instr,
    output [`INST_ADDR_WIDTH-2:0] local_addr,
    output [31:0] fetch_instr    
);
    


    wire bios_selector = instr_address[`INST_ADDR_WIDTH-1];

    assign local_addr = instr_address[`INST_ADDR_WIDTH-2:0];


    assign fetch_instr = bios_selector ? bios_instr : 
                        iram_instr;
endmodule