# Single-Cycle-CPU
实验三	：	单周期CPU设计与实现
一、 实验目的
(1) 掌握单周期CPU数据通路图的构成、原理及其设计方法；
(2) 掌握单周期CPU的实现方法，代码实现方法；
(3) 认识和掌握指令与CPU的关系；
(4) 掌握测试单周期CPU的方法。

二、 实验内容
设计一个单周期CPU，该CPU至少能实现以下指令功能操作。指令与格式如下：
==> 算术运算指令
（1）add  rd , rs, rt  
000000	rs(5位)	rt(5位)	rd(5位)	00000 100000
功能：GPR[rd] ← GPR[rs] + GPR[rt]。
    （2）sub  rd , rs , rt
000000	rs(5位)	rt(5位)	rd(5位)	00000 100010
功能：GPR[rd] ← GPR[rs] - GPR[rt]。
（3）addiu  rt , rs ,immediate  
001001	rs(5位)	rt(5位)	immediate(16位)
功能：GPR[rt] ← GPR[rs] + sign_extend(immediate)； immediate做符号扩展再参加“与”运算。

==> 逻辑运算指令
（4）andi  rt , rs ,immediate  
001100	rs(5位)	rt(5位)	immediate(16位)
功能：GPR[rt] ← GPR[rs] and zero_extend(immediate)；immediate做0扩展再参加“与”运算。
（5）and  rd , rs , rt
000000	rs(5位)	rt(5位)	rd(5位)	00000 100100
功能：GPR[rd] ← GPR[rs] and GPR[rt]。
（6）ori  rt , rs ,immediate  
001101	rs(5位)	rt(5位)	immediate(16位)
功能：GPR[rt] ← GPR[rs] or zero_extend(immediate)。
（7）or  rd , rs , rt
000000	rs(5位)	rt(5位)	rd(5位)	00000 100101
功能：GPR[rd] ← GPR[rs] or GPR[rt]。

==>移位指令
（8）sll  rd, rt,sa 
000000	00000	rt(5位)	rd(5位)	sa(5位)	000000
功能：GPR[rd] ← GPR[rt] << sa。
==>比较指令
（9） slti  rt, rs,immediate   带符号数
001010	rs(5位)	rt(5位)	immediate(16位)
功能：if GPR[rs] < sign_extend(immediate)  GPR[rt] =1 else  GPR[rt] = 0。

==> 存储器读/写指令
（10）sw  rt , offset (rs) 写存储器
101011	rs(5位)	rt(5位)	offset(16位)
功能：memory[GPR[base] + sign_extend(offset)] ← GPR[rt]。
（11) lw  rt , offset (rs) 读存储器
100011	rs(5位)	rt(5位)	offset (16位)
功能：GPR[rt] ← memory[GPR[base] + sign_extend(offset)]。 

 ==> 分支指令
   （12）beq  rs,rt, offset
000100	rs(5位)	rt(5位)	offset (16位)
功能：if(GPR[rs] = GPR[rt]) pc←pc + 4 + sign_extend(offset)<<2  
else pc ←pc + 4
特别说明：offset是从PC+4地址开始和转移到的指令之间指令条数。offset符号扩展之后左移2位再相加。为什么要左移2位？由于跳转到的指令地址肯定是4的倍数（每条指令占4个字节），最低两位是“00”，因此将offset放进指令码中的时候，是右移了2位的，也就是以上说的“指令之间指令条数”。
    （13）bne  rs,rt, offset
000101	rs(5位)	rt(5位)	offset (16位)
功能：if(GPR[rs] != GPR[rt]) pc←pc + 4 + sign_extend(offset) <<2  
else pc ←pc + 4
    （14）bltz  rs, offset
000001	rs(5位)	00000	offset (16位)
功能：if(GPR[rs] < 0) pc←pc + 4 + sign_extend (offset) <<2  
else pc ←pc + 4。

