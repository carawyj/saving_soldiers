module saved(
	x_position_b,
	y_position_b,
	x_position_a,
	y_position_a,
	start,
	clk,
	reset_n,
	x_out,
	y_out,
	color_out,
	plot_out,
	done,
	sixty_signal
	);
	
	input start, clk, reset_n, sixty_signal;
	input [8:0] x_position_b, x_position_a;
	input [7:0] y_position_b, y_position_a;
	output [8:0] x_out;
	output [7:0] y_out;
	output [2:0] color_out;
	output plot_out;
	output done;
	
	wire square_drawer_done;
	
	reg [8:0] x_a, x_b;
	reg [7:0] y_a, y_b;
	reg start_drawing;
	reg enabled;
	
	
	always @(posedge clk) begin
		if (~reset_n) begin
			start_drawing <= 0;
			enabled <= 0;
		end
		else if (start) begin
			enabled <= 1;
		end
		
		if (!enabled) begin	
			x_a <= x_position_a;
			x_b <= x_position_b;
			y_a <= y_position_a;
			y_b <= y_position_b;
		end
	end
	
	// draw sqaure unit
	draw_square saved_square_drawer(
	.clk(clk), 
	.reset_n(reset_n), 
	.AX(x_a), 
	.AY(y_a), 
	.BX(x_b), 
	.BY(y_b), 
	.mouth_sel(2'd3), 
	.x(x_out), 
	.y(y_out), 
	.color(color_out), 
	.plot(plot_out), 
	.done(square_drawer_done), 
	.go(start_drawing)
	);
	
	thirty_counter0 thirty_countersaved(
	.clk(sixty_signal), .reset_n(reset_n), .stop(start), .done(done)
	);
	
endmodule

module thirty_counter0(clk, reset_n, stop, done);
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