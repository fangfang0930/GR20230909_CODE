/*====================================================================
文件名：rcvr.v
作者：赵淑玉
版本：2009-08-12  1.0
功能描述：上行数据发送，包括故障信息、单元状态、直流侧电压、温度（暂未加）
====================================================================*/
module rect_down(clk, rect_en, rect_data, rect_sent);
    
    input	clk;
    input	rect_en;
    input	[19:0]rect_data;
    
    output	rect_sent;
    
    reg		rect_sent;
    
    reg		clk1x_en;
    reg		[7:0]no_bits_sent;
    reg		sent_en, sent_en_delay;
    reg		[15:0]clk_div;
    reg		[19:0]rsr;
    reg		[7:0]tsr;
    
    initial
    begin
	rect_sent = 1'b0;
	clk1x_en = 1'b0;
	no_bits_sent = 8'b0;
	sent_en = 1'b0;
	sent_en_delay = 1'b0;
	clk_div = 16'b0;
	rsr = 20'b0;
	tsr = 8'b0;
	end
    
/*------------------------------clk分频-----------------------------------*/
    always@(posedge clk)
    begin
    if(!clk1x_en)
        clk_div = 16'b0;
    else if(clk_div < 16'd2222)
        clk_div = clk_div + 1'b1;
    else
		clk_div = 16'b0;
    end
    
/*--------------------------选择及发送就绪-----------------------------*/
	always@(posedge clk)
	begin
	if(rect_en)
		begin
        if(!clk1x_en)
            begin
            sent_en <= 1'b1;
            sent_en_delay <= 1'b0;
            end
        else
            sent_en_delay <= 1'b1;
        end
    else if(sent_en_delay && !clk1x_en)
        begin
        sent_en <= 1'b1;
        sent_en_delay <= 1'b0;
        end
    else
        sent_en <= 1'b0;
    end
    
    always@(posedge clk)
    begin
	if(sent_en)
		begin
		clk1x_en <= 1'b1;
		rsr <= rect_data;
        end
    else if(no_bits_sent >= 8'd84)
		clk1x_en <= 1'b0;
	end

/*-----------------------发送位数计数-------------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        no_bits_sent <= 8'b0;
    else if(clk_div == 16'd2222)
        no_bits_sent <= no_bits_sent + 1'b1;
    end
    
/*------------------------各类数据上行发送-------------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        begin
        rect_sent <= 1'b0;
        end
    else if(clk_div == 16'd1)
        begin
        if(no_bits_sent == 8'd0)
			begin
			rect_sent <= 1'b1;
			tsr <= 8'h55;
			end
		else if(no_bits_sent == 8'd12)
			begin
			rect_sent <= 1'b1;
			tsr <= {4'b0,rsr[19:16]};
			end
		else if(no_bits_sent == 8'd24 || no_bits_sent == 8'd48)
			begin
			rect_sent <= 1'b1;
			tsr <= rsr[15:8];
			end
		else if(no_bits_sent == 8'd36 || no_bits_sent == 8'd60)
			begin
			rect_sent <= 1'b1;
			tsr <= rsr[7:0];
			end
		else if(no_bits_sent == 8'd72)
			begin
			rect_sent <= 1'b1;
			tsr <= 8'hAA;
			end
        else if ((no_bits_sent >= 8'd1 && no_bits_sent <= 8'd8) ||
			(no_bits_sent >= 8'd13 && no_bits_sent <= 8'd20) ||
			(no_bits_sent >= 8'd25 && no_bits_sent <= 8'd32) ||
			(no_bits_sent >= 8'd37 && no_bits_sent <= 8'd44) ||
			(no_bits_sent >= 8'd49 && no_bits_sent <= 8'd56) ||
			(no_bits_sent >= 8'd61 && no_bits_sent <= 8'd68) ||
			(no_bits_sent >= 8'd73 && no_bits_sent <= 8'd80))
            begin
            tsr[6:0] <= tsr[7:1];
            rect_sent <= ~tsr[0];
            end
        else
            rect_sent <= 1'b0;
        end
    end
    
endmodule
