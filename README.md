# single_cpu
#单周期CPU在ARTIX-7 100T实验板上的实现
#单周期处理器的大致连线在single.pdf文件中，主要分为不同模块，学生只需要修改CPU文件SCPU和分频文件dm即可
#
#
#
#
#remark：
#1.新建IP核：新建distributed核ROM_D 导入test.coe(原核未上传，这个为测试核)
#               block核RAM_B  导入2_D_mem.coe
#            并设置width和depth
#2.dm.v
#      mem_w选择是否读写
#      dm_ctrl选择执行操作(5个操作需3位二进制)
#      Addr_in的后两位决定读写数字的偏移量
#      wea_mem决定哪几位进行读写
#      是否读写    ->    选择执行操作     ->    选择哪几位写入   ->     对写入数据、标记位赋值
#      mem_w=1     ->    dm_ctrl = 011   ->   Addr_in = 10     ->     Data_write_to_dm = {4{Data_write[7:0]}} 、wea_mem = 0100
#      确定写      ->    选择写字节       ->    确定第3字节写入  ->    写入第3字节，使能位置1