==>跳转指令
（15）j  addr    
000010	addr(26位)
功能：PC ← {PC[31:28] , addr , 2’b0}，无条件跳转。
说明：由于MIPS32的指令代码长度占4个字节，所以指令地址二进制数最低2位均为0，将指令地址放进指令代码中时，可省掉！这样，除了最高6位操作码外，还有26位可用于存放地址，事实上，可存放28位地址，剩下最高4位由pc+4最高4位拼接上。

==> 停机指令
（16）halt 
111111	00000000000000000000000000(26位)
功能：停机；不改变PC的值，PC保持不变。

在本文档中，提供的相关内容对于设计可能不足或甚至有错误，希望同学们在设计过程中如发现有问题，请你们自行改正，进一步补充、完善。谢谢！

三、实验原理
单周期CPU指的是一条指令的执行在一个时钟周期内完成，然后开始下一条指令的执行，即一条指令用一个时钟周期完成。电平从低到高变化的瞬间称为时钟上升沿，两个相邻时钟上升沿之间的时间间隔称为一个时钟周期。时钟周期一般也称振荡周期（如果晶振的输出没有经过分频就直接作为CPU的工作时钟，则时钟周期就等于振荡周期。若振荡周期经二分频后形成时钟脉冲信号作为CPU的工作时钟，这样，时钟周期就是振荡周期的两倍。）
    CPU在处理指令时，一般需要经过以下几个步骤：
    (1) 取指令(IF)：根据程序计数器PC中的指令地址，从存储器中取出一条指令，同时，PC根据指令字长度自动递增产生下一条指令所需要的指令地址，但遇到“地址转移”指令时，则控制器把“转移地址”送入PC，当然得到的“地址”需要做些变换才送入PC。
    (2) 指令译码(ID)：对取指令操作中得到的指令进行分析并译码，确定这条指令需要完成的操作，从而产生相应的操作控制信号，用于驱动执行状态中的各种操作。
    (3) 指令执行(EXE)：根据指令译码得到的操作控制信号，具体地执行指令动作，然后转移到结果写回状态。
    (4) 存储器访问(MEM)：所有需要访问存储器的操作都将在这个步骤中执行，该步骤给出存储器的数据地址，把数据写入到存储器中数据地址所指定的存储单元或者从存储器中得到数据地址单元中的数据。
    (5) 结果写回(WB)：指令执行的结果或者访问存储器中得到的数据写回相应的目的寄存器中。
    单周期CPU，是在一个时钟周期内完成这五个阶段的处理。
图1  单周期CPU指令处理过程
MIPS指令的三种格式：

其中，
op：为操作码；
rs：只读。为第1个源操作数寄存器，寄存器地址（编号）是00000~11111，00~1F；
rt：可读可写。为第2个源操作数寄存器，或目的操作数寄存器，寄存器地址（同上）；
rd：只写。为目的操作数寄存器，寄存器地址（同上）；
sa：为位移量（shift amt），移位指令用于指定移多少位；
funct：为功能码，在寄存器类型指令中（R类型）用来指定指令的功能与操作码配合使用；
immediate：为16位立即数，用作无符号的逻辑操作数、有符号的算术操作数、数据加载（Laod）/数据保存（Store）指令的数据地址字节偏移量和分支指令中相对程序计数器（PC）的有符号偏移量；
    address：为地址。

图2  单周期CPU数据通路和控制线路图

