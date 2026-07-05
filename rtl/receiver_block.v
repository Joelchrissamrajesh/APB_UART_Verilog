module receiver_block
	(
		input pclk,
		input presetn,
		input rxd,
		input rx_fifo_pop,
		input enable,
		input [7:0]lcr,
		output rx_fifo_empty,
		output  [4:0]rx_fifo_count,
		output     [7:0]rx_fifo_out,
		output     rx_fifo_full,
		output     rx_overrun,
	  output reg parity_error,
		output     framing_error,
		output     break_error,
		output     time_out
	);
	//----------------------internal_registers&wires_declaration----------//
		reg rxd1,rxd2;
		reg parity_temp;
		reg stop_bit_temp;
		reg [3:0]bit_counter;
		reg [7:0]rx_buffer;
		reg [7:0]brc_value;
	/*  reg framing_error_temp;  */
		reg [9:0]toc_value;
		reg [7:0]break_counter;
		reg [9:0]timeout_counter;
		reg	rx_fifo_push;
		reg [3:0]rx_state;
		reg [3:0]next_state;
	//--------------------------------------------------------------------//
	
	//-------------------------state_definitions--------------------------//
		localparam IDLE  =4'b0000,
							 START =4'b0001,
							 BIT0  =4'b0010,
							 BIT1	 =4'b0011,
							 BIT2	 =4'b0100,
							 BIT3	 =4'b0101,
							 BIT4	 =4'b0110,
							 BIT5	 =4'b0111,
							 BIT6	 =4'b1000,
							 BIT7	 =4'b1001,
							PARITY =4'b1010,
							STOP1  =4'b1011,
							STOP2  =4'b1100;
	//-------------------------------------------------------------------//
	
	//-------------------------fifo_counter_instantation----------//
		fifo_counter DUT
									(
										.clk(pclk),
										.reset(presetn),
										.data_in(rx_buffer),
										.push(rx_fifo_push),
										.pop(rx_fifo_pop),
										.fifo_empty(rx_fifo_empty),
										.fifo_full(rx_fifo_full),
										.count(rx_fifo_count),
										.data_out(rx_fifo_out)
									);
	//------------------------------------------------------------//
		
	//----------------------------state_logic-----------------------------//
		always@(posedge pclk)
				begin
		    	if(presetn)
				     rx_state<=IDLE;
		 			else
						rx_state<=next_state;
				end
	//--------------------------------------------------------------------//

	//-----------------------dual_flop_sync_logic--------------------------//
		always@(posedge pclk)
			begin
				rxd1<=rxd;
				rxd2<=rxd1;
				end
	//---------------------------------------------------------------------//
	
	//-------------------------------bit_counter_logic--------------------//
			always@(posedge pclk)
				begin
					if(presetn)
						begin
							bit_counter<=4'b0000;
						end
					else 
						begin
								if(enable)
											begin
													if((rx_state==START)&&bit_counter==4'h8)
										       bit_counter<=4'b0000;
						 		          else if((bit_counter==4'hf))
										       bit_counter<=4'b0000;
									        else
											     bit_counter<=bit_counter+1'b1;
									    end
								else
										bit_counter<=bit_counter;
						end
					end
	//----------------------------------------------------------------------//


	//------------------next_state_logic-----------------------------------//
		always@(*)
			begin
				  next_state = rx_state;   // default: stay in current state
					parity_error=1'b0;
					stop_bit_temp=1'b1;
			case(rx_state)
					IDLE :begin
								 	if(rxd2==1'b0 && !break_error)
										begin
											next_state=START;
										end
								else 
										begin
									  	next_state=IDLE;
					         	end
								end

				  START :begin
								  	if(bit_counter==4'h8&&enable&&rxd2==1'b0)
											 begin
											 	 next_state=BIT0;
											  end
								  	else
											next_state=START;
									end
						
				  BIT0 :begin
								  	if(bit_counter==4'hf&&enable)
											 begin
											 	 next_state=BIT1;
											  end
								  	else
											next_state=BIT0;
									end
						
				  BIT1 :begin
								  	if(bit_counter==4'hf&&enable)
											 begin
											 	 next_state=BIT2;
											  end
								  	else
											next_state=BIT1;
									end
						
				  BIT2 :begin
								  	if(bit_counter==4'hf&&enable)
											 begin
											 	 next_state=BIT3;
											  end
								  	else
											next_state=BIT2;
									end
						
				  BIT3 :begin
								  	if(bit_counter==4'hf&&enable)
											 begin
											 	 next_state=BIT4;
											  end
								  	else
											next_state=BIT3;
									end
						
					BIT4 :begin
									if(bit_counter==4'hf&&enable&&lcr[1:0]>2'b00)
										begin
											next_state=BIT5;
										end
									else if(bit_counter==4'hf&&enable&&lcr[1:0]==2'b00&&lcr[3]==1'b0)
											begin
												next_state=STOP1;
											end
									else if(bit_counter==4'hf&&enable&&lcr[1:0]==2'b00&&lcr[3]==1'b1)
												begin
													next_state=PARITY;
												end
									else if(enable)
											begin
												next_state=BIT4;
											end
									else
											next_state=BIT4;
							end
					BIT5 : begin
									if(bit_counter==4'hf&&enable&&lcr[1:0]>2'b01)
											begin
												next_state=BIT6;
											end
									else if(bit_counter==4'hf&&enable&&lcr[1:0]<2'b01&&lcr[3]==1'b0)
												begin
													next_state=STOP1;
												end
									else if(bit_counter==4'hf&&enable&&lcr[1:0]==2'b01&&lcr[3]==1'b1)
												begin
													next_state=PARITY;
												end
									else if(enable)
												begin
													next_state=BIT5;
												end
									else
												next_state=BIT5;
								end

					BIT6 : begin
									if(bit_counter==4'hf&&enable&&lcr[1:0]==2'b11)
										begin
											next_state=BIT7;
										end
									else if(bit_counter==4'hf&&enable&&lcr[1:0]!=2'b11&&lcr[3]==1'b0)
												begin
											   	next_state=STOP1;
							        	end
									else if(bit_counter==4'hf&&enable&&lcr[3]==1'b1)
									       begin
														next_state=PARITY;
													end
									else
												begin
											  	next_state=BIT6;
												end
									end
					BIT7 :begin
									if(bit_counter==4'hf&&enable&&lcr[3]==1'b1)
											begin
												next_state=PARITY;
											end
									else if(bit_counter==4'hf && enable && lcr[3]==1'b0)
												begin
													next_state=STOP1;
												end
										else
											begin
												next_state=BIT7;
											end
							  end
								
				PARITY :begin
									parity_temp=rxd2;
								case(lcr[5:3])
												3'b001:parity_error=(parity_temp==^rx_buffer)?1'b0:1'b1;
												3'b011:parity_error=(parity_temp==~^rx_buffer)?1'b0:1'b1;
												3'b101:parity_error=(parity_temp==~lcr[4])?1'b0:1'b1;
												3'b111:parity_error=(parity_temp==~lcr[4])?1'b0:1'b1;
												default:parity_error=1'b0;
								endcase
									if(bit_counter==4'hf&&enable&&lcr[3]==1'b0)
									begin
											next_state=STOP2;
										end
									else if(bit_counter==4'hf&&enable)
											begin
												next_state=STOP1;
											end
									else
											begin
												next_state=PARITY;
											end
                 end

				STOP1:begin
									stop_bit_temp=rxd2;

								if(bit_counter==4'hf&&enable&&lcr[2]==1'b1)
											begin
												next_state=STOP2;
											end
									else
											begin
												next_state=STOP1;
											end
							end
			STOP2:begin
							stop_bit_temp=rxd2;
							if(!break_error)
							begin
									next_state=IDLE;
								end
							else
								next_state=STOP2;
						end
	default:next_state=IDLE;
	endcase
	end
//assign framing_error=((rx_state==STOP1||rx_state==STOP2)&&stop_bit_temp==0)?1'b1:1'b0;
assign framing_error=(stop_bit_temp==0)?1'b1:1'b0;
always@(*)
	begin
		toc_value=10'd0;
	case(lcr[3:0])
			4'd0:toc_value = 10'd447;
			4'd1:toc_value = 10'd511;
			4'd2:toc_value = 10'd575;
			4'd3:toc_value = 10'd639;
			4'd4:toc_value = 10'd511;
			4'd5:toc_value = 10'd575;
			4'd6:toc_value = 10'd639;
			4'd7:toc_value = 10'd703;
			4'd8:toc_value = 10'd511;
			4'd9:toc_value = 10'd575;

			4'd10:toc_value = 10'd639;
			4'd11:toc_value = 10'd703;
			4'd12:toc_value = 10'd575;
			4'd13:toc_value = 10'd639;
			4'd14:toc_value = 10'd703;
			4'd15:toc_value = 10'd767;
	endcase
	end
	//-----------------------------time_out_block-----------------//
	always@(posedge pclk)
			begin
				if(presetn)
						timeout_counter<=10'd639;
				else if(rx_fifo_push||rx_fifo_pop||!rx_fifo_count)
						timeout_counter<=toc_value;
				else if(enable&&timeout_counter!=10'd0)
							timeout_counter<=timeout_counter-1'b1;
				else
							timeout_counter<=timeout_counter;
			end
  assign time_out=(timeout_counter==10'd0)?1'b1:1'b0;
	//------------------------------break_out_block-----------------//
	always@(*)
		begin
				brc_value<=toc_value[9:2];
		end
	always@(posedge pclk)
		begin
			if(presetn)
					break_counter<=8'd159;
			else if(rxd2)
						break_counter<=brc_value;
			else
					begin
						if(enable&&break_counter!=8'd0)
								break_counter<=break_counter-1'b1;
						else
								break_counter<=break_counter;
					end
			end
	assign break_error=(break_counter==8'd0)?1'b1:1'b0;
 //-----------------------------------------------------------//
 	always@(posedge pclk)
			begin
				if(presetn)
						rx_fifo_push<=1'b0;
				else 
						begin
							if(rx_state==STOP1&&bit_counter==4'h8)
								rx_fifo_push<=1'b1;
							else
									rx_fifo_push<=1'b0;
          	end
			end
	//------------------------------------------------------------//
			always@(posedge pclk)
				begin
					if(presetn)
							rx_buffer<=8'd0;
					else if(bit_counter==4'h8)
							begin
								case(rx_state)
									BIT0:rx_buffer[0]<=rxd2;
									BIT1:rx_buffer[1]<=rxd2;
									BIT2:rx_buffer[2]<=rxd2;
									BIT3:rx_buffer[3]<=rxd2;
									BIT4:rx_buffer[4]<=rxd2;
									BIT5:rx_buffer[5]<=rxd2;
									BIT6:rx_buffer[6]<=rxd2;
									BIT7:rx_buffer[7]<=rxd2;
								endcase
							end
					end
	//-------------------------------------------------------------//
		assign rx_overrun=(rx_fifo_push&rx_fifo_full)?1'b1:1'b0;
endmodule
