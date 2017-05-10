module final(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,
		SW,
		HEX0,
		HEX1,
		HEX4,
		HEX5,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	
	);
	
	input	CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output  [6:0]   HEX0, HEX1, HEX4, HEX5;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [15:0] x;
	wire [15:0] y;
	wire plot;
	
	wire sixty_a, sixty_b, blkscreen_go;
	wire [2:0] game_dp_sel;
	wire [8:0] x_position_a, x_position_b;
	wire [7:0] y_position_a, y_position_b;
	wire [4:0] life, level;
	wire collision_finish, collision_win;
	
	wire game_over, game_won;
	wire saved_finish, death_finish, black_screen_finish;
	wire win_game_finish, game_over_finish;
	wire [8:0] start_x, jump_x, saved_x, death_x, game_over_x, win_game_x, black_screen_x;
	wire [7:0] start_y, jump_y, saved_y, death_y, game_over_y, win_game_y, black_screen_y;
	wire [2:0] start_color, jump_color, saved_color, death_color, game_over_color, win_game_color, black_screen_color;
	wire start_plot, jump_plot, saved_plot, death_plot, game_over_plot, win_game_plot, black_screen_plot;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(plot),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
	
	sixtyFPS_divider sxity0(
	.go(~KEY[1]), 
	.clk(CLOCK_50), 
	.reset_n(resetn), 
	.out_a(sixty_a), 
	.out_b(sixty_b)
	);
	
	// xy_control_a
	xy_control xy_control0(
	.clk(CLOCK_50), 
	.reset_n(resetn), 
	.y_velocity_in(SW[9:5]), 
	.x_velocity_in(SW[4:0]),
	.go(sixty_b),
	.y_out(y_position_a),
	.x_out(x_position_a),
	.load(~KEY[1])
	);
	
	collision collision0(
	.AX(x_position_a), 
	.AY(y_position_a), 
	.BX(x_position_b), 
	.BY(x_position_b), 
	.sixty(sixty_b),
	.go(~KEY[1]), 
	.reset_n(reset_n), 
	.ld_x(1), 
	.ld_y(1), 
	.clk(CLOCK_50), 
	.finish(collision_finish), 
	.win(collision_win)
	);
	
	// xy_control_b
	xy_control_b xy_control_b0(
	.x_out(x_position_b),
	.y_out(y_position_b),
	.reset_n(resetn),
	.clk(CLOCK_50),
	.go(sixty_b),
	.speed(level)
	);
	
	// fsm
	game_control_fsm fsm0(
	.reset_n(resetn),
	.clk(CLOCK_50),
	.shoot(~KEY[1]),
	.win(collision_win),
	.finish(collision_finish),
	.level(level),
	.life(life),
	.game_over(game_over),
	.game_won(game_won),
	.game_dp_sel(game_dp_sel),
	.saved_finish(saved_finish), 
	.death_finish(death_finish), 
	.black_screen_finish(black_screen_finish),
	.win_game_finish(win_game_finish), 
	.game_over_finish(game_over_finish),
	.blkscreen_go(blkscreen_go)
	);
	
	game_control_datapth dp0(
		.start_x(start_x),
		.start_y(start_y),
		.start_color(start_color),
		.start_plot(start_plot),
		.jump_x(jump_x),
		.jump_y(jump_y),
		.jump_color(jump_color),
		.jump_plot(jump_plot),
		.saved_x(saved_x),
		.saved_y(saved_y),
		.saved_color(saved_color),
		.saved_plot(saved_color),
		.death_x(death_x),
		.death_y(death_y),
		.death_color(death_color),
		.death_plot(death_plot),
		.game_over_x(game_over_x),
		.game_over_y(game_over_y),
		.game_over_color(game_over_color),
		.game_over_plot(game_over_plot),
		.win_game_x(win_game_x),
		.win_game_y(win_game_y),
		.win_game_color(win_game_color),
		.win_game_plot(win_game_plot),
		.black_screen_x(black_screen_x),
		.black_screen_y(black_screen_y),
		.black_screen_color(black_screen_color),
		.black_screen_plot(black_screen_plot),
		.x_out(x),
		.y_out(y),
		.plot_out(plot),
		.color_out(colour),
		.clk(CLOCK_50),
		.reset_n(resetn),
		.mux_select(game_dp_sel)
	);
	
	game_tracker game_tracker0(
	.clk(CLOCK_50),
	.reset_n(resetn),
	.life(life),
	.level(level),
	.finish(collision_finish),
	.win(collision_win),
	.game_over(game_over),
	.game_won(game_won)
	);
	
	// start module
	start start0(
	.x_position_b(x_position_b),
	.y_position_b(y_position_b),
	.x_position_a(x_position_a),
	.y_position_a(y_position_a),
	.sixty_signal(sixty_b),
	.clk(CLOCK_50),
	.reset_n(resetn),
	.x_out(start_x),
	.y_out(start_y),
	.color_out(start_color),
	.plot_out(start_plot),
	);
	
	jump jump0(
	.x_position_b(x_position_b),
	.y_position_b(y_position_b),
	.x_position_a(x_position_a),
	.y_position_a(y_position_a),
	.sixty_signal(sixty_b),
	.clk(CLOCK_50),
	.reset_n(resetn),
	.x_out(jump_x),
	.y_out(jump_y),
	.color_out(jump_color),
	.plot_out(jump_plot),
	);
	
	saved saved0(
	.x_position_b(x_position_b),
	.y_position_b(y_position_b),
	.x_position_a(x_position_a),
	.y_position_a(y_position_a),
	.start(collision_finish),
	.clk(CLOCK_50),
	.reset_n(resetn),
	.x_out(saved_x),
	.y_out(saved_y),
	.color_out(saved_color),
	.plot_out(saved_plot),
	.done(saved_finish),
	.sixty_signal(sixty_b)
	);
	
	death death0(
	.x_position_b(x_position_b),
	.y_position_b(y_position_b),
	.x_position_a(x_position_a),
	.y_position_a(y_position_a),
	.start(collision_finish),
	.clk(CLOCK_50),
	.reset_n(resetn),
	.x_out(death_x),
	.y_out(death_y),
	.color_out(death_color),
	.plot_out(death_plot),
	.done(death_finish),
	.sixty_signal(sixty_b)
	);
	
	blk_screen black_screen0(
	.clk(CLOCK_50), 
	.reset_n(resetn), 
	.x(black_screen_x), 
	.y(black_screen_y), 
	.go(blkscreen_go), 
	.color(black_screen_color), 
	.plot(black_screen_plot), 
	.done(black_screen_finish)
	);
	
	win_game w0(
	.clk(CLOCK_50), 
	.reset_n(resetn), 
	.go(saved_finish), 
	.x_out(win_game_x), 
	.y_out(win_game_y), 
	.color_out(win_game_color), 
	.plot_out(win_game_plot), 
	.sixty_signal(sixty_b), 
	.done(win_game_finish)
	);
	
	game_over game_over0(
	.clk(CLOCK_50), 
	.reset_n(resetn), 
	.go(death_finish), 
	.x_out(game_over_x), 
	.y_out(game_over_y), 
	.color_out(game_over_color), 
	.plot_out(game_over_plot), 
	.sixty_signal(sixty_b), 
	.done(game_over_finish)
	);
	
