`include "constants.vh"

module timer #(
    parameter MAX_COUNT=200
) (
    input clk, en, reset, clear,
    output reg timeout_flag
);
    

    reg[31:0] count = 32'd0;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            count <= 32'd0;
            timeout_flag <= 1'd0;
        end

        else if (clear) begin
            count <= 32'd0;
            timeout_flag <= 1'd0;
        end

        else if (en && !timeout_flag) begin

            if (count == MAX_COUNT - 1) timeout_flag <= 1'b1;
            else count <= count + 32'd1;
        end
    end
endmodule