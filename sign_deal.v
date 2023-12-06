module sign_deal(clk, start, stop, rst, check, pass, Lockn, syn, rcvd,
			tr1, tr2, tr3, tr4, ov, uv, TEM, db, col1, col2, col3, col4,
			check_data, fre_data, state, comp_tri,
            fault, fault1, fault2, fault3, fault4, call_fault,
            ov_fault, uv_fault, db_fault, TEM_fault);

	input	clk;
	input	start, stop, rst, check, pass, Lockn, syn;//hff-下层模块采集给的
	input	rcvd;
	input	[15:0]comp_tri;//hff:三角波计数值
	input	tr1, tr2, tr3, tr4;
	input	ov, uv, TEM, db;
	input	col1, col2, col3, col4;
	input	[15:0]check_data, fre_data;
    
	output	[15:0]state;
	output	fault;
	output	fault1, fault2, fault3, fault4, call_fault;
	output	ov_fault, uv_fault, db_fault, TEM_fault;  //hff故障信号给LED
	
	wire	[15:0]state;
	wire	fault;
	reg		fault1, fault2, fault3, fault4;
	
	reg		[9:0]call_count1;
	reg		[3:0]call_count2;
	reg		connect;
	reg		call_fault;
	reg		ready;
	
	wire	switch_fault1, switch_fault2, switch_fault3, switch_fault4;
	wire	tr1_n, tr2_n, tr3_n, tr4_n;
	
	initial
	begin
	fault1 = 1'b0;
	fault2 = 1'b0;
	fault3 = 1'b0;
	fault4 = 1'b0;
	call_count1 = 10'b0;
	call_count2 = 4'b0;
	connect = 1'b0;
	call_fault = 1'b0;
	ready = 1'b0;
	end
	
	always@(posedge clk or posedge rst)
    begin
    if(rst)
        ready <= 1'b0;
    else if(syn || start || check)
        ready <= 1'b1;
    end

