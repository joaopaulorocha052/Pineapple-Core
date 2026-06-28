
`timescale 1ns/1ps
module tb_TopLevel;

    reg CLOCK_50;
    reg [0:9] V_SW;

    wire [0:9] G_LEDR;
    wire [0:8] G_LEDG;
    wire [6:0] HEX1, HEX2, HEX3, HEX4;
    wire [31:0] sp_test, fp_test, mem_test, teste_apocal;

    // -------------------------------------------------------------------
    // Instancia o projeto completo
    // -------------------------------------------------------------------
    TopLevel DUT (
        .CLOCK_50(CLOCK_50),
        .V_SW(V_SW),
        .G_LEDR(G_LEDR),
        .G_LEDG(G_LEDG),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .sp_test(sp_test),
        .fp_test(fp_test),
        .mem_test(mem_test)
    );


    initial CLOCK_50 = 1'b0;
    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        V_SW = 10'b0000000000;
        V_SW[0] = 1'b0;   // habilita o FrequencyDivider desde o tempo 0
        V_SW[1] = 1'b1;   // reset ATIVO inicialmente

        #100;             // mantem reset por 100ns (5 periodos de CLOCK_50)
        V_SW[1] = 1'b0;   // libera o reset -- processador comeca a executar
        #20
        V_SW[0] = 1'b1;
    end

       // controle_de_entradas
    always @(posedge tb_TopLevel.DUT.IoModule.halt_flag) begin
        V_SW[3:9] = 7'd6;
        #20
        V_SW[2] = 1'b1;
        #20
        V_SW[2] = 1'b0;
    end

    always @(teste_apocal or G_LEDR or sp_test or fp_test) begin
        $display("%8t |   %b   |             %d              |        %d           |   %d   |   %d",
                  $time, V_SW[1], teste_apocal, G_LEDR[6:9], sp_test, fp_test);
    end

    initial begin
        #50000; // 50us
        $stop;
    end

endmodule