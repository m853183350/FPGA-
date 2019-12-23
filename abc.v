module abc(ROW,COL,COLG,clk,btn,disp,beep,lcd_en,lcd_rw,lcd_rs,lcd_data);
input clk;
input btn;
output reg[0:0]beep;	//蜂鸣器
output reg[0:7]ROW;	//从上到下，0为有效，作为第ROW行
output reg[0:7]COL;	//从右到左，1为有效，作为第COL列
output reg[0:7]COLG;	//绿色
output reg[0:15]disp;			//数码管输出

reg[3:0]ain;			//刷新单帧中的行列
reg[15:0]btime;		//每65536个clock刷新一次
reg[16:0]refresh;		//分频1khz,---50000

reg[7:0]reg_tempr[223:0];//储存红色图案内容
reg[7:0]reg_tempg[223:0];//储存绿色图案内容
reg[7:0]smgzijian;		//储存数码管自检图案
reg[4:0]frame;			//现在是第frame帧
reg[2:0]fire;			//现在是第fire个烟花
reg[3:0]djs;			//倒计时10s+开自检3s
reg[27:0]djsclk;		//分频1hz
reg[0:0]ksdjs;			//是否开始10s倒计时
parameter N = 32;		//为了把整个数组往后一点
reg[0:0]fireon;		//是否已经放完烟花
reg[0:0]lcdon;			//LCD是否显示字
reg[15:0]ddd[11:0];			//储存数码管图案

//音符频率，不解释
parameter c1 = 191109;
parameter d1 = 170259;
parameter e1 = 151685;
parameter f1 = 143172;
parameter g1 = 127554;//1
parameter a1 = 113636;//2
parameter b1 = 101239;//3

parameter c2 = 93941;//4
parameter d2 = 85131;//5
parameter e2 = 75844;//6
parameter f2 = 71586;//7
parameter g2 = 63776;//8
parameter a2 = 56818;//9
parameter b2 = 50619;

parameter c3 = 47778;
parameter d3 = 42565;
parameter e3 = 37921;
parameter f3 = 35793;
parameter g3 = 31888;
parameter a3 = 28409;
parameter b3 = 25310;

parameter p0 = 1;		//休止（其实是超声波

/*整个曲子
12315553 22552216 33317777 17667712 55112344 43212222 12315553 22552216 66715550 55667712 55112344 43211111
34555555 55565433 33333334 32111117 66777122 23232222 34555555 55565433 33343217 66771255 11232222 21111111 原调

45648886 55885542 66643333 43223345 11445677 76545555 45648886 55885542 22341111 11223345 11445677 76544444
67888888 88898766 66666667 65444443 22333455 56565555 67888888 88898766 66676543 22334511 44565555 54444444 转成数组
*/

reg [0:3]notes[0:191];
reg [0:23]beat;		//拍子分频，约180bmp，模值16_666_666
reg [0:17]freq;		//音高分频
reg [0:7]note;			//记录现在是第note个音符
reg [0:17]_freq;		//用于比较

reg [0:0]rst_n;	//lcd的复位按钮

output wire[0:0]lcd_en;	//lcd使能端
output wire[0:0]lcd_rw;	//lcd读写控制端
output wire[0:0]lcd_rs;	//lcd指令/数据端
output wire[7:0]lcd_data;//lcd数据总线

