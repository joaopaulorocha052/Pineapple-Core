
module TopLevel (
    input CLOCK_50,
    input [0:9] V_SW,
    output [0:9] G_LEDR,
    output [0:8] G_LEDG,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4//,
	//  output [31:0] sp_test,
	//  output [31:0] fp_test,
	//  output [31:0] mem_test
);


    assign G_LEDG[7] = V_SW[0];
    wire _halt_flag, _reset_config_flag, _clk;

    wire [31:0] _input, _config, _output, _teste, _teste_end, _bcd, lixo, _extended_input;
    wire [6:0] _hex1 , _hex2, _hex3, _hex4;

   //wire [31:0] sp_test, fp_test, mem_test, teste_apocal;

    FrequencyDivider fdiv (.in_clk(CLOCK_50), .out_clk(_clk), .en(V_SW[0]));
    IO IoModule (.clk(_clk),
                  .output_value_register(_output),
                  .input_value_register(_input),
                  .io_config(_config),
                  .enter(V_SW[2]), 
                  .halt_flag(_halt_flag),
                    /*input and output pins*/
                  .input_value(lixo), 
                  .output_value(output_pins),
                  .reset(V_SW[1]),
                  .reset_config_flag(_reset_config_flag)
                  );
   SignExtend extends_input_value(.imediato(V_SW[3:9]), .imediato_extendido(_extended_input));
   

    Processador CPU (.CLOCK_50(_clk), 
                     ._mem_clock(CLOCK_50), 
                     .reset(V_SW[1]), 
                     .halt_flag(_halt_flag),
                     .input_value({25'b0, V_SW[3:9]}),
                     .config_value(_config),
                     .output_value(_output),
                     .reset_config_flag(_reset_config_flag),
                     .teste_end(_teste_end),
                     .input_debug(G_LEDR[0:5])//,
							// .sp_test(sp_test),
							// .fp_test(fp_test)
                     );
    Binary_to_BCD bin2bcd(.bin(_output), .bcd(_bcd)); // se n funcionar trocar para _output
    seven_segments seg1(.in(_bcd[3:0]), .segmentos(_hex1));
    seven_segments seg2(.in(_bcd[7:4]), .segmentos(_hex2));
    seven_segments seg3(.in(_bcd[11:8]), .segmentos(_hex3));
    seven_segments seg4(.in(_bcd[15:12]), .segmentos(_hex4));
    
    assign HEX1 = _hex1;
    assign HEX2 = _hex2;
    assign HEX3 = _hex3;
    assign HEX4 = _hex4;
    assign G_LEDR[6:9] = _output;
    
    assign G_LEDG[0:6] = _teste_end;
endmodule
