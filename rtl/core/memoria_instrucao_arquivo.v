module memoria_instrucao_arquivo 
#(
	parameter ADDRESS_WIDTH=10
)(
    clk, endereco, saida, reset
);  
    input clk, reset;
    input [ADDRESS_WIDTH-1:0] endereco;
    output [31:0] saida;
    // aumentar o número de instruções
    reg [31:0] instrucoes [2**(ADDRESS_WIDTH-1):0];
	
		initial begin
		
			$readmemb("init.txt", instrucoes);
		end
assign saida = instrucoes[endereco];
endmodule