initial begin
	refresh = 0;
	beat =0;
	freq = 0;
	ain = 0;
	btime = 0;
	frame = 0;
	djs = 13;
	djsclk = 0;
	fire = 0;
	ksdjs = 0;
	
	rst_n = 1;
	//自检
	reg_tempg[0] = 255;
	reg_tempg[1] = 255;
	reg_tempg[2] = 255;
	reg_tempg[3] = 255;
	reg_tempg[4] = 255;
	reg_tempg[5] = 255;
	reg_tempg[6] = 255;
	reg_tempg[7] = 255;
	reg_tempg[8] = 0;
	reg_tempg[9] = 0;
	reg_tempg[10] = 0;
	reg_tempg[11] = 0;
	reg_tempg[12] = 0;
	reg_tempg[13] = 0;
	reg_tempg[14] = 0;
	reg_tempg[15] = 0;
	reg_tempg[16] = 255;
	reg_tempg[17] = 255;
	reg_tempg[18] = 255;
	reg_tempg[19] = 255;
	reg_tempg[20] = 255;
	reg_tempg[21] = 255;
	reg_tempg[22] = 255;
	reg_tempg[23] = 255;	
	reg_tempr[24] = 0;
	reg_tempr[25] = 0;
	reg_tempr[26] = 0;
	reg_tempr[27] = 0;
	reg_tempr[28] = 0;
	reg_tempr[29] = 0;
	reg_tempr[30] = 0;
	reg_tempr[31] = 0;

	reg_tempr[0] = 0;
	reg_tempr[1] = 0;
	reg_tempr[2] = 0;
	reg_tempr[3] = 0;
	reg_tempr[4] = 0;
	reg_tempr[5] = 0;
	reg_tempr[6] = 0;
	reg_tempr[7] = 0;
	reg_tempr[8] = 255;
	reg_tempr[9] = 255;
	reg_tempr[10] = 255;
	reg_tempr[11] = 255;
	reg_tempr[12] = 255;
	reg_tempr[13] = 255;
	reg_tempr[14] = 255;
	reg_tempr[15] = 255;
	reg_tempr[16] = 255;
	reg_tempr[17] = 255;
	reg_tempr[18] = 255;
	reg_tempr[19] = 255;
	reg_tempr[20] = 255;
	reg_tempr[21] = 255;
	reg_tempr[22] = 255;
	reg_tempr[23] = 255;
	reg_tempg[24] = 0;
	reg_tempg[25] = 0;
	reg_tempg[26] = 0;
	reg_tempg[27] = 0;
	reg_tempg[28] = 0;
	reg_tempg[29] = 0;
	reg_tempg[30] = 0;
	reg_tempg[31] = 0;
	////第一个烟花
	
	reg_tempr[0 + N] = 8'b00000000;
	reg_tempr[1 + N] = 8'b00000000;
	reg_tempr[2 + N] = 8'b00000000;
	reg_tempr[3 + N] = 8'b00011000;
	reg_tempr[4 + N] = 8'b00011000;
	reg_tempr[5 + N] = 8'b00000000;
	reg_tempr[6 + N] = 			 0;
	reg_tempr[7 + N] = 			 0;
	
	reg_tempr[8 + N] = 			 0;
	reg_tempr[9 + N] = 			 0;
	reg_tempr[10 + N] = 8'b00000000;
	reg_tempr[11 + N] = 8'b00000000;
	reg_tempr[12 + N] = 8'b00000000;
	reg_tempr[13 + N] = 8'b00000000;
	reg_tempr[14 + N] = 			  0;
	reg_tempr[15 + N] = 			  0;
	
	reg_tempr[16 + N] = 			  0;
	reg_tempr[17 + N] = 8'b00111100;
	reg_tempr[18 + N] = 8'b01000010;
	reg_tempr[19 + N] = 8'b01011010;
	reg_tempr[20 + N] = 8'b01011010;
	reg_tempr[21 + N] = 8'b01000010;
	reg_tempr[22 + N] = 8'b00111100;
	reg_tempr[23 + N] = 			  0;
	
	reg_tempr[24 + N] = 8'b01101100;
	reg_tempr[25 + N] = 8'b00000001;
	reg_tempr[26 + N] = 8'b10011001;
	reg_tempr[27 + N] = 8'b10100100;
	reg_tempr[28 + N] = 8'b00100101;
	reg_tempr[29 + N] = 8'b10011001;
	reg_tempr[30 + N] = 8'b10000000;
	reg_tempr[31 + N] = 8'b00110110;
	////第二个烟花
	reg_tempr[32 + N] = 0;
	reg_tempr[33 + N] = 0;
	reg_tempr[34 + N] = 0;
	reg_tempr[35 + N] = 0;
	reg_tempr[36 + N] = 0;
	reg_tempr[37 + N] = 0;
	reg_tempr[38 + N] = 0;
	reg_tempr[39 + N] = 0;
	
	reg_tempr[40 + N] = 0;
	reg_tempr[41 + N] = 0;
	reg_tempr[42 + N] = 0;
	reg_tempr[43 + N] = 0;
	reg_tempr[44 + N] = 0;
	reg_tempr[45 + N] = 0;
	reg_tempr[46 + N] = 0;
	reg_tempr[47 + N] = 0;
	
	reg_tempr[48 + N] = 0;
	reg_tempr[49 + N] = 0;
	reg_tempr[50 + N] = 0;
	reg_tempr[51 + N] = 0;
	reg_tempr[52 + N] = 0;
	reg_tempr[53 + N] = 0;
	reg_tempr[54 + N] = 0;
	reg_tempr[55 + N] = 0;
	
	reg_tempr[56 + N] = 0;
	reg_tempr[57 + N] = 0;
	reg_tempr[58 + N] = 0;
	reg_tempr[59 + N] = 0;
	reg_tempr[60 + N] = 0;
	reg_tempr[61 + N] = 0;
	reg_tempr[62 + N] = 0;
	reg_tempr[63 + N] = 0;
	////第三个烟花
	reg_tempr[64 + N] = 8'b0;
	reg_tempr[65 + N] = 8'b0;
	reg_tempr[66 + N] = 8'b00010000;
	reg_tempr[67 + N] = 8'b00011100;
	reg_tempr[68 + N] = 8'b00111000;
	reg_tempr[69 + N] = 8'b00001000;
	reg_tempr[70 + N] = 8'b0;
	reg_tempr[71 + N] = 8'b0;
	
	reg_tempr[72 + N] = 8'b0;
	reg_tempr[73 + N] = 8'b00010000;
	reg_tempr[74 + N] = 8'b00011000;
	reg_tempr[75 + N] = 8'b00111110;
	reg_tempr[76 + N] = 8'b01111100;
	reg_tempr[77 + N] = 8'b00011000;
	reg_tempr[78 + N] = 8'b00001000;
	reg_tempr[79 + N] = 8'b0;
	
	reg_tempr[80 + N] = 8'b00011000;
	reg_tempr[81 + N] = 8'b00100100;
	reg_tempr[82 + N] = 8'b01000010;
	reg_tempr[83 + N] = 8'b10011001;
	reg_tempr[84 + N] = 8'b10011001;
	reg_tempr[85 + N] = 8'b01000010;
	reg_tempr[86 + N] = 8'b00100100;
	reg_tempr[87 + N] = 8'b00011000;

	reg_tempr[88 + N] = 8'b01111110;
	reg_tempr[89 + N] = 8'b11000011;
	reg_tempr[90 + N] = 8'b10011001;
	reg_tempr[91 + N] = 8'b10100101;
	reg_tempr[92 + N] = 8'b10100101;
	reg_tempr[93 + N] = 8'b10011001;
	reg_tempr[94 + N] = 8'b11000011;
	reg_tempr[95 + N] = 8'b01111110;
	////第四个烟花
	reg_tempr[96 + N] = 8'b0;
	reg_tempr[97 + N] = 8'b0;
	reg_tempr[98 + N] = 8'b00010000;
	reg_tempr[99 + N] = 8'b00011100;
	reg_tempr[100 + N] = 8'b00111000;
	reg_tempr[101 + N] = 8'b00001000;
	reg_tempr[102 + N] = 8'b0;
	reg_tempr[103 + N] = 8'b0;
	
	reg_tempr[104 + N] = 8'b0;
	reg_tempr[105 + N] = 8'b00010000;
	reg_tempr[106 + N] = 8'b00011000;
	reg_tempr[107 + N] = 8'b00111110;
	reg_tempr[108 + N] = 8'b01111100;
	reg_tempr[109 + N] = 8'b00011000;
	reg_tempr[110 + N] = 8'b00001000;
	reg_tempr[111 + N] = 8'b0;
	
	reg_tempr[112 + N] = 8'b00011000;
	reg_tempr[113 + N] = 8'b00100100;
	reg_tempr[114 + N] = 8'b01000010;
	reg_tempr[115 + N] = 8'b10011001;
	reg_tempr[116 + N] = 8'b10011001;
	reg_tempr[117 + N] = 8'b01000010;
	reg_tempr[118 + N] = 8'b00100100;
	reg_tempr[119 + N] = 8'b00011000;

	reg_tempr[120 + N] = 8'b01111110;
	reg_tempr[121 + N] = 8'b11000011;
	reg_tempr[122 + N] = 8'b10011001;
	reg_tempr[123 + N] = 8'b10100101;
	reg_tempr[124 + N] = 8'b10100101;
	reg_tempr[125 + N] = 8'b10011001;
	reg_tempr[126 + N] = 8'b11000011;
	reg_tempr[127 + N] = 8'b01111110;
	
	////第五个烟花
	reg_tempr[128 + N] = 8'b0;
	reg_tempr[129 + N] = 8'b0;
	reg_tempr[130 + N] = 8'b0;
	reg_tempr[131 + N] = 8'b0;
	reg_tempr[132 + N] = 8'b0;
	reg_tempr[133 + N] = 8'b0;
	reg_tempr[134 + N] = 8'b0;
	reg_tempr[135 + N] = 8'b0;
	
	reg_tempr[136 + N] = 8'b0;
	reg_tempr[137 + N] = 8'b0;
	reg_tempr[138 + N] = 8'b0;
	reg_tempr[139 + N] = 8'b0;
	reg_tempr[140 + N] = 8'b0;
	reg_tempr[141 + N] = 8'b0;
	reg_tempr[142 + N] = 8'b0;
	reg_tempr[143 + N] = 8'b0;
	
	reg_tempr[144 + N] = 8'b0;
	reg_tempr[145 + N] = 8'b0;
	reg_tempr[146 + N] = 8'b0;
	reg_tempr[147 + N] = 8'b0;
	reg_tempr[148 + N] = 8'b0;
	reg_tempr[149 + N] = 8'b0;
	reg_tempr[150 + N] = 8'b0;
	reg_tempr[151 + N] = 8'b0;
	
	reg_tempr[152 + N] = 8'b0;
	reg_tempr[153 + N] = 8'b0;
	reg_tempr[154 + N] = 8'b0;
	reg_tempr[155 + N] = 8'b0;
	reg_tempr[156 + N] = 8'b0;
	reg_tempr[157 + N] = 8'b0;
	reg_tempr[158 + N] = 8'b0;
	reg_tempr[159 + N] = 8'b0;
	
	////第六个烟花
	reg_tempr[160 + N] = 8'b0;
	reg_tempr[161 + N] = 8'b0;
	reg_tempr[162 + N] = 8'b0;
	reg_tempr[163 + N] = 8'b00011000;
	reg_tempr[164 + N] = 8'b00011000;
	reg_tempr[165 + N] = 8'b0;
	reg_tempr[166 + N] = 8'b0;
	reg_tempr[167 + N] = 8'b0;
	
	reg_tempr[168 + N] = 8'b0;
	reg_tempr[169 + N] = 8'b00000000;
	reg_tempr[170 + N] = 8'b00100100;
	reg_tempr[171 + N] = 8'b00011000;
	reg_tempr[172 + N] = 8'b00011000;
	reg_tempr[173 + N] = 8'b00100100;
	reg_tempr[174 + N] = 8'b0;
	reg_tempr[175 + N] = 8'b0;
	
	reg_tempr[176 + N] = 8'b0;
	reg_tempr[177 + N] = 8'b01000010;
	reg_tempr[178 + N] = 8'b00100100;
	reg_tempr[179 + N] = 8'b00011000;
	reg_tempr[180 + N] = 8'b00011000;
	reg_tempr[181 + N] = 8'b00100100;
	reg_tempr[182 + N] = 8'b01000010;
	reg_tempr[183 + N] = 8'b0;
	
	reg_tempr[184 + N] = 8'b10000001;
	reg_tempr[185 + N] = 8'b01000010;
	reg_tempr[186 + N] = 8'b00100100;
	reg_tempr[187 + N] = 8'b00011000;
	reg_tempr[188 + N] = 8'b00011000;
	reg_tempr[189 + N] = 8'b00100100;
	reg_tempr[190 + N] = 8'b01000010;
	reg_tempr[191 + N] = 8'b10000001;
	
	/////********绿色*********/////
	////第一个烟花
	reg_tempg[0 + N] = 8'b00000000;
	reg_tempg[1 + N] = 8'b00000000;
	reg_tempg[2 + N] = 8'b00000000;
	reg_tempg[3 + N] = 8'b00011000;
	reg_tempg[4 + N] = 8'b00011000;
	reg_tempg[5 + N] = 8'b00000000;
	reg_tempg[6 + N] = 			 0;
	reg_tempg[7 + N] = 			 0;
	
	reg_tempg[8 + N] = 			 0;
	reg_tempg[9 + N] = 			 0;
	reg_tempg[10 + N] = 8'b00011000;
	reg_tempg[11 + N] = 8'b00100100;
	reg_tempg[12 + N] = 8'b00100100;
	reg_tempg[13 + N] = 8'b00011000;
	reg_tempg[14 + N] = 			  0;
	reg_tempg[15 + N] = 			  0;
	
	reg_tempg[16 + N] = 			  0;
	reg_tempg[17 + N] = 8'b00000000;
	reg_tempg[18 + N] = 8'b00000000;
	reg_tempg[19 + N] = 8'b00011000;
	reg_tempg[20 + N] = 8'b00011000;
	reg_tempg[21 + N] = 8'b00000000;
	reg_tempg[22 + N] = 8'b00000000;
	reg_tempg[23 + N] = 			  0;
	
	reg_tempg[24 + N] = 8'b01101100;
	reg_tempg[25 + N] = 8'b00000001;
	reg_tempg[26 + N] = 8'b10000001;
	reg_tempg[27 + N] = 8'b10000000;
	reg_tempg[28 + N] = 8'b00000001;
	reg_tempg[29 + N] = 8'b10000001;
	reg_tempg[30 + N] = 8'b10000000;
	reg_tempg[31 + N] = 8'b00110110;
	////第二个烟花
	reg_tempg[32 + N] = 8'b0;
	reg_tempg[33 + N] = 8'b0;
	reg_tempg[34 + N] = 8'b00010000;
	reg_tempg[35 + N] = 8'b00011100;
	reg_tempg[36 + N] = 8'b00111000;
	reg_tempg[37 + N] = 8'b00001000;
	reg_tempg[38 + N] = 8'b0;
	reg_tempg[39 + N] = 8'b0;
	
	reg_tempg[40 + N] = 8'b0;
	reg_tempg[41 + N] = 8'b00010000;
	reg_tempg[42 + N] = 8'b00011000;
	reg_tempg[43 + N] = 8'b00111110;
	reg_tempg[44 + N] = 8'b01111100;
	reg_tempg[45 + N] = 8'b00011000;
	reg_tempg[46 + N] = 8'b00001000;
	reg_tempg[47 + N] = 8'b0;
	
	reg_tempg[48 + N] = 8'b00011000;
	reg_tempg[49 + N] = 8'b00100100;
	reg_tempg[50 + N] = 8'b01000010;
	reg_tempg[51 + N] = 8'b10011001;
	reg_tempg[52 + N] = 8'b10011001;
	reg_tempg[53 + N] = 8'b01000010;
	reg_tempg[54 + N] = 8'b00100100;
	reg_tempg[55 + N] = 8'b00011000;
	
	reg_tempg[56 + N] = 8'b01111110;
	reg_tempg[57 + N] = 8'b11000011;
	reg_tempg[58 + N] = 8'b10011001;
	reg_tempg[59 + N] = 8'b10100101;
	reg_tempg[60 + N] = 8'b10100101;
	reg_tempg[61 + N] = 8'b10011001;
	reg_tempg[62 + N] = 8'b11000011;
	reg_tempg[63 + N] = 8'b01111110;
	
	////3
	reg_tempg[64 + N] = 8'b0;
	reg_tempg[65 + N] = 8'b0;
	reg_tempg[66 + N] = 8'b0;
	reg_tempg[67 + N] = 8'b0;
	reg_tempg[68 + N] = 8'b0;
	reg_tempg[69 + N] = 8'b0;
	reg_tempg[70 + N] = 8'b0;
	reg_tempg[71 + N] = 8'b0;
	
	reg_tempg[72 + N] = 8'b0;
	reg_tempg[73 + N] = 8'b0;
	reg_tempg[74 + N] = 8'b0;
	reg_tempg[75 + N] = 8'b0;
	reg_tempg[76 + N] = 8'b0;
	reg_tempg[77 + N] = 8'b0;
	reg_tempg[78 + N] = 8'b0;
	reg_tempg[79 + N] = 8'b0;
	
	reg_tempg[80 + N] = 8'b0;
	reg_tempg[81 + N] = 8'b0;
	reg_tempg[82 + N] = 8'b0;
	reg_tempg[83 + N] = 8'b0;
	reg_tempg[84 + N] = 8'b0;
	reg_tempg[85 + N] = 8'b0;
	reg_tempg[86 + N] = 8'b0;
	reg_tempg[87 + N] = 8'b0;
	
	reg_tempg[88 + N] = 8'b0;
	reg_tempg[89 + N] = 8'b0;
	reg_tempg[90 + N] = 8'b0;
	reg_tempg[91 + N] = 8'b0;
	reg_tempg[92 + N] = 8'b0;
	reg_tempg[93 + N] = 8'b0;
	reg_tempg[94 + N] = 8'b0;
	reg_tempg[95 + N] = 8'b0;
	////第四个烟花
	reg_tempg[96 + N] = 8'b0;
	reg_tempg[97 + N] = 8'b0;
	reg_tempg[98 + N] = 8'b00010000;
	reg_tempg[99 + N] = 8'b00011100;
	reg_tempg[100 + N] = 8'b00111000;
	reg_tempg[101 + N] = 8'b00001000;
	reg_tempg[102 + N] = 8'b0;
	reg_tempg[103 + N] = 8'b0;
	
	reg_tempg[104 + N] = 8'b0;
	reg_tempg[105 + N] = 8'b00010000;
	reg_tempg[106 + N] = 8'b00011000;
	reg_tempg[107 + N] = 8'b00111110;
	reg_tempg[108 + N] = 8'b01111100;
	reg_tempg[109 + N] = 8'b00011000;
	reg_tempg[110 + N] = 8'b00001000;
	reg_tempg[111 + N] = 8'b0;
	
	reg_tempg[112 + N] = 8'b00011000;
	reg_tempg[113 + N] = 8'b00100100;
	reg_tempg[114 + N] = 8'b01000010;
	reg_tempg[115 + N] = 8'b10011001;
	reg_tempg[116 + N] = 8'b10011001;
	reg_tempg[117 + N] = 8'b01000010;
	reg_tempg[118 + N] = 8'b00100100;
	reg_tempg[119 + N] = 8'b00011000;

	reg_tempg[120 + N] = 8'b01111110;
	reg_tempg[121 + N] = 8'b11000011;
	reg_tempg[122 + N] = 8'b10011001;
	reg_tempg[123 + N] = 8'b10100101;
	reg_tempg[124 + N] = 8'b10100101;
	reg_tempg[125 + N] = 8'b10011001;
	reg_tempg[126 + N] = 8'b11000011;
	reg_tempg[127 + N] = 8'b01111110;
	////5
	reg_tempg[128 + N] = 8'b0;
	reg_tempg[129 + N] = 8'b0;
	reg_tempg[130 + N] = 8'b0;
	reg_tempg[131 + N] = 8'b00011000;
	reg_tempg[132 + N] = 8'b00011000;
	reg_tempg[133 + N] = 8'b0;
	reg_tempg[134 + N] = 8'b0;
	reg_tempg[135 + N] = 8'b0;
	
	reg_tempg[136 + N] = 8'b0;
	reg_tempg[137 + N] = 8'b00000000;
	reg_tempg[138 + N] = 8'b00100100;
	reg_tempg[139 + N] = 8'b00011000;
	reg_tempg[140 + N] = 8'b00011000;
	reg_tempg[141 + N] = 8'b00100100;
	reg_tempg[142 + N] = 8'b0;
	reg_tempg[143 + N] = 8'b0;
	
	reg_tempg[144 + N] = 8'b0;
	reg_tempg[145 + N] = 8'b01000010;
	reg_tempg[146 + N] = 8'b00100100;
	reg_tempg[147 + N] = 8'b00011000;
	reg_tempg[148 + N] = 8'b00011000;
	reg_tempg[149 + N] = 8'b00100100;
	reg_tempg[150 + N] = 8'b01000010;
	reg_tempg[151 + N] = 8'b0;
	
	reg_tempg[152 + N] = 8'b10000001;
	reg_tempg[153 + N] = 8'b01000010;
	reg_tempg[154 + N] = 8'b00100100;
	reg_tempg[155 + N] = 8'b00011000;
	reg_tempg[156 + N] = 8'b00011000;
	reg_tempg[157 + N] = 8'b00100100;
	reg_tempg[158 + N] = 8'b01000010;
	reg_tempg[159 + N] = 8'b10000001;
	////6
	reg_tempg[160 + N] = 8'b0;
	reg_tempg[161 + N] = 8'b0;
	reg_tempg[162 + N] = 8'b0;
	reg_tempg[163 + N] = 8'b0;
	reg_tempg[164 + N] = 8'b0;
	reg_tempg[165 + N] = 8'b0;
	reg_tempg[166 + N] = 8'b0;
	reg_tempg[167 + N] = 8'b0;
	
	reg_tempg[168 + N] = 8'b0;
	reg_tempg[169 + N] = 8'b0;
	reg_tempg[170 + N] = 8'b0;
	reg_tempg[171 + N] = 8'b0;
	reg_tempg[172 + N] = 8'b0;
	reg_tempg[173 + N] = 8'b0;
	reg_tempg[174 + N] = 8'b0;
	reg_tempg[175 + N] = 8'b0;
	
	reg_tempg[176 + N] = 8'b0;
	reg_tempg[177 + N] = 8'b0;
	reg_tempg[178 + N] = 8'b0;
	reg_tempg[179 + N] = 8'b0;
	reg_tempg[180 + N] = 8'b0;
	reg_tempg[181 + N] = 8'b0;
	reg_tempg[182 + N] = 8'b0;
	reg_tempg[183 + N] = 8'b0;
	
	reg_tempg[184 + N] = 8'b0;
	reg_tempg[185 + N] = 8'b0;
	reg_tempg[186 + N] = 8'b0;
	reg_tempg[187 + N] = 8'b0;
	reg_tempg[188 + N] = 8'b0;
	reg_tempg[189 + N] = 8'b0;
	reg_tempg[190 + N] = 8'b0;
	reg_tempg[191 + N] = 8'b0;
	
	//数码管
	ddd[0] = 16'b_11111100_01111111;
	ddd[1] = 16'b_01100000_01111111;
	ddd[2] = 16'b_11011010_01111111;
	ddd[3] = 16'b_11110010_01111111;
	ddd[4] = 16'b_01100110_01111111;
	ddd[5] = 16'b_10110110_01111111;
	ddd[6] = 16'b_10111110_01111111;
	ddd[7] = 16'b_11100000_01111111;
	ddd[8] = 16'b_11111110_01111111;
	ddd[9] = 16'b_11110110_01111111;
	ddd[10] = 16'b_11111111_00000000;		//自检-全亮
	ddd[11] = 16'b_00000000_00000000;		//自检-全灭
	
	//谱子，，这不让整个数组一起复制也太蠢了
	notes[0] = 4;
	notes[1] = 5;
	notes[2] = 6;
	notes[3] = 4;
	notes[4] = 8;
	notes[5] = 8;
	notes[6] = 8;
	notes[7] = 6;
	notes[8] = 5;
	notes[9] = 5;
	notes[10] = 8;
	notes[11] = 8;
	notes[12] = 5;
	notes[13] = 5;
	notes[14] = 4;
	notes[15] = 2;
	notes[16] = 6;
	notes[17] = 6;
	notes[18] = 6;
	notes[19] = 4;
	notes[20] = 3;
	notes[21] = 3;
	notes[22] = 3;
	notes[23] = 3;
	notes[24] = 4;
	notes[25] = 3;
	notes[26] = 2;
	notes[27] = 2;
	notes[28] = 3;
	notes[29] = 3;
	notes[30] = 4;
	notes[31] = 5;
	notes[32] = 1;
	notes[33] = 1;
	notes[34] = 4;
	notes[35] = 4;
	notes[36] = 5;
	notes[37] = 6;
	notes[38] = 7;
	notes[39] = 7;
	notes[40] = 7;
	notes[41] = 6;
	notes[42] = 5;
	notes[43] = 4;
	notes[44] = 5;
	notes[45] = 5;
	notes[46] = 5;
	notes[47] = 5;
	notes[48] = 4;
	notes[49] = 5;
	notes[50] = 6;
	notes[51] = 4;
	notes[52] = 8;
	notes[53] = 8;
	notes[54] = 8;
	notes[55] = 6;
	notes[56] = 5;
	notes[57] = 5;
	notes[58] = 8;
	notes[59] = 8;
	notes[60] = 5;
	notes[61] = 5;
	notes[62] = 4;
	notes[63] = 2;
	notes[64] = 2;
	notes[65] = 2;
	notes[66] = 3;
	notes[67] = 4;
	notes[68] = 1;
	notes[69] = 1;
	notes[70] = 1;
	notes[71] = 1;
	notes[72] = 1;
	notes[73] = 1;
	notes[74] = 2;
	notes[75] = 2;
	notes[76] = 3;
	notes[77] = 3;
	notes[78] = 4;
	notes[79] = 5;
	notes[80] = 1;
	notes[81] = 1;
	notes[82] = 4;
	notes[83] = 4;
	notes[84] = 5;
	notes[85] = 6;
	notes[86] = 7;
	notes[87] = 7;
	notes[88] = 7;
	notes[89] = 6;
	notes[90] = 5;
	notes[91] = 4;
	notes[92] = 4;
	notes[93] = 4;
	notes[94] = 4;
	notes[95] = 4;
	
	notes[96] = 0;
	notes[97] = 7;
	notes[98] = 8;
	notes[99] = 8;
	notes[100] = 8;
	notes[101] = 8;
	notes[102] = 8;
	notes[103] = 8;
	notes[104] = 8;
	notes[105] = 8;
	notes[106] = 8;
	notes[107] = 9;
	notes[108] = 8;
	notes[109] = 7;
	notes[110] = 6;
	notes[111] = 6;
	notes[112] = 6;
	notes[113] = 6;
	notes[114] = 6;
	notes[115] = 6;
	notes[116] = 6;
	notes[117] = 6;
	notes[118] = 6;
	notes[119] = 7;
	notes[120] = 6;
	notes[121] = 5;
	notes[122] = 4;
	notes[123] = 4;
	notes[124] = 4;
	notes[125] = 4;
	notes[126] = 4;
	notes[127] = 3;
	notes[128] = 2;
	notes[129] = 2;
	notes[130] = 3;
	notes[131] = 3;
	notes[132] = 3;
	notes[133] = 4;
	notes[134] = 5;
	notes[135] = 5;
	notes[136] = 5;
	notes[137] = 6;
	notes[138] = 5;
	notes[139] = 6;
	notes[140] = 5;
	notes[141] = 5;
	notes[142] = 5;
	notes[143] = 5;
	notes[144] = 6;
	notes[145] = 7;
	notes[146] = 8;
	notes[147] = 8;
	notes[148] = 8;
	notes[149] = 8;
	notes[150] = 8;
	notes[151] = 8;
	notes[152] = 8;
	notes[153] = 8;
	notes[154] = 8;
	notes[155] = 9;
	notes[156] = 8;
	notes[157] = 7;
	notes[158] = 6;
	notes[159] = 6;
	notes[160] = 6;
	notes[161] = 6;
	notes[162] = 6;
	notes[163] = 7;
	notes[164] = 6;
	notes[165] = 5;
	notes[166] = 4;
	notes[167] = 3;
	notes[168] = 2;
	notes[169] = 2;
	notes[170] = 3;
	notes[171] = 3;
	notes[172] = 4;
	notes[173] = 5;
	notes[174] = 1;
	notes[175] = 1;
	notes[176] = 4;
	notes[177] = 4;
	notes[178] = 5;
	notes[179] = 6;
	notes[180] = 5;
	notes[181] = 5;
	notes[182] = 5;
	notes[183] = 5;
	notes[184] = 5;
	notes[185] = 4;
	notes[186] = 4;
	notes[187] = 4;
	notes[188] = 4;
	notes[189] = 4;
	notes[190] = 4;
	notes[191] = 4;
	
	note = 0;
