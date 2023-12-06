module pwm_up(clk, start, stop, rst, check, pass, Lockn, syn, sent, rcvd, comp_tri,
            tr1, tr2, tr3, tr4, ov, uv, TEM, db, col1, col2, col3, col4,
            check_data, volt, t_data, fre_data,
            fault, fault1, fault2, fault3, fault4, call_fault,
            ov_fault, uv_fault, db_fault, TEM_fault);

	input	clk;
	input	start, stop, rst, check, pass, Lockn, syn;
	input	rcvd;
	input	[15:0]comp_tri;
	input	tr1, tr2, tr3, tr4;
	input	ov, uv, TEM, db;
	input	col1, col2, col3, col4;
	input	[15:0]check_data, volt, t_data, fre_data;
    
	output	sent;
	output	fault;
	output	fault1, fault2, fault3, fault4, call_fault;
	output	ov_fault, uv_fault, db_fault, TEM_fault;
	
	wire	[15:0]state;
	wire	clk1x_en;
	wire	fault_en, fre_en, volt_en, state_en;
	
	sign_deal sign_deal(clk, start, stop, rst, check, pass, Lockn, syn, rcvd,
			tr1, tr2, tr3, tr4, ov, uv, TEM, db, col1, col2, col3, col4,
			check_data, fre_data, state, comp_tri,
            fault, fault1, fault2, fault3, fault4, call_fault,
            ov_fault, uv_fault, db_fault, TEM_fault);

	up_sign up_sign(clk, t_data, clk1x_en, fault,
			fault_en, fre_en, volt_en, state_en);

	send send(clk, fault_en, fre_en, volt_en, state_en,
			fre_data, volt, state, clk1x_en, sent);

endmodule
