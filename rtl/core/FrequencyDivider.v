module FrequencyDivider
#(
    parameter FREQ_HZ = 10
)

(
    input in_clk, output reg out_clk, input en
);
    reg [25:0] OUT = 0;
    wire [25:0] max_count;
    assign max_count = 26'd50_000_000 /FREQ_HZ;
    always @ (posedge in_clk)begin
        if(en)begin
          if (OUT == max_count)
                begin
                    OUT<= 26'd0;
                    out_clk <= 1;
                end
            else
                begin
                    OUT<= OUT+1;
                    out_clk <= 0;
                end
        end
    end
        
endmodule
