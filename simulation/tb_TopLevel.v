`timescale 1ns/1ps
module tb_TopLevel;

    reg CLOCK_50;
    reg [0:10] V_SW;

    wire [0:9] G_LEDR;
    wire [0:8] G_LEDG;
    wire [6:0] HEX1, HEX2, HEX3, HEX4;
    wire [12:0] LCD_BUS;

    TopLevel DUT (
        .CLOCK_50(CLOCK_50),
        .V_SW(V_SW),
        .G_LEDR(G_LEDR),
        .G_LEDG(G_LEDG),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .LCD_BUS(LCD_BUS)
    );

    // Opcodes (ver unidade_de_controle.v)
    localparam [5:0] OP_JUMP = 6'h01, OP_JR = 6'h02, OP_JAL = 6'h04,
                     OP_LW   = 6'h05, OP_SW = 6'h06, OP_HALT = 6'h3F;

    // Habilita/desabilita o trace de cada instrucao (gera muito log)
    localparam TRACE_PC = 0;

    initial CLOCK_50 = 1'b0;
    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        V_SW = 11'b0;
        V_SW[0] = 1'b0;
        #10;
        V_SW[1] = 1'b1;   // Reset ativo
        V_SW[10] = 1'b0;
        V_SW[2] = 1'b0;   // enter desativado (0)
        #10;
        V_SW[10] = 1'b1;
        #10;
        V_SW[10] = 1'b0;

        #100;
        V_SW[1] = 1'b0;   // Libera o reset para a CPU executar
        #20;
        V_SW[0] = 1'b1;
    end

    integer i;
    integer INPUT_ARRAY [0:10];
    initial i = 0;

    initial begin
        INPUT_ARRAY[0] = 16;
        INPUT_ARRAY[1] = 64;
        INPUT_ARRAY[2] = 42;
        INPUT_ARRAY[3] = 69;
        INPUT_ARRAY[4] = 42;
        INPUT_ARRAY[5] = 1;
        INPUT_ARRAY[6] = 3;
        INPUT_ARRAY[7] = 5;
        INPUT_ARRAY[8] = 89;
        INPUT_ARRAY[9] = 9;
    end

    always @(posedge tb_TopLevel.DUT.IoModule.halt_flag) begin
        V_SW[3:9] = INPUT_ARRAY[i];
        repeat (2) @(posedge DUT._clk);
        V_SW[2] = 1'b0;               // Garante enter em nível baixo (0)
        repeat (3) @(posedge DUT._clk);
        V_SW[2] = 1'b1;               // Borda de subida (0 -> 1): limpa a halt_flag no IO.v
        repeat (3) @(posedge DUT._clk);
        V_SW[2] = 1'b0;               // Retorna enter para nível baixo (0)
        repeat (3) @(posedge DUT._clk);
        $display("%0t [INPUT] #%0d = %0d enviado", $time, i, INPUT_ARRAY[i]);
        i = i + 1;
    end

    /*********************** Monitoramento ***********************/

    // Trace opcional: PC, regiao e instrucao a cada ciclo da CPU
    always @(posedge DUT.CPU.CLOCK_50)
        if (TRACE_PC && !DUT.CPU.reset)
            $display("%0t | PC=0x%03h (%s) | instr=%h",
                     $time, DUT.CPU.end_instrucao,
                     (DUT.CPU.end_instrucao[9] ? "BIOS" : "IRAM"),
                     DUT.CPU.instrucao);

    // Escritas: RAM de dados e iram
    always @(posedge DUT.CPU.CLOCK_50) begin
        if (DUT.CPU.dram_enable)
            $display("%0t [SW dram] PC=0x%03h addr=0x%03h ram[%0d] <= 0x%h",
                     $time, DUT.CPU.end_instrucao, DUT.CPU.ULA_result,
                     DUT.CPU.dram_offset[8:0], DUT.CPU.ula_2);
        if (DUT.CPU.iram_enable)
            $display("%0t [SW iram] PC=0x%03h addr=0x%03h iram[%0d] <= 0x%h",
                     $time, DUT.CPU.end_instrucao, DUT.CPU.ULA_result,
                     DUT.CPU.ULA_result[8:0], DUT.CPU.ula_2);
        // SW que nao atingiu nenhuma memoria (faixa 0x200-0x2FF ou >= 0x500)
        if (DUT.CPU.wram_write && !DUT.CPU.dram_enable && !DUT.CPU.iram_enable)
            $display("%0t [AVISO] SW perdido: PC=0x%03h addr=0x%h",
                     $time, DUT.CPU.end_instrucao, DUT.CPU.ULA_result);
    end

    // Leituras: valor que o registrador vai capturar
    always @(posedge DUT.CPU.CLOCK_50)
        if (!DUT.CPU.reset && DUT.CPU.instrucao[31:26] == OP_LW)
            $display("%0t [LW]     PC=0x%03h addr=0x%03h -> dest=R%0d dado=0x%h",
                     $time, DUT.CPU.end_instrucao, DUT.CPU.ULA_result,
                     DUT.CPU.wdest, DUT.CPU._mem_output);

    // Saltos: JUMP / JAL / JR (o JR mostra o RA lido do registrador)
    always @(posedge DUT.CPU.CLOCK_50)
        if (!DUT.CPU.reset) begin
            if (DUT.CPU.instrucao[31:26] == OP_JUMP)
                $display("%0t [JUMP]   PC=0x%03h -> 0x%03h",
                         $time, DUT.CPU.end_instrucao, DUT.CPU.wend_jump);
            if (DUT.CPU.instrucao[31:26] == OP_JAL)
                $display("%0t [JAL]    PC=0x%03h -> 0x%03h (RA=0x%03h)",
                         $time, DUT.CPU.end_instrucao, DUT.CPU.wend_jump,
                         DUT.CPU.wjal_current_inst);
            if (DUT.CPU.instrucao[31:26] == OP_JR) begin
                $display("%0t [JR]     PC=0x%03h -> 0x%03h (R%0d)",
                         $time, DUT.CPU.end_instrucao, DUT.CPU.ula_1, DUT.CPU.wsrc1);
                // Retorno para fora da regiao esperada? (o bug original)
                if (DUT.CPU.ula_1[9] == 1'b0)
                    $display("%0t [ERRO]   JR retornou para a IRAM (0x%03h): RA zerado/incorreto",
                             $time, DUT.CPU.ula_1);
            end
        end

    // Saida do programa
    reg [31:0] last_output;
    initial last_output = 0;
    always @(DUT._output)
        if (DUT._output !== last_output) begin
            last_output = DUT._output;
            $display("%0t [OUTPUT] %0d (0x%h)", $time, DUT._output, DUT._output);
        end

    // Fim do programa: instrucao HALT na CPU em execucao
    integer k;
    always @(posedge DUT.CPU.CLOCK_50)
        if (!DUT.CPU.reset && DUT.CPU.instrucao[31:26] == OP_HALT) begin
            $display("\n%0t HALT encontrado em PC=0x%03h", $time, DUT.CPU.end_instrucao);
            dump_ram;
            $stop;
        end

    task dump_ram;
        begin
            $display("---- RAM de dados (ram[0..15] = 0x300..0x30F) ----");
            for (k = 0; k < 16; k = k + 1)
                $display("ram[%0d] (0x%03h) = 0x%h (%0d)", k, 16'h300 + k,
                         DUT.CPU.ram.ram[k], DUT.CPU.ram.ram[k]);
            $display("---- SP=0x%h FP=0x%h ----", DUT.CPU.sp_test, DUT.CPU.fp_test);
        end
    endtask

    initial begin
        $display("\n=======================================================");
        $display("   TESTE: BIOS (0x200) -> RAM de dados (0x300)          ");
        $display("=======================================================");
    end

    // Timeout: com _clk ~8,3 MHz (FREQ_HZ = 10_000_000) cada instrucao leva ~120 ns
    initial begin
        #800000000;   // 20 ms
        $display("\n[TIMEOUT] fim da simulacao sem encontrar HALT");
        dump_ram;
        $stop;
    end

endmodule