endmodule

module game_control_fsm(
	reset_n,
	clk,
	shoot,
	win,
	finish,
	level,
	life,
	game_over,
	game_won,
	game_dp_sel,
	saved_finish, 
	death_finish, 
	black_screen_finish,
	win_game_finish, 
	game_over_finish,
	blkscreen_go
	);
	
	input reset_n, clk, shoot, win, finish, game_over, game_won;
	input [3:0] level, life;
	input saved_finish, death_finish, black_screen_finish;
	input win_game_finish, game_over_finish;
	output reg [2:0] game_dp_sel;
	output reg blkscreen_go;
	reg [2:0] cur_state, nxt_state;
	
	localparam
	WAIT = 3'd0,
	START = 3'd1,
	JUMP = 3'd2,
	SAVED = 3'd3,
	DEATH = 3'd4,
	BLACK_SCREEN = 3'd5,
	WIN_GAME = 3'd6,
	GAME_OVER = 3'd7;
	
	always @(*) 
	begin: state_table
		case (cur_state)
			WAIT : nxt_state = START;
			START: nxt_state = shoot ? JUMP : START;
			JUMP: begin
					if (finish) begin
						if (win) begin
							nxt_state = SAVED;
						end
						
						else begin
							nxt_state = DEATH;
						end
					end
					
					else begin
						nxt_state = JUMP;
					end
				end
			SAVED: begin
					if (saved_finish) begin
						if (game_won) begin
							nxt_state = WIN_GAME;
						end
						else begin
							nxt_state = BLACK_SCREEN;
						end
					end
					
					else begin
						nxt_state = SAVED;
					end
					end
			DEATH: begin
					if (death_finish) begin
						if (game_over) begin
							nxt_state = GAME_OVER;
						end
						else begin
							nxt_state = BLACK_SCREEN;
						end
					end
					
					else begin
						nxt_state = DEATH;
					end
					end
			BLACK_SCREEN: begin
							if (black_screen_finish) 
								nxt_state = START;
							end
			
			WIN_GAME: begin
						if (win_game_finish)
							nxt_state = BLACK_SCREEN;
						end
			GAME_OVER: begin
						if (game_over_finish)
							nxt_state = BLACK_SCREEN;
						end
			default: nxt_state = WAIT;
		endcase
	end
	
	always @(clk) 
	begin: signals
		game_dp_sel = 3'd0;
		blkscreen_go = 0;
		case (cur_state)
			JUMP: game_dp_sel = 3'd1;
			SAVED: game_dp_sel = 3'd2;
			DEATH: game_dp_sel = 3'd3;
			BLACK_SCREEN: begin
			game_dp_sel = 3'd4;
			blkscreen_go = 1;
			end
			GAME_OVER: game_dp_sel = 3'd6;
			WIN_GAME: game_dp_sel = 3'd5;
	endcase
	end
	
	always@(posedge clk)
	begin: state_FFs
		if(!reset_n)
		cur_state <=WAIT;
		else
		cur_state <= nxt_state;
	end // state_FFS
	
