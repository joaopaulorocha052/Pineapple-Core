/*************************************** IO ***********************************************

                Registers 33 and 32 store input and output values
                Register 34 stores IO configs
                The 8 bits in io_config register refer to IO settings
                Bits:
                    0 -----> Turns output ON/OFF
                    1 -----> Turns Input ON/OFF 
                    2 -----> Sets output as LEDs
                    3 -----> Sets output as 7 Segments Display
                    4...7 -> To be implemented(LCD, keyboard)

*************************************** IO ***********************************************/


module IO (
    input [31:0] output_value_register,
    input [31:0] io_config,
    input [31:0] input_value,
    input enter, clk, reset,
    output [31:0] output_value,
    output reg [31:0] input_value_register,
    output reg halt_flag, reset_config_flag
    //output [28:0] hex
);
  
  //seven_segments seven (.input_value(output_value), );
wire _hex, _led;

    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            halt_flag = 1'b0;
        end else begin
            if (io_config[1] == 1'b1) begin
                halt_flag =  1'b1;
            end
            if(enter)begin
                halt_flag = 1'b0;
            end
        end
        
        

    end
    assign output_value = output_value_register;

endmodule