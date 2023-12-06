/*====================================================================
�ļ�����PWM.v
���ߣ�������
�汾��2009-08-12  1.0
�������������ݸ�����������Ԫ״̬�����Ʋ���������PWM��
====================================================================*/
module PWM(clk, syn, start, check, pass, pose, nege, fre,
            fault, fault1, fault2, fault3, fault4,
            col1, col2, col3, col4,
            K_1, K_2, K_3, K_4, comp_tri, check_data);

    input	clk;
    input	syn;                   // ͬ������
    input	start, check, pass;
    input	[15:0]pose;        // ���Ʋ�����
    input	[15:0]nege;
    input	[15:0]fre;
    input	fault;
    input	fault1, fault2, fault3, fault4;
    input	col1, col2, col3, col4;
    
    output	K_1, K_2, K_3, K_4;
    output	[15:0]comp_tri;
    output	[15:0]check_data;
    
//    parameter max=280;           //��������ʱ��ֵ
    
    reg		K_1, K_2, K_3, K_4;
    reg		[15:0]comp_tri;            // ���ǲ�����ֵ
    reg		[15:0]check_data;
    reg		[15:0]bypass;
    
    reg		PA1;
    reg		PA2;
    reg		[9:0]d_data1;
    reg		[9:0]d_data2;
    reg		DIR;                     // ���ǲ�����ָ��
    
    initial
    begin
	K_1 = 1'b0;
	K_2 = 1'b0;
	K_3 = 1'b0;
	K_4 = 1'b0;
	comp_tri = 16'b0;
	check_data = 16'b0;
	
	PA1 = 1'b0;
	PA2 = 1'b0;
	d_data1 = 10'b0;
	d_data2 = 10'b0;
	DIR = 1'b0;
	end
    
/*---------------------�첽�������ǲ�---------------------*/
    always@(posedge clk)
    begin
    if(syn)                       //�첽����
        begin
        comp_tri <= 16'b0;
        DIR <= 1'b1;
        end
    else if(DIR)                         //DIR=1���Ӽ���
        begin
        if(comp_tri == fre)           //�����ӵ���ֵ��ʼ����
            begin
            DIR <= 1'b0;
            comp_tri <= comp_tri - 1'b1;
            end
        else
            comp_tri <= comp_tri + 1'b1;
        end
    else                            //DIR=0��������
        begin
        if(comp_tri == 16'b0)         //����������ʱ��ʼ����
            begin
            DIR <= 1'b1;
            comp_tri <= comp_tri + 1'b1;
            end
        else
            comp_tri <= comp_tri - 1'b1;
        end
    end

/*----------------------------�Ƚ����----------------------------*/
    always@(posedge clk)
    begin
    if(pose < fre[15:1])
        begin
        if(DIR)
            begin
            if(comp_tri[15:1] > pose)
                PA1 <= 1'b1;
            end
        else
            begin
            if(comp_tri[15:1] < pose)
                PA1 <= 1'b0;
            end
        end
    else
        PA1 <= 1'b0;
    end
    
    always@(posedge clk)
    begin
    if(nege < fre[15:1])
        begin
        if(DIR)
            begin
            if(comp_tri[15:1] > nege)
                PA2 <= 1'b1;
            end
        else
            begin
            if(comp_tri[15:1] < nege)
                PA2 <= 1'b0;
            end
        end
    else
        PA2 <= 1'b0;
    end

/*----------------------------��ͨʱ��----------------------------*/
    always@(posedge clk)
    begin
    if(!fault)
        bypass <= 16'b0;
    else if(bypass < 16'd20000)
        bypass <= bypass + 1'b1;
    else
		bypass <= 16'd20000;
    end
    
    always@(posedge clk)
    begin
	if(PA1)
		begin
        if(d_data1 < 10'd280)
            d_data1 <= d_data1 + 1'b1;
        else
            d_data1 <= 10'd280;
        end
    else
        begin
        if(d_data1 != 10'b0)
            d_data1 <= d_data1 - 1'b1;
        else
            d_data1 <= 10'b0;
        end
    end
    
    always@(posedge clk)
    begin
	if(PA2)
		begin
        if(d_data2 < 10'd280)
            d_data2 <= d_data2 + 1'b1;
        else
            d_data2 <= 10'd280;
        end
    else
        begin
        if(d_data2 != 10'b0)
            d_data2 <= d_data2 - 1'b1;
        else
            d_data2 <= 10'b0;
        end
    end
/*-----------------------------PWM���----------------------------*/
    always@(posedge clk)
    begin
    if(start && pose != 16'b0 && nege != 16'b0)
        begin
        if(d_data1 == 10'd280)//7us
			K_1 <= 1'b1;
		else
			K_1 <= 1'b0;
		if(d_data1 == 10'b0)
			K_2 <= 1'b1;
		else
			K_2 <= 1'b0;
		end
    else
        begin
        if(check)
            begin
            if(check_data <= 16'd9500 && col2)
                K_1 <= 1'b1;
            else
                K_1 <= 1'b0;
            if(check_data >= 16'd10000 && check_data <= 16'd19500 && col1)
                K_2 <= 1'b1;
            else
                K_2 <= 1'b0;
            end
        else if((bypass > 16'b0 && bypass < 16'd20000) || pass)
            begin
            if(!fault1 && !fault3 && col2 && col4)
                K_1 <= 1'b1;
            else
				begin
                K_1 <= 1'b0;
				if(!fault2 && !fault4 && col1 && col3)
					K_2 <= 1'b1;
                else
                    K_2 <= 1'b0;
                end
            end
        else
            begin
            K_1 <= 1'b0;
            K_2 <= 1'b0;
            end
        end
    end
    
    always@(posedge clk)
    begin
    if(start && pose != 16'b0 && nege != 16'b0)
        begin
        if(d_data2 == 10'd280)
			K_3 <= 1'b1;
		else
			K_3 <= 1'b0;
		if(d_data2 == 10'b0)
			K_4 <= 1'b1;
		else
			K_4 <= 1'b0;
		end
    else
        begin
        if(check)
            begin
            if(check_data >= 16'd20000 && check_data <= 29500 && col4)
                K_3 <= 1'b1;
            else
                K_3 <= 1'b0;
            if(check_data >= 16'd30000 && check_data <= 16'd39500 && col3)
                K_4 <= 1'b1;
            else
                K_4 <= 1'b0;
            end
        else if((bypass > 16'b0 && bypass < 16'd20000) || pass)
            begin
            if(!fault1 && !fault3 && col2 && col4)
                K_3 <= 1'b1;
            else
				begin
                K_3 <= 1'b0;
				if(!fault2 && !fault4 && col1 && col3)
					K_4 <= 1'b1;
                else
                    K_4 <= 1'b0;
                end
            end
        else
            begin
            K_3 <= 1'b0;
            K_4 <= 1'b0;
            end
        end
    end

/*------------------------�Լ�ʱ��------------------------*/    
    always@(posedge clk)
    begin
    if(!check)
        check_data <= 16'd0;
    else if(check_data < 16'd60000)
        check_data <= check_data + 1'b1;
    else
        check_data <= 16'd60000;
    end
    
endmodule
