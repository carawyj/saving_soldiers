module grave_top(clk, reset_n, x, y, go, color, plot, done);
	input clk, reset_n, go;
	output [9:0] x, y;
	output plot, done;
	output [2:0] color;
	
	wire [10:0]count_grave;
	wire [6:0] count_h, count_v;
	wire [1:0] state;
	
	gravecontrol c0 (.clk(clk), 
		.reset_n(reset_n), 
		.go(go), 
		.count_grave(count_grave), 
		.count_h(count_h), 
		.count_v(count_v),
		.color(color),
		.state(state),
		.plot(plot),
		.done(done)
		);
		
	datapathgrave d0 (.count_grave(count_grave),
		.count_h(count_h),
		.count_v(count_v),
		.state(state),
		.X(x),
		.Y(y));
endmodule

module gravecontrol(
    	input clk, reset_n, go,
	
	output [10:0] count_grave,
	output [6:0] count_v,
	output [6:0] count_h,
	output reg [2:0]color,

	output reg [1:0] state,
	output reg plot, done
	);
	
	wire stopg, stoph, stopv;
	reg reseterg, reseterh, reseterv;
	reg [2:0] cur_s, nxt_s;
	
	counter3264 cg(.reset_n(reseterg), .out(count_grave), .clk(clk), .stop(stopg));
	counter244 ch(.reset_n(reseterh), .out(count_h), .clk(clk), .stop(stoph));
	counter432 cv(.reset_n(reseterv), .out(count_v), .clk(clk), .stop(stopv));
	
	localparam WAIT = 3'd0,
		   PLOTTING_GRAVE = 3'd1,
		   PLOTTING_H = 3'd2,
		   PLOTTING_V = 3'd3,
		   STOP_PLOTTING = 3'd4;
	
	always@(*)
	begin: state_table
		case (cur_s)
			WAIT : nxt_s = go? PLOTTING_GRAVE : WAIT;
			PLOTTING_GRAVE : nxt_s = stopg? PLOTTING_H : PLOTTING_GRAVE;
			PLOTTING_H : nxt_s = stoph? PLOTTING_V : PLOTTING_H;
			PLOTTING_V : nxt_s = stopv?  STOP_PLOTTING : PLOTTING_V;
			STOP_PLOTTING : nxt_s = WAIT;
			default: nxt_s = WAIT;
		endcase
	end
	
	always @(*)
	begin: signals
		plot = 0;
		reseterg = 0;
		reseterh = 0;
		reseterv = 0;
	case(cur_s)
		PLOTTING_GRAVE : begin
			state = 2'd0;
			reseterg = 1;
			plot = 1;
			color = 3'b111;
		end
		
		PLOTTING_H : begin
			state = 2'd1;
			reseterh = 1;
			plot = 1;
			color = 3'b000;
		end
		
		PLOTTING_V : begin
			state = 2'd2;
			reseterv = 1;
			plot = 1;
			color = 3'b000;
		end
		
		STOP_PLOTTING: 
			done = 1;
	endcase
	end
	
	always@(posedge clk)
	begin: state_FFs
		if(!reset_n)
		cur_s <=WAIT;
		else
		cur_s <= nxt_s;
	end // state_FFS
endmodule

module datapathgrave(
	input [10:0] count_grave,
	input [6:0] count_h,
	input [6:0] count_v,
	input [1:0] state,
    
	output reg [9:0] X,
	output reg [9:0] Y
	);
	
	reg [9:0] x = 9'd50;
	reg [9:0] y = 9'd50;
	always@(*)
	begin
        case(state)
		0: begin
			X <= x + count_grave[4:0];
			Y <= y + count_grave[10:5];
		end
		
		1: begin
			X <= x + 5'd24 + count_h[6:2];
			Y <= y + 5'd8 + count_h[1:0];
		end
		
		2: begin
			X <= x + 5'd4 + count_v[1:0];
			Y <= y + 5'd32 + count_v[6:2];
		end
	endcase
	end	
endmodule
	
	
	
module counter3264(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [10:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 11'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 11'd2047)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule

module counter432(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [6:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 7'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 7'd127)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule

module counter244(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [6:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 7'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 7'b1111000)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule