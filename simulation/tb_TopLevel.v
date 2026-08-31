
`timescale 1ns/1ps
module tb_TopLevel;

    reg CLOCK_50;
    reg [0:10] V_SW;

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
        #10
        V_SW[1] = 1'b1;   // reset ATIVO inicialmente
        V_SW[10] = 1'b0;
        V_SW[2] = 1'b1;
        #10
        V_SW[10] = 1'b1;
        V_SW[2] = 1'b0;
        #10
        V_SW[10] = 1'b0;
        V_SW[2] = 1'b1;

        #100;             // mantem reset por 100ns (5 periodos de CLOCK_50)
        V_SW[1] = 1'b0;   // libera o reset -- processador comeca a executar
        #20
        V_SW[0] = 1'b1;
    end

    integer i;
    integer INPUT_ARRAY [0:2];
    initial i = -1;

    initial begin
        INPUT_ARRAY[0] = 1;
        INPUT_ARRAY[1] = 2;
        INPUT_ARRAY[2] = 3;
    end

        // initial begin
        //     INPUT_ARRAY[0] = 5;
        //     INPUT_ARRAY[1] = 2;
        //     INPUT_ARRAY[2] = 5;
        //     INPUT_ARRAY[3] = 12;
        //     INPUT_ARRAY[4] = 8;
        //     INPUT_ARRAY[5] = 15;
        //     INPUT_ARRAY[6] = 15;
        //     INPUT_ARRAY[7] = 3;
        //     INPUT_ARRAY[8] = 20;
        //     INPUT_ARRAY[9] = 19;
        //     INPUT_ARRAY[10] = 25;
        //     INPUT_ARRAY[11] = 1;
        //     INPUT_ARRAY[12] = 30;
        //     INPUT_ARRAY[13] = 42;
        //     INPUT_ARRAY[14] = 42;
        //     INPUT_ARRAY[15] = 10;
        //     INPUT_ARRAY[16] = 50;
        //     INPUT_ARRAY[17] = 7;
        //     INPUT_ARRAY[18] = 60;
        //     INPUT_ARRAY[19] = 55;
        //     INPUT_ARRAY[20] = 75;
        //     INPUT_ARRAY[21] = 80;
        //     INPUT_ARRAY[22] = 12;
        //     INPUT_ARRAY[23] = 90;
        //     INPUT_ARRAY[24] = 99;
        // end
       // controle_de_entradas
    always @(posedge tb_TopLevel.DUT.IoModule.halt_flag) begin
        V_SW[3:9] = INPUT_ARRAY[i];
        #20
        V_SW[2] = 1'b0;
        #50
        V_SW[2] = 1'b1;

        i = i + 1;
    end

    always @(teste_apocal or G_LEDR or sp_test or fp_test) begin
        $display("%8t |   %b   |             %d              |        %d           |   %d   |   %d",
                  $time, V_SW[1], teste_apocal, G_LEDR[6:9], sp_test, fp_test);
    end

    initial begin
        #500000; // 50us
        $stop;
    end

endmodule