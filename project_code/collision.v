module collision (AX, AY, BX, BY, sixty, go, reset_n, ld_x, ld_y, clk, finish, win);
	input [8:0] AX, AY, BX, BY;
	input sixty, go, reset_n, clk;
	input ld_x, ld_y;

	output reg win;
	output reg finish;
	
	reg [8:0] ax, ay, bx, by;
	//load ax, ay, bx, by
	always@(*)
	begin
		if (ld_x)
		begin
			ax <= AX;
			bx <= BX;
		end
		if (ld_y)
		begin
			ay <= AY;
			by <= BY;
		end
	end
	
	wire a_x, b_x, c_x, d_x;
	assign a_x =  ax + 5'd31 > bx;
	assign b_x = ax + 5'd31 < bx + 5'd31;
	assign c_x = ax > bx;
	assign d_x = ax < bx + 5'd31;

	wire a_y, b_y, c_y, d_y;
	assign a_y = ay > by;
	assign b_y = ay + 5'd31 < by + 5'd31;
	assign c_y = ay + 5'd31 > by;
	assign d_y = ay < by + 5'd31;
	
	wire times_up;
	reg counter_stop;
	ten_sec_counter c0(.clk(sixty), .reset_n(reset_n), .stop(counter_stop), .times_up(times_up));
	
	always@(*)
	begin 
	finish = 0;
	counter_stop =0;
	win <= 0;
	if (a_x & b_x & c_y & b_y)
	begin
		finish = 1;
		counter_stop = 1;
		win <= 1;
	end
	
	else if (a_x & b_x & a_y & d_y)
	begin
		finish = 1;
		counter_stop = 1;
		win <= 1;
	end
	
	else if (c_x & d_x & a_y & d_y)
	begin
		finish = 1;
		counter_stop = 1;
		win <= 1;
	end
	
	else if (c_x & d_x & c_y & b_y)
	begin
		finish = 1;
		counter_stop = 1;
		win <= 1;
	end
	
	else if (times_up)
	begin
		finish = 1;
	end
	end
endmodule

module ten_sec_counter(clk, reset_n, stop, times_up);
	input clk, reset_n, stop;
	output reg times_up;
	
	reg [7:0] count;
	
	always@(posedge clk)begin
	if (!reset_n)
	begin
		count <= 8'd0;
		times_up = 0;
	end
	
	else if (!stop)
	begin
		if (count == 8'd179)
			times_up = 1;
		else
		begin
			times_up =0;
			count <= count + 1;
		end
	end
	
	else if(stop)
		begin
		count <= 10'd0;
		times_up = 0;
		end
	end
endmodule