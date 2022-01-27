`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/06 14:34:56
// Design Name: 
// Module Name: Seg_Led
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


module Seg_Led(
input Reset,
input [3:0]Digit_in,
output reg[7:0]Out
 );
 always@(Digit_in or Reset)
    begin
    if(Reset == 0) Out = 8'b11111110;
    else begin
     case(Digit_in)
                     4'b0000:	 Out=	8'b00000011;	//0
                     4'b0001:    Out=    8'b10011111;    //1
                     4'b0010:    Out=    8'b00100101;    //2
                     4'b0011:    Out=    8'b00001101;    //3
                     4'b0100:    Out=    8'b10011001;    //4
                     4'b0101:    Out=    8'b01001001;    //5
                     4'b0110:    Out=    8'b01000001;    //6
                     4'b0111:    Out=    8'b00011111;    //7
                     4'b1000:    Out=    8'b00000001;    //8
                     4'b1001:    Out=    8'b00001001;    //9
                     4'b1010:    Out=    8'b00010001;    //A
                     4'b1011:    Out=    8'b11000001;    //B
                     4'b1100:    Out=    8'b01100011;    //C
                     4'b1101:    Out=    8'b10000101;    //D
                     4'b1110:    Out=    8'b01100001;    //E
                     4'b1111:    Out=    8'b01110001;    //F
                     default:    Out=    8'b00000000;    
      endcase
    end
   end
 
endmodule