end

/*
reg [7:0] ROW_r0 [7:0 + N] = {
					8'b00000000,8'b00000000,8'b00000000,8'b00011000,
					8'b00011000,8'b00000000,0,0
				};
reg [7:0] ROW_r1 [7:0 + N] = {
					0,0,8'b00011000,8'b00100100,
					8'b00100100,8'b00011000,0,0
				};
reg [7:0] ROW_r2 [7:0 + N] = {
					0,8'b00011000,8'b00100100,8'b01001010,
					8'b01010010,8'b00100100,8'b00011000,0
				};
reg [7:0] ROW_r3 [7:0 + N] = {
					8'b00011000,8'b01100110,8'b01000110,8'b10010001,
					8'b10001001,8'b01100010,8'b01100110,8'b00011000
				};*/
				
always @(posedge clk)
begin

//测试蜂鸣器是否能正确播放音乐
if(djs == 0)
begin

if(beat < 10_666_666)
beat <= beat + 1;
else
begin
	beat <= 0;
	if(note < 96)
	note <= note + 1;
	else
	note <= 96;//停下来
end

case(notes[note])
0:_freq = p0;
1:_freq = g1;
2:_freq = a1;
3:_freq = b1;
4:_freq = c2;
5:_freq = d2;
6:_freq = e2;
7:_freq = f2;
8:_freq = g2;
9:_freq = a2;
endcase

