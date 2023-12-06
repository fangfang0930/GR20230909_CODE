/*====================================================================
文件名：ad.v
作者：赵淑玉
版本：2009-08-12  1.0
功能描述：向AD芯片提供片选等信号，AD转换直流侧电压
====================================================================*/
module ad(clk, t_data, ad_in, adclk, cs_n, volt);

    input	clk;
    input	[15:0]t_data; //200US
    input	ad_in;
    
    output	adclk;
    output	cs_n;
    output	[15:0]volt;
    
    reg		cs_n;
    reg		adclk;
    reg		[15:0]volt;
    
    reg		[15:0]rsr;
    reg		[5:0]clk_div;
    reg		[4:0]ad_count;
    
    initial
    begin
	cs_n = 1'b1;
	adclk = 1'b1;
	volt = 16'b0;
	rsr = 16'b0;
	clk_div = 6'b0;
	ad_count = 5'b0;
	end
    //分频
    always@(posedge clk)
    begin
    if(t_data >= 16'd1 && t_data <= 16'd700)
        cs_n <= 1'b0;
    else
        cs_n <= 1'b1;
    end
    
    always@(posedge clk)
    begin
    if(cs_n)
        clk_div <= 6'b0;
    else
        begin
        if(clk_div < 6'd39)//HFF-1M 采样频率
            clk_div <= clk_div + 1'b1;
        else
            clk_div <= 6'b0;
        end
    end
    //hff-adclk形成
    always@(posedge clk)//HFF-1M adclk采样频率16个方波
    begin
    if(cs_n)
		adclk <= 1'b1;
    else if(clk_div == 6'd19)
        adclk <= 1'b1;
    else if(clk_div == 6'd39)
        begin
        if(ad_count >= 6'd16)
            adclk <= 1'b1;
        else
            adclk <= 1'b0;
        end
    end
    //volt计数
    always@(posedge clk)
    begin
    if(cs_n)
        begin
        volt <= rsr;
        ad_count <= 5'b0;
        end
    else if(clk_div == 6'd39)
        begin
        if(ad_count < 5'd16)
            ad_count <= ad_count + 1'b1;
        else
            ad_count <= 5'd16;
        end
    end
    //hff-数据转换rsr
    always@(posedge clk)
    begin
    if(clk_div == 6'd19)
        begin
        if(ad_count < 5'd16)
            begin
            rsr[0] <= ad_in;
            rsr[15:1] <= rsr[14:0];
            end
        end
    end
    
endmodule
