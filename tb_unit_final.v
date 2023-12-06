`timescale 1ns/1ns

module tb_UNIT_FINAL();

   reg clk;
   reg tr1, tr2, tr3, tr4;
   reg ov, db, uv, TEM;
   reg col1, col2, col3, col4;
   reg rcvd;
   reg ad_in;
   wire adclk, cs_n;
   wire sent;
   wire K_1, K_2, K_3, K_4, K_5;
   wire LED1, LED2, LED3, LED4, LED5, LED6, LED7, LED8, LED9, LED10;

   // Clock generation
   initial begin
      clk = 0;
      forever #5 clk = ~clk;
   end

   // Instantiate UNIT_FINAL module
   UNIT_FINAL uut (
      .clk(clk),
      .tr1(tr1),
      .tr2(tr2),
      .tr3(tr3),
      .tr4(tr4),
      .ov(ov),
      .db(db),
      .uv(uv),
      .TEM(TEM),
      .col1(col1),
      .col2(col2),
      .col3(col3),
      .col4(col4),
      .rcvd(rcvd),
      .ad_in(ad_in),
      .adclk(adclk),
      .cs_n(cs_n),
      .K_1(K_1),
      .K_2(K_2),
      .K_3(K_3),
      .K_4(K_4),
      .K_5(K_5),
      .sent(sent),
      .LED1(LED1),
      .LED2(LED2),
      .LED3(LED3),
      .LED4(LED4),
      .LED5(LED5),
      .LED6(LED6),
      .LED7(LED7),
      .LED8(LED8),
      .LED9(LED9),
      .LED10(LED10)
   );

   // Test stimulus
   initial begin
      tr1 = 0;
      tr2 = 0;
      tr3 = 0;
      tr4 = 0;
      ov = 0;
      db = 0;
      uv = 0;
      TEM = 0;
      col1 = 0;
      col2 = 0;
      col3 = 0;
      col4 = 0;
      rcvd = 0;
      ad_in = 0;

      // Apply stimulus
      #10 tr1 = 1; // Example: Change tr1 value after 10 time units
      #20 tr1 = 0;
	  #20 uv = 1;
      // Add more stimulus as needed

      #1000 $finish; // Finish simulation after a certain time
   end

   // Monitor outputs
   always @(posedge clk) begin
      // Display outputs
      $display("Time=%0t adclk=%b cs_n=%b K_1=%b K_2=%b K_3=%b K_4=%b K_5=%b sent=%b LED1=%b LED2=%b LED3=%b LED4=%b LED5=%b LED6=%b LED7=%b LED8=%b LED9=%b LED10=%b",
               $time, adclk, cs_n, K_1, K_2, K_3, K_4, K_5, sent, LED1, LED2, LED3, LED4, LED5, LED6, LED7, LED8, LED9, LED10);
   end

endmodule