endmodule

module game_control_datapth(
		start_x,
		start_y,
		start_color,
		start_plot,
		jump_x,
		jump_y,
		jump_color,
		jump_plot,
		saved_x,
		saved_y,
		saved_color,
		saved_plot,
		death_x,
		death_y,
		death_color,
		death_plot,
		game_over_x,
		game_over_y,
		game_over_color,
		game_over_plot,
		win_game_x,
		win_game_y,
		win_game_color,
		win_game_plot,
		black_screen_x,
		black_screen_y,
		black_screen_color,
		black_screen_plot,
		x_out,
		y_out,
		plot_out,
		color_out,
		clk,
		reset_n,
		mux_select
	);
	
	input [8:0] start_x, jump_x, saved_x, death_x, game_over_x, win_game_x, black_screen_x;
	input [7:0] start_y, jump_y, saved_y, death_y, game_over_y, win_game_y, black_screen_y;
	input [2:0] start_color, jump_color, saved_color, death_color, game_over_color, win_game_color, black_screen_color;
	input start_plot, jump_plot, saved_plot, death_plot, game_over_plot, win_game_plot, black_screen_plot;
	output reg [8:0] x_out;
	output reg [7:0] y_out;
	output reg [2:0] color_out;
	output reg plot_out;
	input [2:0] mux_select;
	input reset_n, clk;
	
	always @(posedge clk) begin
		
		if (!reset_n) begin
			x_out <= start_x;
			y_out <= start_y;
			color_out <= start_color;
			plot_out <= start_plot;
		end
		
		else begin
			case (mux_select)
			// Starting state
			0: begin
				x_out = start_x;
				y_out = start_y;
				color_out = start_color;
				plot_out = start_plot;
				end
			// Jumping state
			1: begin
				x_out = jump_x;
				y_out = jump_y;
				color_out = jump_color;
				plot_out = jump_plot;
				end
			// Saved state
			2: begin
				x_out = saved_x;
				y_out = saved_y;
				color_out = saved_color;
				plot_out = saved_plot;
				end
			// Death state
			3: begin
				x_out = death_x;
				y_out = death_y;
				color_out = death_color;
				plot_out = death_plot;
				end
			// Black_screen state
			4: begin
				x_out = black_screen_x;
				y_out = black_screen_y;
				color_out = black_screen_color;
				plot_out = black_screen_plot;
				end
			// Win_game state
			5: begin
				x_out = win_game_x;
				y_out = win_game_y;
				color_out = win_game_color;
				plot_out = win_game_plot;
				end
			// game_over state
			6: begin
				x_out = game_over_x;
				y_out = game_over_y;
				color_out = game_over_color;
				plot_out = game_over_plot;
				end
			endcase
		end
	end
	
endmodule