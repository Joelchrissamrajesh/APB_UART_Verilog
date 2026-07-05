module fifo_counter
	(
		input clk,
		input reset,
		input [7:0]data_in,
		input push,
		input pop,
		output fifo_empty,
		output fifo_full,
		output  reg[4:0]count,
		output [7:0]data_out
	);
	integer i;
	reg [7:0]mem[15:0];
	reg [3:0]write_pointer,read_pointer;
	
	assign fifo_empty=(count==5'b00000)?1'b1:1'b0;
	
	assign fifo_full=(count==5'b10000)?1'b1:1'b0;
	

always@(posedge clk)
	begin
		if(reset)
			begin
			
				write_pointer<=4'b0;
				read_pointer<=4'b0;
				count<=5'd0;
				for(i=0;i<16;i=i+1)
					begin
					mem[i]<=8'd0;
					end
	end
			else if(push&&pop&&!fifo_full&&!fifo_empty)
				begin
					mem[write_pointer]<=data_in;
					
					read_pointer<=read_pointer+4'd1;
					write_pointer<=write_pointer+4'd1;
				end
			else if(push && !fifo_full &&count<=5'd15)
					begin
						mem[write_pointer]<=data_in;
						write_pointer<=write_pointer+4'd1;
						count<=count+1'b1;
					end
			else if(pop && !fifo_empty&&count>5'd0)
					begin
	
						read_pointer<=read_pointer+4'd1;
						count<=count-1'b1;
					end
	end
	assign data_out=mem[read_pointer];
	endmodule
