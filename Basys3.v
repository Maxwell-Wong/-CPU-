`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/06 14:33:07
// Design Name: 
// Module Name: Basys3
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


module Basys3(
    input button,
    input [1:0]SW,
    input CLK,  //Basys3's Clock
    input Reset,
    output [7:0]Digit_Out,
    output reg[3:0] AN
);
wire [31:0]cur_PC;
wire [31:0] new_PCaddr;
wire [31:0]ALU_Res;
wire [31:0] Write_Data;
wire [31:0]Data_rs;
wire [31:0]Data_rt;
wire[31:0] Instruction;
wire [31:0]DataOut;
wire [4:0]Write_Reg;
wire Single_CLK; //CPU's Clock

parameter T1MS = 5000;
reg [19:0] count ;
 reg[3:0] Value;

Single_Cycle_CPU scpu(Single_CLK,Reset,cur_PC,new_PCaddr,ALU_Res,Write_Data,Data_rs, Data_rt,Instruction,DataOut,Write_Reg);

initial begin
    count <= 0;
    AN <= 4'b0111;
end 
Debounce debounce(CLK,button,Single_CLK);
always@(posedge CLK)
    begin
        if(Reset==0) begin
            count<=0;
            AN<=4'b0000;
        end
        else begin
        count=count+1;
            if(count==T1MS)begin
            count<=0;
                case(AN)
                    4'b1110:AN = 4'b1101;
                     4'b1101:AN = 4'b1011;
                      4'b1011:AN = 4'b0111;
                       4'b0111:AN = 4'b1110;
                        4'b0000:AN = 4'b0111;
                endcase 
            end
        end    
    end
Seg_Led led(Reset,Value,Digit_Out);
always@(posedge Single_CLK)
begin 
case(AN)
    4'b1110:
            begin
            case(SW)
                2'b00:Value = new_PCaddr[3:0];
                2'b01:Value = Data_rs[3:0];
                2'b10:Value = Data_rt[3:0];
                2'b11:Value = DataOut[3:0];
            endcase
            end
    4'b1101:
             begin
            case(SW)
                 2'b00:Value = new_PCaddr[7:4];
                 2'b01:Value = Data_rs[7:4];
                 2'b10:Value = Data_rt[7:4];
                 2'b11:Value = DataOut[7:4];
             endcase
             end
    4'b1011:
             begin
               case(SW)
                  2'b00:Value = cur_PC[3:0];
                  2'b01:Value = Instruction[24:21];
                  2'b10:Value = Instruction[19:16];
                  2'b11:Value = ALU_Res[3:0];
               endcase 
              end
    4'b0111:
             begin
               case(SW)
                2'b00: Value = cur_PC[7:4];
                2'b01: Value = {3'b000,Instruction[25]};
                2'b10: Value = {3'b000,Instruction[20]};
                2'b11: Value = ALU_Res[7:4];
                endcase  
             end
endcase 
end    
endmodule

