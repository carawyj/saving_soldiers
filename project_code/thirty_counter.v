module thirty_counter(clk, reset_n, stop, done);
	input clk, reset_n, stop;
	output reg done;
	
	reg [4:0] count;
	
	always@(posedge clk)begin
	if (!reset_n)
	begin
		count <= 5'd0;
		done = 0;
	end
	
	else if (!stop)
	begin
		if (count == 5'd29)
			done = 1;
		else
		begin
			done =0;
			count <= count + 1;
		end
	end
	
	else if(stop)
		begin
			count <= 10'd0;
			done = 0;
		end
	end
endmodule