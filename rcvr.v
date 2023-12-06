/*====================================================================
文件名：rec.v
作者：赵淑玉
版本：2009-08-12  1.0
功能描述：下行数据接收模块
====================================================================*/
module rcvr(clk, t, rcvd, over, tsr, clk_div, no_bits_rcvd, clk1x_en);

    input	clk;
    input	[19:0]t;
    input	rcvd;
    
    output	over;
    output	[19:0]tsr;
    output	[1:0]clk_div;
    output	[4:0]no_bits_rcvd;
    output	clk1x_en;
    
    reg		over;
    reg		[19:0]tsr;
    reg		[1:0]clk_div;
    reg		[4:0]no_bits_rcvd;
    reg		clk1x_en;
    
    reg		error;
    reg		parity;
    
    reg		[23:0]tt;
    
    initial
	begin
    over = 1'b0;
    error = 1'b0;
    clk1x_en = 1'b0;
    clk_div = 2'b0;
    no_bits_rcvd  = 5'b0;
    parity = 1'b1;
    tsr = 20'b0;
    tt = 24'b0;
    end
    
/*--------------------------clk分频---------------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        clk_div <= 2'b0;
    else
        clk_div <= clk_div + 1'b1;
    end
    
/*-----------------------数据接收使能信号控制------------------------*/
	always@(posedge clk)
	begin
	if (t == 20'hFFFFF)
		begin
		if (tt < 24'hFFFFFF)
			tt <= tt + 1'b1;
		else
			tt <= 24'hFFFFFF;
		end
	else
		tt <= 24'b0;
	end
	
    always@(posedge clk)
    begin
    if(rcvd && tt == 24'hFFFFFF)
        clk1x_en <= 1'b1;
    else if(error || over)
        clk1x_en <= 1'b0;
    else if(no_bits_rcvd == 5'd22 && clk_div == 2'b11)
        clk1x_en <= 1'b0;
    end

/*----------------------数据接收位数计数------------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        no_bits_rcvd <= 5'b0;
    else if(clk_div == 2'b11)
        no_bits_rcvd <= no_bits_rcvd + 1'b1;
    end

/*--------------------串并转换，判断数据串正误--------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        begin
        parity <= 1'b1;
        error <= 1'b0;
        over <= 1'b0;
        tsr <= 20'b0;
        end
    else if(clk_div == 2'b01)
        begin
        if(no_bits_rcvd == 5'b0)
            begin
            if(!rcvd)
                error <= 1'b1;
            end
        else if(no_bits_rcvd >= 5'd1 && no_bits_rcvd <= 5'd4)
            begin
            tsr[19:1] <= tsr[18:0];
            tsr[0] <= ~rcvd;
            parity <= parity^(~rcvd);
            end
        else if(no_bits_rcvd == 5'd5)
            begin
            if(tsr[3:0] == 4'b1100 || tsr[3:0] == 4'b1000)
                over <= 1'b1;
            else
                begin
                tsr[19:1] <= tsr[18:0];
                tsr[0] <= ~rcvd;
                parity <= parity^(~rcvd);
                end
            end
        else if(no_bits_rcvd >= 5'd5 && no_bits_rcvd <= 5'd20)
            begin
            tsr[19:1] <= tsr[18:0];
            tsr[0] <= ~rcvd;
            parity <= parity^(~rcvd);
            end
        else if(no_bits_rcvd == 5'd21)
            begin
            parity <= parity^(~rcvd);
            end
        else if(no_bits_rcvd == 5'd22)
            begin
            if(rcvd || parity)
                error <= 1'b1;
            end
        end
    else
        begin
        over <= 1'b0;
        error <= 1'b0;
        end
    end
    
endmodule
