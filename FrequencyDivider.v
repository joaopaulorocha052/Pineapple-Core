module FrequencyDivider(
    input in_clk, output reg out_clk, input en
);
    reg [25:0] OUT = 0;
    
    always @ (posedge in_clk)begin
        if(en)begin
          //if (OUT == 26'd10000000) 
	  if ( OUT == 26'd1)
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
