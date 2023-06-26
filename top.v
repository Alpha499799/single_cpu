`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/21 09:57:33
// Design Name: 
// Module Name: top
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
//ENTER
wire GPIOf0000000_we;
wire GPIOe0000000_we;
wire GPIOf0;
wire [4:0] BTN_out;
wire [15:0] SW_out;
//clk_div
wire [31:0]clkdiv1;
wire Clk_CPU;
//SPIO
wire [1:0] counter_set;
wire [15:0] LED_out;
wire [15:0] led;
//dm_controller
wire [31:0] data_read;
wire [31:0] data_write_to_dm;
wire [3:0] wea_mem;
//counter_x
wire counter0_out;
wire counter1_out;
wire counter2_out;
wire [31:0] counter_out;
//ROM_D
wire [31:0] spo;
//SCPU
wire mem_w;
wire [31:0] PC_out;
wire [31:0] Addr_out;
wire [31:0] Data_out;
wire [2:0] dm_ctrl;
wire CPU_MIO;
wire INT;
//RAM_B
wire [31:0] douta;
//MIO_BUS
wire [31:0] Cpu_data4bus;
wire [31:0] ram_data_in;
wire [9:0] ram_addr;
wire counter_we;
wire [31:0] peripheral;
//Multi_8CH32
wire [63:0] LES;
wire [7:0] point_out;
wire [7:0] LE_out;
wire [31:0] Disp_num;
//SSeg7
wire [7:0] seg_an;
wire [7:0] seg_sout;

module top(
    input rstn,
    input [4:0]btn_i,
    input [15:0]sw_i,
    input clk,
    
    output[7:0]disp_an_o,
    output[7:0]disp_seg_o,
    
    output[15:0]led_o
    );
    
    

Enter enter(
    .clk(clk),
    .BTN(btn_i),
    .SW(sw_i),
    .BTN_out(BTN_out),
    .SW_out(SW_out)
    );
    
    

clk_div clk_div(
    .clk(clk),
    .rst(!rstn),
    .SW2(SW_out[2]),
    .clkdiv(clkdiv1),
    .Clk_CPU(Clk_CPU)
);


SPIO spio(
    .clk(!Clk_CPU),
    .rst(!rstn),
    .EN(GPIOf0000000_we),
    .P_Data(peripheral),                            //MIO_BUS 输出
    .counter_set(counter_set),
    .LED_out(LED_out),
    .led(led),
    .GPIOf0(GPIOf0)                        //MIO_BUS输出
);



dm_controller dm_controller(
    .mem_w(mem_w),                                  //SCPU输出
    .Addr_in(Addr_out),                             //SCPU输出
    .Data_write(ram_data_in),                          //MIO_BUS输出
    .dm_ctrl(dm_ctrl),                              //SCPU输出
    .Data_read_from_dm(Cpu_data4bus),               //MIO_BUS输出
    .Data_read(data_read),
    .Data_write_to_dm(data_write_to_dm),
    .wea_mem(wea_mem)
);




Counter_x counter_x(
    .clk(!Clk_CPU),
	.rst(!rstn),
    .clk0(clkdiv1[6]),
    .clk1(clkdiv1[9]),
    .clk2(clkdiv1[11]),
    .counter_we(counter_we),                        //MIO_BUS输出
    .counter_val(peripheral),                       //MIO_BUS 输出
    .counter_ch(counter_set),
    .counter0_OUT(counter0_out),
    .counter1_OUT(counter1_out),
    .counter2_OUT(counter2_out)
    //.counter_out(counter_out)
);


ROM_D rom_d(
    .a(PC_out[11:2]),
    .spo(spo)
);



RAM_B ram_b(
    .addra(ram_addr),
    .clka(!clk),
    .dina(data_write_to_dm),
    .wea(wea_mem),
    .douta(douta)
);



SCPU scpu(
  .clk(Clk_CPU),
  .reset(!rstn),
  .MIO_ready(CPU_MIO),
  .inst_in(spo),
  .Data_in(data_read), 
  .mem_w(mem_w),
  .PC_out(PC_out),
  .Addr_out(Addr_out),
  .Data_out(Data_out),
  .dm_ctrl(dm_ctrl),
  .CPU_MIO(CPU_MIO),
  .INT(counter0_out)
);



MIO_BUS mio_bus(
  .clk(clk),
  .rst(!rstn),
  .BTN(BTN_out),
  .SW(SW_out),
  .mem_w(mem_w),
  .Cpu_data2bus(Data_out),
  .addr_bus(Addr_out),
  .ram_data_out(douta),
  .led_out(LED_out),
  .counter_out(counter_out),
  .counter0_out(counter0_out),
  .counter1_out(counter1_out),
  .counter2_out(counter2_out),
  .Cpu_data4bus(Cpu_data4bus),
  .ram_data_in(ram_data_in),
  .ram_addr(ram_addr),
  .data_ram_we(),
  .GPIOf0000000_we(GPIOf0000000_we),
  .GPIOe0000000_we(GPIOe0000000_we),
  .counter_we(counter_we),
  .Peripheral_in(peripheral)
);

assign LES = 64'hffffffffffffffff;
wire [63:0] point_in1;
wire [31:0] data1;
assign point_in1 = {clkdiv1,clkdiv1};
assign data1 = {2'b00 , PC_out[31:2]};
Multi_8CH32 multi_8ch32(
  .clk(!Clk_CPU),
  .rst(!rstn),
  .EN(GPIOe0000000_we),
  .Switch(SW_out[7:5]),
  .point_in(point_in1),
  .LES(LES),
  .data0(peripheral),
  .data1(data1),
  .data2(spo),
  .data3(counter_out),
  .data4(Addr_out),
  .data5(Data_out),
  .data6(Cpu_data4bus),
  .data7(PC_out),
  .point_out(point_out),
  .LE_out(LE_out),
  .Disp_num(Disp_num)
);


SSeg7 sseg7(
  .clk(clk),
  .rst(!rstn),
  .SW0(SW_out[0]),
  .flash(clkdiv1[10]),
  .Hexs(Disp_num),
  .point(point_out),
  .LES(LE_out),
  .seg_an(seg_an),
  .seg_sout(seg_sout)
);

assign disp_an_o = seg_an;
assign disp_seg_o = seg_sout;
assign led_o = led;

endmodule
