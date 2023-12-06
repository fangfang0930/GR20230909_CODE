/*====================================================================
�ļ�����up_sign.v
���ߣ�������
�汾��2009-08-12  1.0
�����������������ݷ���ʹ���ź�����
====================================================================*/
module up_sign(clk, t_data, clk1x_en, fault,
			fault_en, fre_en, volt_en, state_en);
            
    input	clk;
    input	[15:0]t_data;
    input	clk1x_en;
    input	fault;
    
    output	fault_en, fre_en, volt_en, state_en;
    
    reg		fault_en, fre_en, volt_en, state_en;
    reg		fault_delay1, fault_delay2, fre_en_delay, volt_en_delay, state_en_delay;
    
    initial
    begin
	fault_en = 1'b0;
	fre_en = 1'b0;
	volt_en = 1'b0;
	state_en = 1'b0;
	fault_delay1 = 1'b0;
	fault_delay2 = 1'b0;
	fre_en_delay = 1'b0;
	volt_en_delay = 1'b0;
	state_en_delay = 1'b0;
	end

/*========================������Ϣ����ʹ��========================*/
    always@(posedge clk)
    begin
    fault_delay1 <= fault;
    fault_delay2 <= fault_delay1;
    if(fault_delay1 && !fault_delay2)
        fault_en <= 1'b1;
    else
        fault_en <= 1'b0;
    end

/*========================ֱ�����ѹ���ݷ���ʹ��==================*/
    always@(posedge clk)
    begin
    if(t_data == 16'd1000)
        begin
        if(!clk1x_en)
            begin
            volt_en <= 1'b1;
            volt_en_delay <= 1'b0;
            end
        else
            volt_en_delay <= 1'b1;
        end
    else if(volt_en_delay && !clk1x_en)
        begin
        volt_en <= 1'b1;
        volt_en_delay <= 1'b0;
        end
    else
        volt_en <= 1'b0;
    end

/*=======================��Ԫ״̬����ʹ��========================*/
    always@(posedge clk)
    begin
    if(t_data == 16'd2000)
        begin
        if(!clk1x_en)
            begin
            state_en <= 1'b1;
            state_en_delay <= 1'b0;
            end
        else
            state_en_delay <= 1'b1;
        end
    else if(state_en_delay && !clk1x_en)
        begin
        state_en <= 1'b1;
        state_en_delay <= 1'b0;
        end
    else
        state_en <= 1'b0;
    end
    
/*========================ֱ�����ѹ���ݷ���ʹ��==================*/
    always@(posedge clk)
    begin
    if(t_data == 16'd3000)
        begin
        if(!clk1x_en)
            begin
            fre_en <= 1'b1;
            fre_en_delay <= 1'b0;
            end
        else
            fre_en_delay <= 1'b1;
        end
    else if(fre_en_delay && !clk1x_en)
        begin
        fre_en <= 1'b1;
        fre_en_delay <= 1'b0;
        end
    else
        fre_en <= 1'b0;
    end
    
endmodule
