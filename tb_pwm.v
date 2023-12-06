`timescale 1ns / 1ns

module tb_PWM();
  reg clk;                   // 时钟信号
  reg syn;                   // 同步脉冲
  reg start, check, pass;    // 控制信号
  reg [15:0] pose;           // 正向调制波形
  reg [15:0] nege;           // 负向调制波形
  reg [15:0] fre;            // 三角波频率
  reg fault;                 // 故障信号
  reg fault1, fault2, fault3, fault4; // 其他故障信号
  reg col1, col2, col3, col4; // 碰撞信号
  
  wire  K_1, K_2, K_3, K_4;  // PWM输出信号
  wire [15:0] comp_tri;            // 三角波计数值
  wire [15:0] check_data;          // 自检数据
  
  // Instantiate the PWM module
  PWM uut (
    .clk(clk),
    .syn(syn),
    .start(start),
    .check(check),
    .pass(pass),
    .pose(pose),
    .nege(nege),
    .fre(fre),
    .fault(fault),
    .fault1(fault1),
    .fault2(fault2),
    .fault3(fault3),
    .fault4(fault4),
    .col1(K_1),
    .col2(K_2),
    .col3(K_3),
    .col4(K_4),
    .K_1(K_1),
    .K_2(K_2),
    .K_3(K_3),
    .K_4(K_4),
    .comp_tri(comp_tri),
    .check_data(check_data)
  );

  // Clock generation (20 MHz)
  always begin
    #1 clk = ~clk; // Generate a 20 MHz clock signal
  end

  // Test vector generation
  initial begin
    clk = 0;
    syn = 0;
    start = 0;
    check = 0;
    pass = 0;
    pose = 16'h1ff; // Set your test values here
    nege = 16'h2ff; // Set your test values here
    fre = 16'h0fff;  // Set your test values here
    fault = 0;
    fault1 = 0;
    fault2 = 0;
    fault3 = 0;
    fault4 = 0;
    col1 = 0;
    col2 = 0;
    col3 = 0;
    col4 = 0;

    // Apply test vectors and control signals
    #10 start = 1; // Start PWM
    #10 check = 0; // Enable self-check
    #10 pass = 0;  // Enable pass condition

    // Continue simulation
   // #1000;
   // $finish;
  end

  // Display signals
  always @(posedge clk) begin
    $display("Time=%0t K_1=%h K_2=%h K_3=%h K_4=%h", $time, K_1, K_2, K_3, K_4);
    $display("Time=%0t comp_tri=%h check_data=%h", $time, comp_tri, check_data);
  end

endmodule