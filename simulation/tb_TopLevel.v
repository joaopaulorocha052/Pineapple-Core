
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
        .HEX4(HEX4)
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

    integer i;
    integer INPUT_ARRAY [0:9];
    initial i = 0;

    initial begin
        INPUT_ARRAY[0] = 5;
	INPUT_ARRAY[1] = 2;
	INPUT_ARRAY[2] = 10;
	INPUT_ARRAY[3] = 4;
	INPUT_ARRAY[4] = 3;
	INPUT_ARRAY[5] = 1;
	INPUT_ARRAY[6] = 6;
	INPUT_ARRAY[7] = 8;
	INPUT_ARRAY[8] = 9;
	INPUT_ARRAY[9] = 7;
    end
       // controle_de_entradas
    always @(posedge tb_TopLevel.DUT.IoModule.halt_flag) begin
        V_SW[3:9] = INPUT_ARRAY[i];
        #20
        V_SW[2] = 1'b1;
        #50
        V_SW[2] = 1'b0;

        i = i + 1;
    end

    always @(G_LEDG) begin
        $display("%8t|   %d",
                  $time, {G_LEDG[0], G_LEDG[1], G_LEDG[2], G_LEDG[3], G_LEDG[4], G_LEDG[5], G_LEDG[6]});
    end

    initial begin
        #100000; // 50us
        $stop;
    end

endmodule