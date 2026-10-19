module IO (
    input [31:0] output_value_register,
    input [31:0] io_config,
    input [31:0] input_value,
    input enter, clk, reset,
    output [31:0] output_value,
    output reg [31:0] input_value_register,
    output reg halt_flag, reset_config_flag
);

    reg previous_enter_value;
    reg input_done;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            halt_flag <= 1'b0;
            previous_enter_value <= 1'b0;
            input_value_register <= 32'b0;
            input_done <= 1'b0;
        end else begin
            previous_enter_value <= enter;

            // Quando a configuracao de entrada e desativada, reseta o estado de leitura
            if (io_config[1] == 1'b0) begin
                halt_flag <= 1'b0;
                input_done <= 1'b0;
            end 
            // Se a entrada esta ativada e ainda nao foi lida, solicita a pausa (halt)
            else if (io_config[1] == 1'b1 && !input_done) begin
                halt_flag <= 1'b1;
            end

            // Ao detetar a borda de subida do enter, captura o valor e libera a CPU
            if (enter && !previous_enter_value) begin
                halt_flag <= 1'b0;
                input_value_register <= input_value;
                input_done <= 1'b1; // Marca a leitura como concluida
            end
        end
    end

    assign output_value = output_value_register;

endmodule