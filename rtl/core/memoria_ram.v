module memoria_ram
 #( parameter DATA_WIDTH =32 , parameter ADDR_WIDTH =9)
 (
 input [( DATA_WIDTH -1) :0] data ,
 input [( ADDR_WIDTH -1) :0] read_addr , write_addr ,
 input we , read_clock , write_clock ,
 output reg [( DATA_WIDTH -1) :0] q
//  output [(DATA_WIDTH - 1):0] test_out,
// output [(DATA_WIDTH - 1):0] test_out1,
// output [(DATA_WIDTH - 1):0] test_out2,
// output [(DATA_WIDTH - 1):0] test_out3,
// output [(DATA_WIDTH - 1):0] test_out4
 );

 // Declare the RAM variable
 reg [ DATA_WIDTH -1:0] ram [2** ADDR_WIDTH -1:0] /* synthesis preserve */;
 integer init_i;
 initial begin
     for (init_i = 0; init_i < 2**ADDR_WIDTH; init_i = init_i + 1) begin
         ram[init_i] = {DATA_WIDTH{1'b0}};
     end
 end

 always @ ( posedge write_clock )
 begin
 // Write
 if ( we ) 
 ram [ write_addr ] <= data ;
 end
// clock de 50MHz
 always @ ( posedge read_clock )
 begin
 // Read
  q <= ram [ read_addr ];
 end
// assign test_out = ram[0];
//assign test_out1 = ram[1];
//assign test_out2 = ram[2];
//assign test_out3 = ram[3];
//assign test_out4 = ram[4];
	 

 endmodule