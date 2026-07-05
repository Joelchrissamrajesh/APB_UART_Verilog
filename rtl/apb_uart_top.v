module uart_top
	( 
		input pclk,
		input presetn,
		input [7:0]paddr,
		input [7:0] pwdata,
		input pwrite,
		input penable,
		input psel,
		input rxd,

		output [7:0]prdata,
		output irq,
		output pready,
		output pslveer,
	 	output txd
	);
	//--------------------wires----------------------//
		wire tx_fifo_empty;
		wire tx_fifo_full;
		wire tx_busy;
		wire [7:0]rx_data_out;
		wire rx_overrun;
		wire parity_error;
		wire framing_error;
		wire break_error;
		wire time_out;
		wire rx_fifo_empty;
		wire rx_fifo_full;
		wire [4:0]rx_fifo_count;
		wire [7:0]lcr;
		wire tx_fifo_we;
		wire rx_fifo_re;
		wire tx_enable;
		wire rx_enable;


//-----------------------------------------------------//
		register_block reg1 
									(
										.pclk(pclk),
										.presetn(presetn),
										.psel(psel),
										.pwrite(pwrite),
										.pwdata(pwdata),
									
										.penable(penable),
										.paddr(paddr),
										.tx_fifo_empty(tx_fifo_empty),
										.tx_fifo_full(tx_fifo_full),
										.tx_busy(tx_busy),
										.rx_data_out(rx_data_out),
										.rx_overrun(rx_overrun),
										.parity_error(parity_error),
										.framing_error(framing_error),
										.break_error(break_error),
										.time_out(time_out),
										.rx_fifo_empty(rx_fifo_empty),
										.rx_fifo_full(rx_fifo_full),
										.rx_fifo_count(rx_fifo_count),
										.prdata(prdata),
										.pready(pready),
										.pslverr(pslveer),
										.lcr(lcr),
										.tx_fifo_we(tx_fifo_we),
										.tx_enable(tx_enable),
										.rx_enable(rx_enable),
										.rx_fifo_re(rx_fifo_re),
										.loopback(),
			 							.irq(irq)
									);


	//--------------------------------------------------//
		transmitter tx1 
					(
						.pclk(pclk),
						.presetn(presetn),
						.pwdata(pwdata),
						.tx_fifo_push(tx_fifo_we),
						.enable(tx_enable),
						.lcr(lcr),
						.tx_fifo_count(),
						.busy(tx_busy),
						.tx_fifo_empty(tx_fifo_empty),
						.tx_fifo_full(tx_fifo_full),
						.txd(txd)
					);
	//-----------------------------------------------------//
			receiver_block rx1
								(
									.pclk(pclk),
									.presetn(presetn),
									.rxd(rxd),
									.rx_fifo_pop(rx_fifo_re),
									.enable(rx_enable),
									.lcr(lcr),
									.rx_fifo_empty(rx_fifo_empty),
									.rx_fifo_count(rx_fifo_count),
									.rx_fifo_out(rx_data_out),
									.rx_fifo_full(rx_fifo_full),
									.rx_overrun(rx_overrun),
									.parity_error(parity_error),
									.framing_error(framing_error),
									.break_error(break_error),
									.time_out(time_out)
								);
	endmodule
