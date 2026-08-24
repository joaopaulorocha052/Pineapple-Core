module LCD_CONTROLLER (
    input clk,
    input reset,
    input [31:0] input_data,
    input [31:0] output_data, // Pode ser usado futuramente na linha 2
    output reg en,
    output reg [9:0] lcd_instruction_bus
);
    reg [10:0] state;
    reg [10:0] prev_state;

    wire [31:0] _bcd_input;
    reg  [31:0] prev_input, prev_output;

    localparam  S_INIT  = 10'd0,
                S_IDLE  = 10'd16,  // Novo estado de repouso (aguarda mudança na entrada)
                S_EN_HI = 10'd99,
                S_EN_LO = 10'd100;

    reg [2:0] init_cnt; // Alterado de integer para reg

    Binary_to_BCD input_bcd_convert(.bin(input_data), .bcd(_bcd_input));

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state               <= S_INIT;
            en                  <= 1'b0;
            lcd_instruction_bus <= 10'b0;
            init_cnt            <= 3'd0;
            prev_input          <= input_data;
        end
        else begin
            case (state)
                // ========================================================
                // SEQUÊNCIA OBRIGATÓRIA DO DATASHEET (Function Set x3)
                // ========================================================
                S_INIT: begin 
                    if(init_cnt == 3'd3) begin
                        state <= 10'd1;
                    end
                    else begin
                        lcd_instruction_bus <= {2'b00, 8'b00111000}; 
                        init_cnt <= init_cnt + 1'b1;
                        prev_state <= state - 1'b1; 
                        state <= S_EN_HI;
                    end
                end

                // ========================================================
                // CONFIGURAÇÕES DE OPERAÇÃO
                // ========================================================
                10'd1: begin lcd_instruction_bus <= {2'b00, 8'b00001111}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd2: begin lcd_instruction_bus <= {2'b00, 8'b00000001}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd3: begin lcd_instruction_bus <= {2'b00, 8'b00000110}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end

                // ========================================================
                // ESCRITA NA LINHA 1 ("IN:")
                // ========================================================
                10'd4: begin lcd_instruction_bus <= {2'b10, 8'h49}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd5: begin lcd_instruction_bus <= {2'b10, 8'h4E}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd6: begin lcd_instruction_bus <= {2'b10, 8'h3A}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                
                // CORREÇÃO: Adicionado 4'b0011 (0x30 em Hex) para converter os dígitos BCD para texto ASCII!
                10'd7: begin lcd_instruction_bus <= {2'b10, 4'b0011, _bcd_input[15:12]}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd8: begin lcd_instruction_bus <= {2'b10, 4'b0011, _bcd_input[11:8]};  en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd9: begin lcd_instruction_bus <= {2'b10, 4'b0011, _bcd_input[7:4]};   en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd10:begin lcd_instruction_bus <= {2'b10, 4'b0011, _bcd_input[3:0]};   en <= 1'b0; prev_state <= state; state <= S_EN_HI; end

                // ========================================================
                // TROCA PARA A LINHA 2 (Set DDRAM Address = 0x40)
                // ========================================================
                10'd11: begin lcd_instruction_bus <= {2'b00, 8'hC0}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end

                // ========================================================
                // ESCRITA NA LINHA 2 ("OUT:")
                // ========================================================
                10'd12: begin lcd_instruction_bus <= {2'b10, 8'h4F}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd13: begin lcd_instruction_bus <= {2'b10, 8'h55}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd14: begin lcd_instruction_bus <= {2'b10, 8'h54}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd15: begin lcd_instruction_bus <= {2'b10, 8'h3A}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end

                10'd16: begin lcd_instruction_bus <= {2'b10, 4'b0011, output_data[15:12]}; en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd17: begin lcd_instruction_bus <= {2'b10, 4'b0011, output_data[11:8]};  en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd18: begin lcd_instruction_bus <= {2'b10, 4'b0011, output_data[7:4]};   en <= 1'b0; prev_state <= state; state <= S_EN_HI; end
                10'd19:begin lcd_instruction_bus <= {2'b10, 4'b0011, output_data[3:0]};   en <= 1'b0; prev_state <= state; state <= S_EN_HI; end

                // ========================================================
                // ESTADO IDLE (Espera por nova entrada)
                // ========================================================
                S_IDLE: begin
                    en <= 1'b0;
                    // Só atualiza a tela SE o input mudar
                    if (prev_input != input_data) begin
                        prev_input <= input_data;
                        state <= 10'd2; // Pula de volta para "Limpar Tela" (Clear Display) e recomeça a escrita
                    end
                    else if(prev_output != output_data)begin
                        prev_output <= output_data;
                        state <= 10'd2;
                    end
                end
                
                S_EN_HI: begin
                    en <= 1'b1;
                    state <= S_EN_LO;
                end

                S_EN_LO: begin
                    en <= 1'b0;
                    state <= prev_state + 1'b1;
                end

                default: state <= S_INIT;
            endcase
        end
    end  
endmodule