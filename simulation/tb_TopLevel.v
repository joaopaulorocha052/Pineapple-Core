`timescale 1ns/1ps
module tb_TopLevel;

    reg CLOCK_50;
    reg [0:10] V_SW;

    wire [0:9] G_LEDR;
    wire [0:8] G_LEDG;
    wire [6:0] HEX1, HEX2, HEX3, HEX4;

    TopLevel DUT (
        .CLOCK_50(CLOCK_50),
        .V_SW(V_SW),
        .G_LEDR(G_LEDR),
        .G_LEDG(G_LEDG),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4)
    );

    initial CLOCK_50 = 1'b0;
    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        V_SW = 11'b0;
        V_SW[0] = 1'b0;   
        #10;
        V_SW[1] = 1'b1;   // Reset ativo
        V_SW[10] = 1'b0;
        V_SW[2] = 1'b1;
        #10;
        V_SW[10] = 1'b1;
        V_SW[2] = 1'b0;
        #10;
        V_SW[10] = 1'b0;
        V_SW[2] = 1'b1;

        #100;             
        V_SW[1] = 1'b0;   // Libera o reset para a CPU executar
        #20;
        V_SW[0] = 1'b1;
    end

    // Monitoramento automático do Boot
    initial begin
        $display("\n=======================================================");
        $display("   MONITORAMENTO DE BOOT: BIOS (0x200) -> IRAM (0x000)  ");
        $display("=======================================================");
        $monitor("Tempo: %0t ns | PC: 0x%0h | Região: %s | Instrução: %h",
                 $time,
                 DUT.CPU.end_instrucao,
                 (DUT.CPU.end_instrucao[9] ? "BIOS" : "IRAM"),
                 DUT.CPU.instrucao);
    end

    initial begin
        #1000;
        $stop;
    end

endmodule