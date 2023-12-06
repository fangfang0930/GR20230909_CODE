module pwm_down(clk, t, rcvd,
            fault, fault1, fault2, fault3, fault4,
            col1, col2, col3, col4,
            start, stop, rst, check, pass,
			check_data, comp_tri,
			syn, Lockn, fre_data,
			K_1, K_2, K_3, K_4);
            
	input	clk;
    input	[19:0]t;
    input	rcvd;
    input	fault;
    input	fault1, fault2, fault3, fault4;
    input	col1, col2, col3, col4;
    
    output	start, stop, rst, check, pass;
    output	[15:0]check_data;
	output	syn;
	output	Lockn;
	output	[15:0]fre_data;
    output	K_1, K_2, K_3, K_4;
    output	[15:0]comp_tri;
    
    wire	over;
    wire	[19:0]tsr;
    wire	[1:0]clk_div;
    wire	[4:0]no_bits_rcvd;
    wire	clk1x_en;
    wire	[15:0]pose, nege;
    
    rcvr rcvr(clk, t, rcvd, over, tsr, clk_div, no_bits_rcvd, clk1x_en);
    
    down_deal down_deal(clk, comp_tri, over, tsr, clk_div, no_bits_rcvd, clk1x_en, fault,
			start, stop, rst, check, pass,
			syn, Lockn, fre_data, pose, nege);
			
	PWM PWM(clk, syn, start, check, pass, pose, nege, fre_data,
            fault, fault1, fault2, fault3, fault4,
            col1, col2, col3, col4,
            K_1, K_2, K_3, K_4, comp_tri, check_data);
            
endmodule
