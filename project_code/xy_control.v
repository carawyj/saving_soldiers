module xy_control(
	clk, 
	reset_n, 
	y_velocity_in, 
	x_velocity_in,
	go,
	y_out,
	x_out,
	load
	);
	
	input [4:0] y_velocity_in, x_velocity_in;
	input clk, reset_n, go, load;
	output [8:0] x_out;
	output [7:0] y_out;
	
	wire v_boundary;
	
	
	y_control y_control0(
	.velocity_in(y_velocity_in),
	.clk(clk), 
	.reset_n(reset_n), 
	.go(go), 
	.y_out(y_out), 
	.load(load), 
	.bdry(v_boundary)
	);
	
	x_control x_control0(
	.velocity_in(x_velocity_in), 
	.clk(clk), 
	.reset_n(reset_n), 
	.go(go), 
	.x_out(x_out), 
	.load(load), 
	.v_boundary(v_boundary)
	);
	
endmodule

//Y control unit
module y_control(velocity_in, clk, reset_n, go, y_out, load, bdry);
	input clk, reset_n, go, load;
	output [7:0] y_out;
	input [4:0] velocity_in;
	output bdry;
	
	wire boundary, max, up;
	wire [4:0] velocity;
	
	y_counter counter0(
	.velocity(velocity),
	.clk(clk),
	.reset_n(reset_n),
	.go(go),
	.up(up),
	.boundary(boundary), 
	.y_out(y_out), 
	.max(max)
	);
	
	y_velocity velocity0(
	.velocity_i(velocity_in), 
	.boundary(boundary), 
	.clk(clk), 
	.reset_n(reset_n), 
	.velocity_out(velocity), 
	.up(up), 
	.max(max), 
	.go(go), 
	.load(load)
	);
	
	assign bdry = boundary;
	
endmodule


module y_counter(velocity, clk, reset_n, go, up, boundary, y_out, max);
	input clk, reset_n, go, max;
	output reg up, boundary;
	input [4:0] velocity;
	output reg [7:0] y_out;
	
	wire [7:0] down_compare;
	assign down_compare = 8'd207 - {3'b000, velocity};
	
	
	always @(posedge clk) begin
	
		//reset
		if (!reset_n) begin
			up <= 1;
			y_out <= 8'd207;
			boundary <= 0;
		end
		
		//Frame starts drawing
		else if (go) begin
			//When going up
			if (up) begin
				//When y peaks
				if (max) begin
					up <= 0;
					boundary <= 0;
					y_out <= y_out;
				end
				
				//When bumps boundary
				else if (y_out <= velocity) begin
					up <= 0;
					boundary <= 1;
					y_out <= 8'd0;
				end
				
				//Normal up
				else begin
					up <= 1;
					boundary <= 0;
					y_out <= y_out - {3'b000, velocity};
				end
				
			end
			
			//When going down
			else begin
				//When bumps boundary
				if (y_out >= down_compare) begin
					up <= 1;
					boundary <= 1;
					y_out <= 8'd207;
				end
				
				//Normal fall
				else begin
					up <= 0;
					boundary <= 0;
					y_out <= y_out + {3'b000, velocity};
				end
				
			end
			
		end
		
	end
	
endmodule

module y_velocity(velocity_i, boundary, clk, reset_n, velocity_out, up, max, go, load);
	input [4:0] velocity_i;
	input clk, boundary, reset_n, up, go, load;
	output reg [4:0] velocity_out;
	output reg max;
	
	always @(posedge clk) begin
	//reset
	if (!reset_n) begin
		velocity_out <= 5'd0;
		max <= 0;
	end
	
	//Load initial velocity
	else if (load) begin
		if (velocity_i > 5'd30) begin
			velocity_out <= 5'd30;
			max <= 0;
		end
		else begin
			velocity_out <= velocity_i;
			max <= 0;
		end
	end
	
	//Actual change in velocity
	else if (go) begin
	
		//When velocity should be positive and decelerate by gravity
		if (up) begin
			//When bump into boundary
			if (boundary) begin
				max <= 0;
				velocity_out <= velocity_out >> 1;
			end
			
			//When reaches peak
			else if (velocity_out == 5'd0) begin
				max <= 1;
				velocity_out <= velocity_out;
			end
			
			//Normal decelerate
			else begin
				max <= 0;
				velocity_out <= velocity_out - 1;
			end
			
		end
		
		//When velocity should be negative
		else begin
			//When bump into boundary
			if (boundary) begin
				max <= 0;
				velocity_out <= velocity_out >> 1;
			end
			
			//Terminal velocity
			else if (velocity_out == 5'd30) begin
				velocity_out <= 5'd30;
				max <= 0;
			end
			
			//Normal acceleration
			else begin
				velocity_out <= velocity_out + 1;
				max <= 0;
			end
		end
	end
	
	end	
	
endmodule

//x control unit
module x_control(velocity_in, clk, reset_n, go, x_out, load, v_boundary);
	input clk, reset_n, go, load, v_boundary;
	output [8:0] x_out;
	input [4:0] velocity_in;
	
	wire [4:0] velocity;
	wire boundary, all_boundary;
	
	assign all_boundary = boundary || v_boundary;
	
	x_counter counter0(
	.velocity(velocity), 
	.clk(clk), 
	.reset_n(reset_n), 
	.go(go), 
	.boundary(boundary), 
	.x_out(x_out)
	);
	
	x_velocity velocity0(
	.velocity_i(velocity_in), 
	.boundary(all_boundary), 
	.clk(clk), 
	.reset_n(reset_n), 
	.velocity_out(velocity), 
	.go(go), 
	.load(load)
	);
	
endmodule

module x_counter(velocity, clk, reset_n, go, boundary, x_out);
	input clk, reset_n, go;
	input [4:0] velocity;
	output reg [8:0] x_out;
	output reg boundary;
	
	reg right;
	
	wire [8:0] right_compare;
	assign right_compare = 9'd287 - {4'd0000, velocity};
	
	always @(posedge clk) begin
	
		//reset
		if (!reset_n) begin
			right <= 1;
			boundary <= 0;
			x_out <= 9'd0;
		end
		
		else if (go) begin
			//When going right
			if (right) begin
				//When bumps to boundary
				if (x_out >= right_compare) begin
					right <= 0;
					boundary <= 1;
					x_out <= 9'd287;
				end
				
				else begin
					right <= 1;
					boundary <= 0;
					x_out <= x_out + {4'd0000, velocity};
				end
			end
			
			//When going left
			else begin
				//When bumps to boundary
				if (x_out <= velocity) begin
					right <= 1;
					boundary <= 1;
					x_out <= 9'd0;
				end
				
				else begin
					right <= 0;
					boundary <= 0;
					x_out <= x_out - {4'd0000, velocity};
				end
			end
			
		end
	
	end
	
endmodule

module x_velocity(velocity_i, boundary, clk, reset_n, velocity_out, go, load);
	input [4:0] velocity_i;
	input clk, reset_n, boundary, go, load;
	output reg [4:0] velocity_out;
	
	always @(posedge clk) begin
	//reset
	if (!reset_n) begin
		velocity_out <= 5'd0;
	end
	
	//Load initial velocity
	else if (load) begin
		//When input is larger than terminal V
		if (velocity_i > 5'd30) begin
			velocity_out <= 5'd30;
		end
		
		else begin
			velocity_out <= velocity_i;
		end
	end
	
	//Actual change in velocity
	else if (go) begin
		if (boundary) begin
			velocity_out <= velocity_out >> 1;
		end
		
		else begin
			velocity_out <= velocity_out;
		end
	end
	
	end
	
endmodule