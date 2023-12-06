module UNIT_FINAL(clk, tr1, tr2, tr3, tr4, ov, uv, TEM, db, col1, col2, col3, col4,
            ad_in, adclk, cs_n, K_1, K_2, K_3, K_4, K_5, rcvd, sent,
            LED1, LED2, LED3, LED4, LED5, LED6, LED7, LED8, LED9, LED10);
    
	input	clk;
	input	tr1, tr2, tr3, tr4;
	input	ov, db, uv, TEM;
	input	col1, col2, col3, col4;
	input	rcvd;
	input	ad_in;
	
	output	adclk, cs_n;
	output	sent;
	output	K_1, K_2, K_3, K_4, K_5;
	output	LED1, LED2, LED3, LED4, LED5, LED6, LED7, LED8, LED9, LED10;
    
	wire	[15:0]check_data;
	wire	[15:0]comp_tri;
	wire	fault;
	wire	fault1, fault2, fault3, fault4, call_fault;
	wire	syn;
	wire	start, stop, rst, check, pass;
	wire	Lockn;
	wire	[15:0]fre_data;
	wire	[15:0]volt;
	wire	ov_fault, uv_fault, db_fault, TEM_fault;
    
	reg		LED1, LED2, LED3, LED4, LED5, LED6, LED7, LED8, LED9, LED10;
	
	reg		[19:0]t;
	reg		[15:0]tri_200us;
	reg		[13:0]tri_count;
	
	wire	K_5;
	
	initial
	begin
	t = 20'b0;
	tri_200us = 16'b0;
	tri_count = 14'b0;
	end
	
	assign	K_5 = 1'b0;

/*-------------------------单元状态指示灯---------------------------*/
	always@(posedge clk)
	begin
	if(tri_count >= 14'd15000)//15000*200us=3s  0-亮
		begin
		LED1 <= ~fault1;
		LED2 <= ~fault2;
		LED3 <= ~fault3;
		LED4 <= ~fault4;
		LED5 <= ~ov_fault;//~ov_fault;//HFF
		LED6 <= ~uv_fault;//~uv_fault; //HFF
		LED7 <= ~TEM_fault;//~TEM_fault;//HFF
		LED8 <= ~call_fault;
		LED9 <= ~start;
		LED10 <= ~stop;
		end
	else if(tri_count <= 14'd2500)//2500*200us=500ms
		begin
		LED1 <= 1'b0;
		LED2 <= 1'b0;
		LED3 <= 1'b0;
		LED4 <= 1'b0;
		LED5 <= 1'b0;
		LED6 <= 1'b0;
		LED7 <= 1'b0;
		LED8 <= 1'b0;
		LED9 <= 1'b0;
		LED10 <= 1'b0;
		end
	else if(tri_count <= 14'd5000)//1s
		begin
		LED1 <= 1'b1;
		LED2 <= 1'b1;
		LED3 <= 1'b1;
		LED4 <= 1'b1;
		LED5 <= 1'b1;
		LED6 <= 1'b1;
		LED7 <= 1'b1;
		LED8 <= 1'b1;
		LED9 <= 1'b1;
		LED10 <= 1'b1;
		end
	else if(tri_count <= 14'd10000)//2s
		begin
		LED1 <= 1'b0;
		LED2 <= 1'b0;
		LED3 <= 1'b0;
		LED4 <= 1'b0;
		LED5 <= 1'b0;
		LED6 <= 1'b0;
		LED7 <= 1'b0;
		LED8 <= 1'b0;
		LED9 <= 1'b0;
		LED10 <= 1'b0;
		end
	else
		begin
		LED1 <= 1'b1;
		LED2 <= 1'b1;
		LED3 <= 1'b1;
		LED4 <= 1'b1;
		LED5 <= 1'b1;
		LED6 <= 1'b1;
		LED7 <= 1'b1;
		LED8 <= 1'b1;
		LED9 <= 1'b1;
		LED10 <= 1'b1;
		end
	end
	
	always@(posedge clk)
	begin
	if(t < 20'hFFFFF)
		t <= t + 1'b1;
	else
		t <= 20'hFFFFF;
	end
	
	always@(posedge clk)
	begin
	if(t < 20'hFFFFF)
		tri_200us <= 16'b0;
	else if(tri_200us < 16'd7999)
		tri_200us <= tri_200us + 1'b1;   //hff-200US
	else
		begin
		tri_200us <= 16'b0;
		if(tri_count < 14'd15000)
			tri_count <= tri_count + 1'b1;
		else
			tri_count <= 14'd15000;
		end
	end
	
	ad ad(clk, tri_200us, ad_in, adclk, cs_n, volt);
	
	pwm_down pwm_down(clk, t, rcvd,
            fault, fault1, fault2, fault3, fault4,
            col1, col2, col3, col4,
            start, stop, rst, check, pass,
			check_data, comp_tri,
			syn, Lockn, fre_data,
			K_1, K_2, K_3, K_4);
			
	pwm_up pwm_up(clk, start, stop, rst, check, pass, Lockn, syn, sent, rcvd, comp_tri,
            tr1, tr2, tr3, tr4, ov, uv, TEM, db, col1, col2, col3, col4,
            check_data, volt, tri_200us, fre_data,
            fault, fault1, fault2, fault3, fault4, call_fault,
            ov_fault, uv_fault, db_fault, TEM_fault);
	
endmodule
