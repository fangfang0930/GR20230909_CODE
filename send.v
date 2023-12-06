/*====================================================================
文件名：rcvr.v
作者：赵淑玉
版本：2009-08-12  1.0
功能描述：上行数据发送，包括故障信息、单元状态、直流侧电压、温度（暂未加）
====================================================================*/
module send(clk, fault_en, fre_en, volt_en, state_en,
			fre_data, volt, state, clk1x_en, sent);
    
    input	clk;
    input	fault_en, fre_en, volt_en, state_en;
    input	[15:0]fre_data, volt, state;
    
    output	clk1x_en;
    output	sent;
    
    reg		clk1x_en;
    reg		sent;
    
    reg		[7:0]no_bits_sent;
    reg		[1:0]cs;
    reg		[2:0]clk_div;
    reg		[20:0]rsr;
    reg		parity;
    reg		[20:0]tsr;
    reg		en;
    
    initial
    begin
	clk1x_en = 1'b0;
	sent = 1'b1;
	no_bits_sent = 8'b0;
	cs = 2'b0;
	clk_div = 3'b0;
	rsr = 21'b0;
	parity = 1'b1;
	tsr = 21'b0;
	en = 1'b0;
	end
    
/*------------------------------clk分频-----------------------------------*/
    always@(posedge clk)
    begin
    if(!clk1x_en)
        clk_div = 3'b0;
    else
        clk_div = clk_div + 1'b1;
    end
    
/*--------------------------选择及发送就绪-----------------------------*/
    always@(posedge clk)
    begin
    if(fault_en)
        begin
        cs = 2'b01;
        clk1x_en = 1'b1;
        rsr <= {5'b00101, 3'b111, 5'b00101, 3'b111, 5'b00101};
        end
    else if(fre_en)
		begin
		cs <= 2'b10;
		clk1x_en <= 1'b1;
		rsr <= {5'b00010, fre_data};
		end
    else if(state_en)
        begin
        cs <= 2'b10;
        clk1x_en <= 1'b1;
        rsr <= {5'b00100, state};
        end
    else if(volt_en)
        begin
        cs <= 2'b10;
        clk1x_en <= 1'b1;
        rsr <= {5'b00001, volt};
        end
    else if((cs == 2'b10 && no_bits_sent == 8'd75)||(cs == 2'b01 && no_bits_sent == 8'd150))
        begin
        cs <= 2'b0;
        clk1x_en <= 1'b0;
        end
    end

    always@(posedge clk)
    begin
    if(clk_div == 3'b011 && (no_bits_sent == 8'b0 || no_bits_sent == 8'd25 ||
		no_bits_sent == 8'd50 || no_bits_sent == 8'd75 || no_bits_sent == 8'd100 ||
		no_bits_sent == 8'd125))
        en <= 1'b1;
    else
        en <= 1'b0;
    end
/*-----------------------发送位数计数-------------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        no_bits_sent <= 8'b0;
    else if(clk_div == 3'b111)
        no_bits_sent <= no_bits_sent + 1'b1;
    end
    
/*------------------------各类数据上行发送-------------------------*/
    always@(posedge clk or negedge clk1x_en)
    begin
    if(!clk1x_en)
        begin
        parity <= 1'b1;
        sent <= 1'b1;
        end
    else if(en)
        begin
        tsr <= rsr;
        parity <= 1'b1;
        end
    else if(clk_div == 3'b011)
        begin
        if((no_bits_sent >= 8'd1 && no_bits_sent <= 8'd21) ||
			(no_bits_sent >= 8'd26 && no_bits_sent <= 8'd46) ||
			(no_bits_sent >= 8'd51 && no_bits_sent <= 8'd71) ||
			(no_bits_sent >= 8'd76 && no_bits_sent <= 8'd96) ||
			(no_bits_sent >= 8'd101 && no_bits_sent <= 8'd121) ||
			(no_bits_sent >= 8'd126 && no_bits_sent <= 8'd146))
            begin
            tsr[20:1] <= tsr[19:0];
            sent <= tsr[20];
            parity <= parity^tsr[20];
            end
        else if(no_bits_sent == 8'd22 || no_bits_sent == 8'd47 ||
				no_bits_sent == 8'd72 || no_bits_sent == 8'd97 ||
				no_bits_sent == 8'd122 || no_bits_sent == 8'd147)
            sent <= parity;
        else
            sent <= 1'b1;
        end
    end
    
endmodule
