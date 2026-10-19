module LCD_CONTROLLER #(
    parameter CLK_FREQ = 50_000_000 // Clock de 50 MHz da DE2-115
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] input_data,
    input  wire [31:0] output_data,
    output reg         en,
    output reg  [9:0]  lcd_instruction_bus
);

    // Conversão BCD para ambas as entradas
    wire [31:0] bcd_in;
    wire [31:0] bcd_out;

    Binary_to_BCD input_bcd_convert (.bin(input_data),  .bcd(bcd_in));
    Binary_to_BCD output_bcd_convert(.bin(output_data), .bcd(bcd_out));

    // Registradores de controle de fluxo e mudanças
    reg [31:0] prev_input, prev_output;
    reg [4:0]  step;
    reg [2:0]  state;
    reg [19:0] timer;

    // Sinal combinacional que define qual instrução enviar em cada passo
    reg [9:0] current_cmd;

    // Constantes de tempo baseadas em clock de 50MHz (20ns por ciclo)
    localparam T_20MS   = CLK_FREQ / 50;       // 1_000_000 ciclos (Estabilização inicial)
    localparam T_2MS    = CLK_FREQ / 500;      // 100_000 ciclos (Clear Display)
    localparam T_50US   = CLK_FREQ / 20_000;   // 2_500 ciclos (Comando/Dado padrão)
    localparam T_PULSE  = 25;                  // ~500 ns para o pulso de Enable

    // Estados da FSM de protocolo
    localparam FSM_POWER_ON = 3'd0,
               FSM_SET_DATA = 3'd1,
               FSM_PULSE_HI = 3'd2,
               FSM_WAIT_CMD = 3'd3,
               FSM_IDLE     = 3'd4;

    // =========================================================================
    // MAPA DE COMANDOS E DADOS DA TELA (Tabela Sequencial)
    // =========================================================================
    always @(*) begin
        case (step)
            // Sequência de Inicialização do LCD
            5'd0:  current_cmd = {2'b00, 8'h38}; // Function Set: 8-bit, 2 linhas
            5'd1:  current_cmd = {2'b00, 8'h0C}; // Display ON, Cursor OFF (0x0C evita piscar)
            5'd2:  current_cmd = {2'b00, 8'h01}; // Clear Display
            5'd3:  current_cmd = {2'b00, 8'h06}; // Entry Mode: Avança cursor para direita

            // Linha 1: "IN:" + 4 dígitos BCD
            5'd4:  current_cmd = {2'b10, 8'h49}; // 'I'
            5'd5:  current_cmd = {2'b10, 8'h4E}; // 'N'
            5'd6:  current_cmd = {2'b10, 8'h3A}; // ':'
            5'd7:  current_cmd = {2'b10, 4'b0011, bcd_in[15:12]};
            5'd8:  current_cmd = {2'b10, 4'b0011, bcd_in[11:8]};
            5'd9:  current_cmd = {2'b10, 4'b0011, bcd_in[7:4]};
            5'd10: current_cmd = {2'b10, 4'b0011, bcd_in[3:0]};

            // Mudar para a Linha 2 (DDRAM Address 0x40 -> Comando 0xC0)
            5'd11: current_cmd = {2'b00, 8'hC0};

            // Linha 2: "OUT:" + 4 dígitos BCD
            5'd12: current_cmd = {2'b10, 8'h4F}; // 'O'
            5'd13: current_cmd = {2'b10, 8'h55}; // 'U'
            5'd14: current_cmd = {2'b10, 8'h54}; // 'T'
            5'd15: current_cmd = {2'b10, 8'h3A}; // ':'
            5'd16: current_cmd = {2'b10, 4'b0011, bcd_out[15:12]};
            5'd17: current_cmd = {2'b10, 4'b0011, bcd_out[11:8]};
            5'd18: current_cmd = {2'b10, 4'b0011, bcd_out[7:4]};
            5'd19: current_cmd = {2'b10, 4'b0011, bcd_out[3:0]};

            default: current_cmd = 10'b0;
        endcase
    end

    // =========================================================================
    // MÁQUINA DE ESTADOS COM CONTROLE DE TEMPORIZAÇÃO (PROTOCOLO LCD)
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state               <= FSM_POWER_ON;
            step                <= 5'd0;
            timer               <= 20'd0;
            en                  <= 1'b0;
            lcd_instruction_bus <= 10'b0;
            prev_input          <= 32'hFFFF_FFFF;
            prev_output         <= 32'hFFFF_FFFF;
        end else begin
            case (state)
                // 1. Aguarda estabilização elétrica do chip (20 ms)
                FSM_POWER_ON: begin
                    en <= 1'b0;
                    if (timer < T_20MS) begin
                        timer <= timer + 1'b1;
                    end else begin
                        timer <= 20'd0;
                        step  <= 5'd0;
                        state <= FSM_SET_DATA;
                    end
                end

                // 2. Aplica o barramento do passo atual
                FSM_SET_DATA: begin
                    lcd_instruction_bus <= current_cmd;
                    en                  <= 1'b0;
                    timer               <= 20'd0;
                    state               <= FSM_PULSE_HI;
                end

                // 3. Gera o pulso em alto para Enable (~500 ns)
                FSM_PULSE_HI: begin
                    en <= 1'b1;
                    if (timer < T_PULSE) begin
                        timer <= timer + 1'b1;
                    end else begin
                        en    <= 1'b0;
                        timer <= 20'd0;
                        state <= FSM_WAIT_CMD;
                    end
                end

                // 4. Aguarda o tempo necessário para o LCD executar o comando
                FSM_WAIT_CMD: begin
                    en <= 1'b0;
                    // Se for Clear Display (passo 2), aguarda 2ms. Caso contrário, 50us.
                    if ((step == 5'd2 && timer < T_2MS) || (step != 5'd2 && timer < T_50US)) begin
                        timer <= timer + 1'b1;
                    end else begin
                        timer <= 20'd0;
                        if (step < 5'd19) begin
                            step  <= step + 1'b1;
                            state <= FSM_SET_DATA;
                        end else begin
                            state <= FSM_IDLE;
                        end
                    end
                end

                // 5. Estado de Repouso: monitora mudanças nos dados de entrada/saída
                FSM_IDLE: begin
                    en <= 1'b0;
                    if (input_data != prev_input || output_data != prev_output) begin
                        prev_input  <= input_data;
                        prev_output <= output_data;
                        step        <= 5'd2; // Pula direto para o "Clear Display" e reescreve
                        state       <= FSM_SET_DATA;
                    end
                end

                default: state <= FSM_POWER_ON;
            endcase
        end
    end

endmodule