if(freq < _freq)
freq <= freq + 1;
else
begin
	freq <= 0;
	beep <= ~beep;
end

end	//这个对应前面的if(djs==0)
else;

if(btn && ~fireon)		//全部放完之后重新开始
begin
	djs <= 9;
	frame <= 3;
	note <= 0;
end
else;

if(djs > 10)			//开机3秒自检
begin
	if(djsclk < 50_000_000)
	begin
		djsclk <= djsclk + 1;
			if(djsclk == 25_000_000)
			disp <= ddd[11];
			else if(djsclk == 1)
			disp <= ddd[10];
			else;
	end
	else
		begin
			djsclk <= 0;
			djs <= djs - 1;
			frame <= frame + 1;
			disp <= ddd[10];
		end
end

else if(djs == 10)	//自检完成等待按下开始键
begin

	disp <= ddd[11];
	frame <= 3;
	if(btn)
	begin
		ksdjs <= 1;
		djs <= 9;
		end
	else;
end

else if(djs > 0 && djs < 10 && ksdjs)	//10s倒计时
begin
lcdon <= 1;
	if(djsclk < 50_000_000)
		djsclk <= djsclk + 1;
	else
		begin
			djsclk <= 0;
			djs <= djs - 1;
		end
end

else if(djs == 0)
begin



		if(djsclk < 12_500_000)
		djsclk <= djsclk + 1;
	else
		begin
			djsclk <= 0;
			if(frame < 28)
			begin
				frame <= frame + 1;
				rst_n <= 0;		//lcd显示内容
				fireon <= 1;	//正在播放
			end
			else
			begin
				//rst_n <= 1;
				fireon <= 0;
				lcdon <= 0;
			end
		end
