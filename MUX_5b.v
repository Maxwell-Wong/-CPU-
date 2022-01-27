`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/26 11:03:50
// Design Name: 
// Module Name: MUX_5b
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MUX_5b(
   input enable,  //enable=1:rd  enable=0:rt
   input [4:0]Data1, //rt [20:16]
   input [4:0]Data2, //rd [15:11]
   output [4:0] Res
   );
   
   assign Res = enable?Data2:Data1;
endmodule
