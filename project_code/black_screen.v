module blk_screen(clk, reset_n, x, y, go, color, plot, done);
	input clk, reset_n, go;
	output [8:0] x;
	output [7:0] y;
	output plot, done;
	output [2:0] color;
	
	wire [8:0]c_x;
	wire [7:0] c_y;
	
	assign color = 3'b0;
	
	blk_screen_control c0 (.clk(clk), 
		.reset_n(reset_n), 
		.go(go), 
		.c_x(c_x),
		.c_y(c_y), 
		.plot(plot),
		.done(done)
		);
		
	blk_screen_datapath d0 (.c_x(c_x),
		.c_y(c_y),
		.X(x),
		.Y(y));
endmodule


module blk_screen_control(
	input clk, reset_n, go,	
	output [8:0] c_x,
	output [7:0] c_y,
	output reg plot,
	output reg done
	);
	
	wire stop;
	reg reseter;
	reg [1:0] cur_s, nxt_s;
	
	blk_screen_counter cb(.reset_n(reseter), .c_x(c_x), .c_y(c_y), .clk(clk), .stop(stop));
	
	localparam WAIT = 2'd0,
		   PLOTTING = 2'd1,
		   STOP_PLOTTING = 2'd3;
	always@(*)
	begin: state_table
		case (cur_s)
			WAIT : nxt_s = go? PLOTTING : WAIT;
			PLOTTING : nxt_s = stop?  STOP_PLOTTING : PLOTTING;
			STOP_PLOTTING : nxt_s = WAIT;
			default: nxt_s = WAIT;
		endcase
	end

	always @(*)
	begin: signals
		plot = 0;
		reseter = 0;
		case(cur_s)
		PLOTTING:begin
			reseter = 1;
			plot = 1;
			end
		STOP_PLOTTING: begin
			done = 1;
			end
		endcase
	end
	
	always@(posedge clk)
	begin: state_FFs
		if(!reset_n)
		cur_s <= WAIT;
		else
		cur_s <= nxt_s;
	end // state_FFS
endmodule

module blk_screen_datapath(
	input [8:0] c_x,
	input [7:0] c_y,
    
	output reg [8:0] X,
	output reg [7:0] Y
	);
	
	reg [8:0] x = 9'd0;
	reg [7:0] y = 8'd0;
	
	always@(*)
	begin
		X <= x + c_x;
		Y <= y + c_y;
	end
endmodule

module blk_screen_counter(clk,reset_n,c_x,c_y,stop);
	input clk;
	input reset_n;
	output [8:0] c_x;
	output [7:0] c_y;
	output reg stop;

	reg [8:0] x;
	reg [7:0] y;

	    always @(posedge clk)
		begin
			if (reset_n == 1'b0)
				begin
					x <= 0;
					y <= 0;
					stop <= 0; 
				end
			else if (x == 9'd319 & y == 8'd239)
				stop <= 1;
			else if (x == 9'd319)
				begin
					x <= 0;
					y <= y + 1;
				end
			else
				x <= x + 1;
		end

	   assign c_x = x;
	   assign c_y = y;
endmodule