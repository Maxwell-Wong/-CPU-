`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/26 09:34:18
// Design Name: 
// Module Name: MUX_32b
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


module MUX_32b(
   input enable,
   input [31:0]Data1,
   input [31:0]Data2,
   output [31:0] Res
   );
   
   assign Res = enable?Data1:Data2; 
    
    
endmodule
