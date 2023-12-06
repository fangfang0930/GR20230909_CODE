/*====================================================================
文件名：rec.v
作者：赵淑玉
版本：2009-08-12  1.0
功能描述：下行数据接收模块
====================================================================*/
module down_deal(clk, comp_tri, over, tsr, clk_div, no_bits_rcvd, clk1x_en, fault,
			start, stop, rst, check, pass,
			syn, Lockn, fre_data, pose, nege);
			
	input	clk;
	input	[15:0]comp_tri;
	input	over;
	input	[19:0]tsr;
	input	[1:0]clk_div;
	input	[4:0]no_bits_rcvd;
	input	clk1x_en;
	input	fault;
	
	output	start, stop, rst, check, pass;
	output	syn;
	output	Lockn;
	output	[15:0]fre_data;
	output	[15:0]pose, nege;
	
	reg		start, stop, rst, check, pass;
	reg		syn;
	reg		Lockn;
	reg		[15:0]fre_data;
	reg		[15:0]pose, nege;
	
	reg		lock_delay;
	reg		[1:0]syn_error;
	reg		[15:0]ref_data, cmd_data;
	reg		ref_over, cmd_over;
	reg		[19:0]rsr1, rsr2;
	reg		[1:0]cs;
	reg		[15:0]cnt;
	
	initial
	begin
	start = 1'b0;
	stop = 1'b0;
	rst = 1'b0;
	check = 1'b0;
    syn = 1'b0;
    Lockn = 1'b1;
    fre_data = 16'd40000;
    pose = 16'b0;
    nege = 16'b0;
    
    lock_delay = 1'b0;
    syn_error = 2'b0;
    ref_data = 16'b0;
    cmd_data = 16'b0;
    ref_over = 1'b0;
    cmd_over = 1'b0;
    rsr1 = 20'b0;
    rsr2 = 20'b0;
    cnt = 16'b0;
    end
    
/*--------------------接收故障封锁包--------------------*/
    always@(posedge clk or posedge rst)
    begin
    if(rst)
        Lockn <= 1'b1;
    else if(over && tsr[3:0] == 4'b1100)
        begin
        if(!lock_delay && Lockn)
            lock_delay <= 1'b1;
        else
            begin
            Lockn <= 1'b0;
            lock_delay <= 1'b0;
            end
        end
    else if(cnt >= 16'd400)
        lock_delay <= 1'b0;
    end

/*--------------------------同步信号接收----------------------------*/
    always@(posedge clk)
    begin
    if(over && tsr[3:0] == 4'b1000)
        begin
        if(!start || comp_tri <= 16'd10 || syn_error == 2'b11)
            begin
            syn_error <= 2'b0;
            syn <= 1'b1;
            end
        else
            syn_error <= syn_error + 1'b1;
        end
    else
        syn <= 1'b0;
    end

/*--------------3选2控制命令、开关频率、调制波数据接收---------------*/
    always@(posedge clk)
    begin
    if(no_bits_rcvd == 5'd22 && clk_div == 2'b11)
        begin
        if(tsr == rsr1 || tsr == rsr2)
            begin
            cs <= 2'b0;
            if(tsr[19:16] == 4'b1001)
                begin
                ref_data <= tsr[15:0];
                ref_over <= 1'b1;
                end
            else if(tsr[19:16] == 4'b1010)
                begin
                cmd_data <= tsr[15:0];
                cmd_over <= 1'b1;
                end
            else if(tsr[19:16] == 4'b1011 && !start)
                begin
                fre_data <= tsr[15:0];
                end
            end
		else 
            begin
            if(cs == 2'b0)
                begin
                cs <= 2'b01;
                rsr1 <= tsr;
                end
            else if(cs == 2'b01)
                begin
                cs <= 2'b10;
                rsr2 <= tsr;
                end
            else if(cs == 2'b10)
                begin
                cs <= 2'b0;
                rsr1 <= tsr;
                end
            end
        end
    else
        begin
        ref_over <= 1'b0;
        cmd_over <= 1'b0;
        if(cnt >= 16'd400)
            begin
            cs <= 2'b0;
            rsr1 <= 20'b0;
            rsr2 <= 20'b0;
            end
        end
    end
    
    always@(posedge clk)
    begin
    if(clk1x_en)
        cnt <= 16'd0;
    else
        begin
        if(cnt < 16'd400)
            cnt <= cnt + 1'b1;
        else
            cnt <= 16'd400;
        end
    end
    
/*---------------------------载波周期设定------------------------------*/
	always@(posedge clk)
	begin
	if(!start)
		begin
		pose <= 16'b0;
		nege <= 16'b0;
		end
	else if(ref_over)
		begin
		if(ref_data >= fre_data)
			begin
			pose <= 16'b0;
			nege <= 16'b0;
			end
		else
			begin
			pose <= fre_data - ref_data;
			nege <= ref_data;
			end
		end
	end
    
/*---------------------------生成控制命令------------------------------*/
    always@(posedge clk)
    begin
    if(cmd_over)
        begin
        if(cmd_data == 16'h1111 && !fault && Lockn)
            start <= 1'b1;
        else if(cmd_data == 16'h2222 || cmd_data == 16'h6666)
            start <= 1'b0;
        end
    else if(fault || !Lockn)
        start <= 1'b0;
    end
    
    always@(posedge clk)
    begin
    if(cmd_over)
        begin
        if(cmd_data == 16'h2222)
            stop <= 1'b1;
        else if(cmd_data == 16'h1111 || cmd_data == 16'h4444 || cmd_data == 16'h6666)
            stop <= 1'b0;
        end
    else if(fault || !Lockn)
        stop <= 1'b1;
    end
    
    always@(posedge clk)
    begin
    if(cmd_over)
        begin
        if(cmd_data == 16'h4444 && !start)
            rst <= 1'b1;
        end
    else
        rst <= 1'b0;
    end
    
    always@(posedge clk)
    begin
    if(cmd_over)
        begin
        if(cmd_data == 16'h8888 && !start && Lockn)
            check <= 1'b1;
        else if(cmd_data == 16'h1111 || cmd_data == 16'h2222 ||
				cmd_data == 16'h4444 || cmd_data == 16'h6666)
			check <= 1'b0;
        end
    else if(!Lockn)
        check <= 1'b0;
    end
    
    always@(posedge clk)
    begin
    if(cmd_over)
        begin
        if(cmd_data == 16'h6666 && Lockn)
            pass <= 1'b1;
        else if(cmd_data == 16'h1111 || cmd_data == 16'h2222 || cmd_data == 16'h4444)
			pass <= 1'b0;
        end
    else if(!Lockn)
        pass <= 1'b0;
    end
    
endmodule
