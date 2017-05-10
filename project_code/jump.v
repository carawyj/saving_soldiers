module jump(
	x_position_b,
	y_position_b,
	x_position_a,
	y_position_a,
	sixty_signal,
	clk,
	reset_n,
	x_out,
	y_out,
	color_out,
	plot_out
	);
	
	input sixty_signal, clk, reset_n;
	input [8:0] x_position_b, x_position_a;
	input [7:0] y_position_b, y_position_a;
	output [8:0] x_out;
	output [7:0] y_out;
	output [2:0] color_out;
	output plot_out;
	
	wire [8:0] black_drawer_x_position_a, black_drawer_x_position_b, square_drawer_x_position;
	wire [7:0] black_drawer_y_position_a, black_drawer_y_position_b, square_drawer_y_position;
	wire black_drawer_a_done, black_drawer_b_done, square_drawer_done;
	wire [2:0] black_drawer_color_a_out, black_drawer_color_b_out, square_drawer_color_out;
	wire black_drawer_plot_a_out, black_drawer_plot_b_out, square_drawer_plot_out;
	wire ld_signal;
	
	assign ld_signal = black_drawer_a_done || black_drawer_b_done;
	
	// Black drawer for saving square
	black_drawer black_drawer_a(
	.go(sixty_signal), 
	.clk(clk), 
	.reset_n(reset_n), 
	.done(black_drawer_a_done), 
	.plot(black_drawer_plot_a_out),
	.y_in(y_position_a), 
	.x_in(x_position_a), 
	.x_out(black_drawer_x_position_a), 
	.y_out(black_drawer_y_position_a), 
	.color_out(black_drawer_color_a_out)
	);
	
	// Black drawer for target square
	black_drawer black_drawer_b(
	.go(black_drawer_a_done), 
	.clk(clk), 
	.reset_n(reset_n), 
	.done(black_drawer_b_done), 
	.plot(black_drawer_plot_b_out), 
	.y_in(y_position_b), 
	.x_in(x_position_b), 
	.x_out(black_drawer_x_position_b), 
	.y_out(black_drawer_y_position_b), 
	.color_out(black_drawer_color_b_out)
	);
	
	// draw sqaure unit
	draw_square jump_square_drawer(
	.clk(clk), 
	.reset_n(reset_n), 
	.AX(x_position_a), 
	.AY(y_position_a), 
	.BX(x_position_b), 
	.BY(y_position_b), 
	.mouth_sel(2'd1), 
	.x(square_drawer_x_position), 
	.y(square_drawer_y_position), 
	.color(square_drawer_color_out), 
	.plot(square_drawer_plot_out), 
	.done(square_drawer_done), 
	.go(black_drawer_b_done)
	);
	
	jump_datapath jump_datapath0(
	.clk(clk),
	.reset_n(reset_n),
	.ld_module(ld_signal),
	.black_drawer_b_plot(black_drawer_plot_b_out),
	.black_drawer_b_color(black_drawer_color_b_out),
	.black_drawer_b_y(black_drawer_y_position_b),
	.black_drawer_b_x(black_drawer_x_position_b),
	.black_drawer_a_plot(black_drawer_plot_a_out),
	.black_drawer_a_color(black_drawer_color_a_out),
	.black_drawer_a_y(black_drawer_y_position_a),
	.black_drawer_a_x(black_drawer_x_position_a),
	.square_drawer_plot(square_drawer_plot_out),
	.square_drawer_color(square_drawer_color_out),
	.square_drawer_x(square_drawer_x_position),
	.square_drawer_y(square_drawer_y_position),
	.x(x_out),
	.y(y_out),
	.color(color_out),
	.plot(plot_out),
	.go(sixty_signal)
	);
	
endmodule

module jump_datapath(
	clk,
	reset_n,
	ld_module,
	black_drawer_b_plot,
	black_drawer_b_color,
	black_drawer_b_y,
	black_drawer_b_x,
	black_drawer_a_plot,
	black_drawer_a_color,
	black_drawer_a_y,
	black_drawer_a_x,
	square_drawer_plot,
	square_drawer_color,
	square_drawer_x,
	square_drawer_y,
	x,
	y,
	color,
	plot,
	go
	);
	
	input ld_module, black_drawer_a_plot, square_drawer_plot, go, clk, reset_n;
	input black_drawer_b_plot;
	input [8:0] black_drawer_a_x, square_drawer_x, black_drawer_b_x;
	input [7:0] black_drawer_a_y, square_drawer_y, black_drawer_b_y;
	input [2:0] black_drawer_a_color, square_drawer_color, black_drawer_b_color;
	output reg plot;
	output reg [8:0] x;
	output reg [7:0] y;
	output reg [2:0] color;
	reg [1:0] track;
	
	always @(posedge clk) begin
		if (!reset_n || go)
			track <= 2'd0;
		
		else if (ld_module)
			track <= track + 1;
		
		if (track == 2'd0)begin
			x <= black_drawer_a_x;
			y <= black_drawer_a_y;
			plot <= black_drawer_a_plot;
			color <= black_drawer_a_color;
		end
		
		else if (track == 2'd1)begin
			x <= black_drawer_b_x;
			y <= black_drawer_b_y;
			plot <= black_drawer_b_plot;
			color <= black_drawer_b_color;
		end
		
		else if (track == 2'd2)begin
			x <= square_drawer_x;
			y <= square_drawer_y;
			plot <= square_drawer_plot;
			color <= square_drawer_color;
		end
			
	end
	
endmodule
