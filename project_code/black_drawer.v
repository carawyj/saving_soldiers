module black_drawer(go, clk, reset_n, done, plot, y_in, x_in, x_out, y_out, color_out);
	input go, clk, reset_n;
	input [8:0] x_in;
	input [7:0] y_in;
	output done, plot;
	output [8:0] x_out;
	output [7:0] y_out;
	output [2:0] color_out;
	
	wire [9:0] count_in;
	wire ld_x, ld_y, ld_prevx, ld_prevy;
	
	black_drawer_fsm(
	.go(go), 
	.clk(clk), 
	.reset_n(reset_n), 
	.plot(plot), 
	.ld_x(ld_x), 
	.ld_y(ld_y), 
	.count_in(count_in), 
	.done(done),
	.ld_prevx(ld_prevx),
	.ld_prevy(ld_prevy)
	);
	
	black_drawer_datapath(
	.y_in(y_in), 
	.x_in(x_in), 
	.clk(clk), 
	.reset_n(reset_n), 
	.ld_x(ld_x), 
	.ld_y(ld_y),  
	.count_in(count_in), 
	.x_out(x_out), 
	.y_out(y_out), 
	.color_out(color_out),
	.ld_prevx(ld_prevx),
	.ld_prevy(ld_prevy)
	);
	
endmodule

module black_drawer_fsm(go, clk, reset_n, plot, ld_x, ld_y, count_in, done, ld_prevx, ld_prevy);
	input go, clk, reset_n;
	output reg ld_x, ld_y, done, plot, ld_prevx, ld_prevy;
	output [9:0] count_in;
	reg [1:0] cur_state, nxt_state;
	wire stop;
	reg counter_reseter;
	
	black_counter counter0(
	.reset_n(counter_reseter), 
	.out(count_in), 
	.clk(clk), 
	.max(stop)
	);
	
	localparam S_LOAD_XY      = 2'd0,
		   S_LOAD_XY_WAIT     = 2'd1,
		   PLOTTING           = 2'd2,
           STOP_PLOTTING      = 2'd3;
	
	always @(*)
	begin: state_table
		case (cur_state)
			S_LOAD_XY: nxt_state = go ? S_LOAD_XY_WAIT : S_LOAD_XY;
			S_LOAD_XY_WAIT: nxt_state = PLOTTING;
			PLOTTING: nxt_state = stop ? STOP_PLOTTING : PLOTTING;
			STOP_PLOTTING: nxt_state = S_LOAD_XY;
			default: nxt_state = S_LOAD_XY;
		endcase
	end
	
	always @(*)
	begin: signals
		plot = 0;
		ld_x = 0;
		ld_y = 0;
		ld_prevx = 0;
		ld_prevy = 0;
		counter_reseter = 0;
		done = 0;
	case (cur_state)
		S_LOAD_XY: begin
			ld_x = 1;
			ld_y = 1;
		end
		PLOTTING: begin
			counter_reseter = 1;
			plot = 1;
		end
		STOP_PLOTTING: begin 
			done = 1;
			ld_prevx = 1;
			ld_prevy = 1;
		end
	endcase
	end
	
	always @(posedge clk)
	begin: state_FFs
		if (!reset_n)
			cur_state <= S_LOAD_XY;
		else
			cur_state <= nxt_state;
	end
	
endmodule

module black_drawer_datapath (y_in, x_in, clk, reset_n, ld_x, ld_y, count_in, x_out, y_out, color_out, ld_prevx, ld_prevy);
	input reset_n, ld_x, ld_y, clk, ld_prevx, ld_prevy;
	input [8:0] x_in;
	input [7:0] y_in;
	input [9:0] count_in;
	output [2:0] color_out;
	output [8:0] x_out;
	output [7:0] y_out;
	
	reg [8:0] cur_x, prev_x;
	reg [7:0] cur_y, prev_y;
	
	assign color_out = 3'b000;
	
	x_adder add_x(.A(prev_x), .B(count_in[4:0]), .out(x_out));
	y_adder add_y(.A(prev_y), .B(count_in[9:5]), .out(y_out));
	
	always @(posedge clk) begin
		//Reset
		if (!reset_n) begin
			cur_x <= 9'd0;
			prev_x <= 9'd0;
			cur_y <= 8'd207;
			prev_y <= 8'd207;
		end
		
		else begin
			if (ld_x)
				cur_x <= x_in;
			if (ld_y)
				cur_y <= y_in;
			if (ld_prevx)
				prev_x <= cur_x;
			if (ld_prevy)
				prev_y <= cur_y;
		end
	end
	
endmodule

module x_adder(A, B, out);
	input [8:0] A;
	input [4:0] B;
	output [8:0] out;
	
	assign out = A + B;
	
endmodule

module y_adder(A, B, out);
	input [7:0] A;
	input [4:0] B;
	output [7:0] out;
	
	assign out = A + B;
	
endmodule

module black_counter(reset_n, out, clk, max);
	input reset_n, clk;
	output reg [9:0] out;
	output reg max;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 10'd0;
		max <= 0;
		end
	else
	begin
		if (out == 10'd1023)
			max <= 1;			
		
		else
			out <= out + 1;
	end

	end
endmodule