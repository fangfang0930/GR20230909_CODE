/*====================================================================
文件名：rec.v
作者：赵淑玉
版本：2009-08-12  1.0
功能描述：下行数据接收模块
====================================================================*/
module rect_up(clk, t, rect_rcvd, rect_en, rect_data);

    input	clk;
    input	[19:0]t;
    input	rect_rcvd;
    
    output	rect_en;
    output	[19:0]rect_data;
    
    reg		rect_en;
    reg		[19:0]rect_data;
    
    reg		[7:0]tsr;
    reg		[11:0]clk_div;
    reg		[3:0]no_bits_rcvd;
    reg		clk1x_en;
    reg		error;
    reg		[3:0]rsr_ctrl, cs;
    reg		[7:0]rsr[2:5];
    reg		[15:0]rcvd_cnt;
    
    initial
	begin
    rect_en = 1'b0;
    rect_data = 20'b0;
    clk1x_en = 1'b0;
    clk_div = 12'b0;
    no_bits_rcvd  = 4'b0;
    tsr = 8'b0;
    error = 1'b0;
    rsr_ctrl = 4'b0;
    cs = 4'b0;
    rcvd_cnt = 16'b0;
    end
    
/*--------------------------clk分频---------------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        clk_div = 12'b0;
    else if(clk_div < 12'd2222)
        clk_div = clk_div + 1'b1;
    else
		clk_div = 12'b0;
    end
    
/*-----------------------数据接收使能信号控制------------------------*/
    always@(posedge clk)
    begin
    if(rect_rcvd && t == 20'hFFFFF)
        clk1x_en <= 1'b1;
    else if(error)
        clk1x_en <= 1'b0;
    else if(no_bits_rcvd >= 4'd8 && clk_div == 12'd2222)
        clk1x_en <= 1'b0;
    end

/*----------------------数据接收位数计数------------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        no_bits_rcvd <= 4'b0;
    else if(clk_div == 12'd2222)
        no_bits_rcvd <= no_bits_rcvd + 1'b1;
    end

/*--------------------串并转换，判断数据串正误--------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        begin
        error <= 1'b0;
        tsr <= 8'b0;
        end
    else if(clk_div == 12'd1111)
        begin
        if(no_bits_rcvd == 4'b0)
            begin
            if(!rect_rcvd)
                error <= 1'b1;
            end
        else if(no_bits_rcvd >= 4'd1 && no_bits_rcvd <= 4'd8)
            begin
            tsr[6:0] <= tsr[7:1];
            tsr[7] <= ~rect_rcvd;
            end
        end
    else
        error <= 1'b0;
    end
    
    always@(posedge clk)
    begin
	if(no_bits_rcvd == 4'd8 && clk_div == 12'd2222)
		begin
		if(cs == 4'b0)
			begin
			if(tsr == 8'h55)
				cs <= cs + 1'b1;
			end
		else if(cs == 4'b0001)
			begin
			rsr_ctrl <= tsr[3:0];
			cs <= cs + 1'b1;
			end
		else if(cs == 4'b0110)
			begin
			cs <= 4'b0;
			if(rsr[2] == rsr[4] && rsr[3] == rsr[5] && tsr == 8'hAA)
				begin
				rect_data <= {rsr_ctrl, rsr[2], rsr[3]};
				rect_en <= 1'b1;
				end
			end
		else
			begin
			rsr[cs] <= tsr;
			cs <= cs + 1'b1;
			end
		end
	else
		begin
		rect_en <= 1'b0;
		if(rcvd_cnt >= 16'd11111)
			cs <= 4'b0;
		end
	end
	
	always@(posedge clk)
    begin
	if((no_bits_rcvd == 4'd9 && clk_div == 12'd2222) || clk1x_en)
		rcvd_cnt <= 16'b0;
	else
		rcvd_cnt <= rcvd_cnt + 1'b1;
	end

endmodule
