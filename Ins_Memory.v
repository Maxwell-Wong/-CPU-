`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/22 19:39:19
// Design Name: 
// Module Name: Ins_Memory
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


module Ins_Memory(
    input [31:0] Iaddr,
    input RW,
    output reg [31:0] IDataOut
);
    reg [7:0] Ins_mem[255:0]; 
    initial 
        begin 
            $readmemb("C:/Users/maxwell/Desktop/Instructions.txt",Ins_mem);
        end
    always@(Iaddr or RW)
        begin 
            if(RW) //writeable 
                begin
                    IDataOut = {Ins_mem[Iaddr],Ins_mem[Iaddr+1],Ins_mem[Iaddr+2],Ins_mem[Iaddr+3]};
                end
        end
endmodule