图2是一个简单的基本上能够在单周期CPU上完成所要求设计的指令功能的数据通路和必要的控制线路图。其中指令和数据各存储在不同存储器中，即有指令存储器和数据存储器。访问存储器时，先给出内存地址，然后由读或写信号控制操作。对于寄存器组，先给出寄存器地址，读操作时不需要时钟信号，输出端就直接输出相应数据；而在写操作时，在 WE使能信号为1时，在时钟边沿触发将数据写入寄存器。图中控制信号作用如表1所示，表2是ALU运算功能表。
表1 控制信号的作用
控制信号名	状态“0”	状态“1”
Reset	初始化PC为0	PC接收新地址
PCWre	PC不更改，相关指令：halt	PC更改，相关指令：除指令halt外
ALUSrcA	来自寄存器堆data1输出，相关指令：add、sub、addiu、or、and、andi、ori、slti、beq、bne、bltz、sw、lw	来自移位数sa，同时，进行(zero-extend)sa，即 {{27{1'b0}},sa}，相关指令：sll
ALUSrcB	来自寄存器堆data2输出，相关指令：add、sub、or、and、beq、bne、bltz	来自sign或zero扩展的立即数，相关指令：addi、andi、ori、slti、sw、lw
DBDataSrc	来自ALU运算结果的输出，相关指令：add、addiu、sub、ori、or、and、andi、slti、sll	来自数据存储器（Data MEM）的输出，相关指令：lw
RegWre	无写寄存器组寄存器，相关指令：
beq、bne、bltz、sw、halt	寄存器组写使能，相关指令：add、addiu、sub、ori、or、and、andi、slti、sll、lw
InsMemRW	写指令存储器	读指令存储器(Ins. Data)
mRD	输出高阻态	读数据存储器，相关指令：lw
mWR	无操作	写数据存储器，相关指令：sw
RegDst	写寄存器组寄存器的地址，来自rt字段，相关指令：addiu、andi、ori、slti、lw	写寄存器组寄存器的地址，来自rd字段，相关指令：add、sub、and、or、sll
ExtSel	(zero-extend)immediate（0扩展），相关指令：addiu、andi、ori	(sign-extend)immediate（符号扩展）
，相关指令：slti、sw、lw、beq、bne、bltz
PCSrc[1..0]	00：pc<－pc+4，相关指令：add、addiu、sub、or、ori、and、andi、slti、sll、sw、lw、beq(zero=0)、bne(zero=1)、bltz(sign=0)；
01：pc<－pc+4+(sign-extend)immediate，相关指令：beq(zero=1)、
bne(zero=0)、bltz(sign=1)；
10：pc<－{(pc+4)[31:28],addr[27:2],2'b00}，相关指令：j；
11：未用
ALUOp[2..0]	ALU 8种运算功能选择(000-111)，看功能表
相关部件及引脚说明：
Instruction Memory：指令存储器，
  Iaddr，指令存储器地址输入端口
  IDataIn，指令存储器数据输入端口（指令代码输入端口）
  IDataOut，指令存储器数据输出端口（指令代码输出端口）
  RW，指令存储器读写控制信号，为0写，为1读
Data Memory：数据存储器，
  Daddr，数据存储器地址输入端口
  DataIn，数据存储器数据输入端口
  DataOut，数据存储器数据输出端口
  /RD，数据存储器读控制信号，为0读
  /WR，数据存储器写控制信号，为0写
Register File：寄存器组
  Read Reg1，rs寄存器地址输入端口
  Read Reg2，rt寄存器地址输入端口
  Write Reg，将数据写入的寄存器端口，其地址来源rt或rd字段
  Write Data，写入寄存器的数据输入端口
  Read Data1，rs寄存器数据输出端口
  Read Data2，rt寄存器数据输出端口
  WE，写使能信号，为1时，在时钟边沿触发写入
ALU：  算术逻辑单元
  result，ALU运算结果
  zero，运算结果标志，结果为0，则zero=1；否则zero=0
  sign，运算结果标志，结果最高位为0，则sign=0，正数；否则，sign=1，负数

表2 ALU运算功能表        
ALUOp[2..0]	功能	描述
000	Y = A + B	加
001	Y = A – B	减
010	Y = B<<A	B左移A位
011	Y = A ∨ B	或
100	Y = A ∧ B	与
101	Y=（A<B）?1: 0	比较A与B
不带符号
110	Y=(((rega<regb) && (rega[31] == regb[31] )) ||( ( rega[31] ==1 && regb[31] == 0))) ? 1:0	比较A与B
带符号
111	Y = A  B	异或



四、实验设备
PC机一台，BASYS 3 实验板一块，Xilinx Vivado 开发软件一套。