end

else;

if(refresh < 50001)		//屏幕一直在循环
	refresh <= refresh + 1;
else
	begin
		refresh <= 0;
		if(ain < 8)
			ain <= ain + 1;
		else
			ain <= 0;
	end

	 case (ain)
  0:begin
  COL<=reg_tempr[0 + 8 * frame];
  COLG<=reg_tempg[0 + 8 * frame];
  ROW<=~8'b10000000;
  end
  1:begin
     COL<=reg_tempr[1 + 8 * frame];
	  COLG<=reg_tempg[1 + 8 * frame];
     ROW<=~8'b01000000;
  end
  2:begin
     COL<=reg_tempr[2 + 8 * frame];
	  COLG<=reg_tempg[2 + 8 * frame];
     ROW<=~8'b00100000;
  end
  3:begin
	  COL<=reg_tempr[3 + 8 * frame];
	  COLG<=reg_tempg[3 + 8 * frame];
	  ROW<=~8'b00010000;
	  end
	4:begin
		COL<=reg_tempr[4 + 8 * frame];
		COLG<=reg_tempg[4 + 8 * frame];
		ROW<=~8'b00001000;
		end
	5:begin
		COL<=reg_tempr[5 + 8 * frame];
		COLG<=reg_tempg[5 + 8 * frame];
		ROW<=~8'b00000100;
		end
	6:begin
		COL<=reg_tempr[6 + 8 * frame];
		COLG<=reg_tempg[6 + 8 * frame];
		ROW<=~8'b00000010;
		end
	7:begin
		COL<=reg_tempr[7 + 8 * frame];
		COLG<=reg_tempg[7 + 8 * frame];
		ROW<=~8'b00000001;
		end

  endcase
  
if(0 < djs && djs < 10)	//数码管显示内容
	disp <= ddd[djs];
else if(djs == 0)
	disp <= ddd[11];
	else;

end

wire rst_n_;
wire lcdon_;
assign lcdon_ = lcdon;
assign rst_n_ = rst_n;
lcd_1602_driver lcd_1602_1(
                .clk(clk)    ,
                .rst_n(rst_n_)  ,
                .lcd_en(lcd_en) ,
                .lcd_rw(lcd_rw) ,  //因为只执行写操作，所以永远为0.
                .lcd_rs(lcd_rs) ,
                .lcd_data(lcd_data),
					 .enable(lcdon_)
              );


endmodule
