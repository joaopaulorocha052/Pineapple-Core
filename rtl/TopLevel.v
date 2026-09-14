
module TopLevel (
    input CLOCK_50,
    input [0:10] V_SW,
    output [0:9] G_LEDR,
    output [0:8] G_LEDG,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [12:0] LCD_BUS
);


    assign G_LEDG[8] = V_SW[0];
    wire _halt_flag, _reset_config_flag, _clk, _lcd_clock;

    wire [31:0] _input, _config, _output, _teste, _teste_end, _bcd, lixo, _extended_input;
    wire [6:0] _hex1 , _hex2, _hex3, _hex4;

   //wire [31:0] sp_test, fp_test, mem_test, teste_apocal;

     `ifdef DEBUG_MODE
        FrequencyDivider #(.FREQ_HZ(100)) fdiv (.in_clk(CLOCK_50), .out_clk(_clk), .en(V_SW[0]));
    `else
        FrequencyDivider #(.FREQ_HZ(50_000_000)) fdiv (.in_clk(CLOCK_50), .out_clk(_clk), .en(V_SW[0]));
    `endif


    FrequencyDivider #(.FREQ_HZ(500)) LcdClockDriver (.in_clk(CLOCK_50), .out_clk(_lcd_clock), .en(1));

    IO IoModule (.clk(_clk),
                  .output_value_register(_output),
                  .input_value_register(_input),
                  .io_config(_config),
                  .enter(!V_SW[2]), 
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
                     .input_debug(G_LEDR[0:5])
                     );

    wire[9:0] lcd_instruction;
    wire enable_lcd;
    LCD_CONTROLLER lcd(.clk(_lcd_clock), .reset(V_SW[10]), .input_data(_extended_input), .output_data(_bcd), .en(enable_lcd), .lcd_instruction_bus(lcd_instruction));
    // Mapeamento corrigido baseado na nova pinagem de 14 bits:
    assign LCD_BUS = {
        1'b1,                  // LCD_BUS[12] -> L6 (Luz acesa)
        1'b1,                  // LCD_BUS[11] -> L5 (Alimentação ligada)
        lcd_instruction[9],    // LCD_BUS[10] -> M2 (RS externo mapeado pelo controlador)
        lcd_instruction[8],    // LCD_BUS[9]  -> M1 (RW externo mapeado pelo controlador)
        enable_lcd,            // LCD_BUS[8]  -> L4 (Enable)
        lcd_instruction[7:0]   // LCD_BUS[7:0] -> L3 a M5 (Barramento de 8 bits de Dados)
    };


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
    
    assign G_LEDG[0:7] = _teste_end;
endmodule