/*------------------------光纤通断检测--------------------------*/
    always@(posedge clk)
    begin
    if(ready)
        begin
        if(!rcvd)
            call_count1 <= 10'b0;
        else if(call_count1 < 10'd400)
            call_count1 <= call_count1 + 1'b1;
        else
            call_count1 <= 10'd400;
        end
    else
        call_count1 <= 10'b0;
    end
    
    always@(posedge clk)
    begin
	if(ready)
		begin
		if(syn)
			connect <= 1'b1;
		else if(comp_tri == fre_data)
			begin
			connect <= 1'b0;
			if(connect)
				call_count2 <= 4'b0;
			else if(call_count2 < 4'b0100)
				call_count2 <= call_count2 + 1'b1;
			else
				call_count2 <= 4'b0100;
			end
		end
	else
		call_count2 <= 4'b0;
	end

    always@(posedge clk)
    begin
    if(!ready)
        call_fault <= 1'b0;
    else if(call_count1 >= 10'd400 || 
			call_count2 >= 4'b0100)
        call_fault <= 1'b1;
    end
    
/*---------------------------自检信息-------------------------*/
	always@(posedge clk or posedge rst)
	begin
	if(rst)
		begin
		fault1 <= 1'b0;
		fault2 <= 1'b0;
		fault3 <= 1'b0;
		fault4 <= 1'b0;
		end
	else if(check_data == 16'd5000)
        begin
        if(col1 && col2)
            fault1 <= 1'b1;
        if(!col2)
            fault2 <= 1'b1;
        if(!col3)
            fault3 <= 1'b1;
        if(!col4)
            fault4 <= 1'b1;
        end
    else if(check_data == 16'd15000)
        begin
        if(!col1)
            fault1 <= 1'b1;
        if(col2 && col1)
            fault2 <= 1'b1;
        if(!col3)
            fault3 <= 1'b1;
        if(!col4)
            fault4 <= 1'b1;
        end
    else if(check_data == 16'd25000)
        begin
        if(!col1)
            fault1 <= 1'b1;
        if(!col2)
            fault2 <= 1'b1;
        if(col3 && col4)
            fault3 <= 1'b1;
        if(!col4)
            fault4 <= 1'b1;
        end
    else if(check_data == 16'd35000)
        begin
        if(!col1)
            fault1 <= 1'b1;
        if(!col2)
            fault2 <= 1'b1;
        if(!col3)
            fault3 <= 1'b1;
        if(col4 && col3)
            fault4 <= 1'b1;
        end
    else
		begin
		if(switch_fault1)
			fault1 <= 1'b1;
		if(switch_fault2)
			fault2 <= 1'b1;
		if(switch_fault3)
			fault3 <= 1'b1;
		if(switch_fault4)
			fault4 <= 1'b1;
		end
    end
    
/*--------------------------单元状态-------------------------------*/
    assign state = {2'b0, pass, check, ov_fault, uv_fault, TEM_fault, db_fault,
					fault1, fault2, fault3, fault4, start, (~Lockn), 1'b0, call_fault};
    
/*------------------------单元故障保护------------------------------*/    
    assign tr1_n = ~tr1;
    assign tr2_n = ~tr2;
    assign tr3_n = ~tr3;
    assign tr4_n = ~tr4;
    
    error t1(clk, rst, tr1_n, switch_fault1);
    error t2(clk, rst, tr2_n, switch_fault2);
    error t3(clk, rst, tr3_n, switch_fault3);
    error t4(clk, rst, tr4_n, switch_fault4);
    
 error ov_f(clk, rst, ov, ov_fault); //  error db_f(clk, rst, db, ov_fault);//
    alarm uv_f(clk, rst, uv, uv_fault);
  error  TEM_f(clk, rst, TEM, TEM_fault);// error TEM_f(clk, rst, TEM, TEM_fault);
   alarm db_f(clk, rst, db, db_fault); // alarm ov_f(clk, rst, ov, db_fault);
    
    assign fault = (call_fault || ov_fault || TEM_fault || fault1 || fault2 || fault3 || fault4);
    
endmodule

module error(clk, rst, in, out);
    
    input	clk;
    input	rst;
    input	in;
    
    output	out;
    
    reg		out;
    reg		[3:0]count;
	
    initial
		begin
		out = 0;
		count = 0;
	end
	
    always@(posedge clk)
    begin
    if(rst)
        begin
        count <= 4'b0;
        out <= 1'b0;
        end
    else if(in)
        begin
        if(count < 4'b1000)
            count <= count + 1'b1;
        else
			begin
			count <= 4'b1000;
            out <= 1'b1;
            end
        end
    else begin
		count <= 4'b0;
		 out <= 1'b0; //del
		end
    end
    
endmodule
module error1(clk, rst, in, out);
    
    input	clk;
    input	rst;
    input	in;
    
    output	out;
    
    reg		out;
    reg		[3:0]count;
    
    always@(posedge clk)
    begin
    if(rst)
        begin
        count <= 4'b0;
        out <= 1'b0;
        end
    else if(~in)
        begin
        if(count < 4'b1000)
            count <= count + 1'b1;
        else
			begin
			count <= 4'b1000;
            out <= 1'b1;
            end
        end
    else
		count <= 4'b0;
    end
    
endmodule

module alarm(clk, rst, in, out);
    
    input	clk;
    input	rst;
    input	in;
    
    output	out;
    
    reg		out;
    reg		[3:0]count;
     initial
		begin
		out = 0;
		count = 0;
	end
    always@(posedge clk)
    begin
    if(rst)
        begin
        count <= 4'b0;
        out <= 1'b0;
        end
    else if(in)
        begin
        if(count < 4'b1000)
            count <= count + 1'b1;
        else
            begin
			count <= 4'b1000;
            out <= 1'b1;
            end
        end
    else
		begin
        if(count != 4'b0)
            count <= count - 1'b1;
        else
            begin
			count <= 4'b0;
            out <= 1'b0;
            end
        end
    end
    
endmodule
module alarm1(clk, rst, in, out);
    
    input	clk;
    input	rst;
    input	in;
    
    output	out;
    
    reg		out;
    reg		[3:0]count;
    
    always@(posedge clk)
    begin
    if(rst)
        begin
        count <= 4'b0;
        out <= 1'b0;
        end
    else if(~in)
        begin
        if(count < 4'b1000)
            count <= count + 1'b1;
        else
            begin
			count <= 4'b1000;
            out <= 1'b1;
            end
        end
    else
		begin
        if(count != 4'b0)
            count <= count - 1'b1;
        else
            begin
			count <= 4'b0;
            out <= 1'b0;
            end
        end
    end
    
endmodule
	