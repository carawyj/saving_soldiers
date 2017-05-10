module win_game(clk, reset_n, go, x_out, y_out, color_out, plot_out, done, sixty_signal, done);
	input clk, reset_n, go, sixty_signal;
	output [8:0] x_out;
	output [7:0] y_out;
	output [2:0] color_out;
	output plot_out, done;
	
	wire [8:0] black_drawer_x_position, square_drawer_x_position;
	wire [7:0] black_drawer_y_position, square_drawer_y_position;
	wire black_drawer_done, square_drawer_done;
	wire [2:0] black_drawer_color_out, square_drawer_color_out;
	wire black_drawer_plot_out, square_drawer_plot_out;
	
	blk_screen b0(.clk(clk), 
	.reset_n(reset_n), 
	.x(black_drawer_x_position), 
	.y(black_drawer_y_position), 
	.go(go), 
	.color(black_drawer_color_out), 
	.plot(black_drawer_plot_out), 
	.done(black_drawer_done));
	
	// draw sqaure unit
	draw_square square_drawer0(
	.clk(clk), 
	.reset_n(reset_n), 
	.AX(9'd100), 
	.AY(8'd100), 
	.BX(9'd200), 
	.BY(8'd100), 
	.mouth_sel(2'd3), 
	.x(square_drawer_x_position), 
	.y(square_drawer_y_position), 
	.color(square_drawer_color_out), 
	.plot(square_drawer_plot_out), 
	.done(square_drawer_done), 
	.go(black_drawer_done)
	);
	
	game_over_datapath win_game_dp0(
	.clk(clk),
	.reset_n(resetn),
	.ld_module(black_drawer_done),
	.black_drawer_plot(black_drawer_plot_out),
	.black_drawer_color(black_drawer_color_out),
	.black_drawer_y(black_drawer_y_position),
	.black_drawer_x(black_drawer_x_position),
	.square_drawer_plot(square_drawer_plot_out),
	.square_drawer_color(square_drawer_color_out),
	.square_drawer_x(square_drawer_x_position),
	.square_drawer_y(square_drawer_y_position),
	.x(x_out),
	.y(y_out),
	.color(color_out),
	.plot(plot_out),
	);
	
	thirty_counter thirty_counter0(
	.clk(sixty_signal), .reset_n(reset_n), .stop(go), .done(done)
	);
endmodule
