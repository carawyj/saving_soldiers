

module draw_square(
clk, reset_n, AX, AY, BX, BY, mouth_sel, x, y, color, plot, done, go);
	input clk, reset_n, go;
	input [7:0] AY, BY;
	input [8:0] AX, BX;
	input [1:0] mouth_sel;
	
	output [2:0] color;
	output [15:0] x, y;
	output plot;
	output done;
	
	wire [11:0] count_in64;
	wire [7:0] count_in16;
	wire [5:0] count_in4;
	wire [6:0] count_in_sad;
	wire [6:0] count_in_wow;
	wire [6:0] count_in_happy1;
	wire [5:0] count_in_happy2;
	wire [4:0] count_in_happy3;
	
	wire [4:0] state;
	wire ld_x, ld_y;
	
	control c0(.clk(clk), .reset_n(reset_n),
	.go(go),
	.mouth_sel(mouth_sel),	
	.count_in64(count_in64),
	.count_in16(count_in16),
	.count_in4(count_in4),
	.count_in_sad(count_in_sad),
	.count_in_wow(count_in_wow),
	.count_in_happy1(count_in_happy1),
	.count_in_happy2(count_in_happy2),
	.count_in_happy3(count_in_happy3),
	.color(color),
	.state(state),
	.ld_x(ld_x), .ld_y(ld_y), .plot(plot), .done(done));
	
	draw_datapath d1(.AX(AX), .BX(BX),
	.AY(AY), .BY(BY),
	.clk(clk), .reset_n(reset_n),
	.count_in64(count_in64),
	.count_in16(count_in16),
	.count_in4(count_in4),
	.count_in_sad(count_in_sad),
	.count_in_wow(count_in_wow),
	.count_in_happy1(count_in_happy1),
	.count_in_happy2(count_in_happy2),
	.count_in_happy3(count_in_happy3),
	.state(state),
	.ld_x(ld_x),.ld_y(ld_y),
	.x(x),
	.y(y));
endmodule

module draw_datapath(
    input [15:0] AX, BX,
    input [15:0] AY, BY,
    
    input clk, reset_n,
    
    input [9:0] count_in64,
    input [5:0] count_in16,
    input [3:0] count_in4,
    input [4:0] count_in_sad,
    input [4:0] count_in_wow,
    input [4:0] count_in_happy1,
    input [3:0] count_in_happy2,
    input [2:0] count_in_happy3,
    input [4:0] state,
    input ld_x, ld_y,
    
    output reg [15:0] x,
    output reg [15:0] y
    );
    
    reg [15:0] ax, bx, ay, by;
    
    always@(*)
    begin
        case(state)
	// draw body of soldier a
        0: begin
            x <= ax + count_in64[4:0];
				y <= ay + count_in64[9:5];
            end
	//draw eye white of soldier a
	1: begin
	    x <= ax + count_in16[2:0] + 5'd22;
	    y <= ay + count_in16[5:3] + 3'd4;
	    end
	2: begin
	    x <= ax + count_in16[2:0] + 3'd4;
	    y <= ay + count_in16[5:3] + 3'd4;
	    end
	//draw eye black of soldier a
	3: begin
	    x <= ax + count_in4[1:0] + 6'd7;
	    y <= ay + count_in4[3:2] + 4'd5;
	    end
	4: begin
	    x <= ax + count_in4[1:0] + 6'd25;
	    y <= ay + count_in4[3:2] + 4'd5;
	    end
	//draw wow mouth of soldier a
	5: begin
	    x <= ax + count_in_wow[1:0] + 5'd14;
	    y <= ay + count_in_wow[4:2] + 7'd18;
	    end
	//draw sad mouth of soldier a
	6: begin
	    x <= ax + count_in_sad[4:1] + 6'd8;
	    y <= ay + count_in_sad[0] + 7'd22;
	    end
	//draw happy mouth of soldier a
	7: begin
	    x <= ax + count_in_happy1[4:1] + 6'd10;
	    y <= ay + count_in_happy1[0] + 6'd20;
	    end
	8: begin
	    x <= ax + count_in_happy2[3:1] + 6'd12;
	    y <= ay + count_in_happy2[0] + 6'd22;
	    end
	9: begin
	    x <= ax + count_in_happy3[2:1] + 6'd14;
	    y <= ay + count_in_happy3[0] + 6'd24;
	    end
	//draw body of soldier b
	10: begin
	    x <= bx + count_in64[4:0];
	    y <= by + count_in64[9:5];
            end
	//draw eye white of soldier b
	11: begin
	    x <= bx + count_in16[2:0] + 6'd22;
	    y <= by + count_in16[5:3] + 4'd4;
	    end
	12: begin
	    x <= bx + count_in16[2:0] + 6'd4;
	    y <= by + count_in16[5:3] + 4'd4;
	    end
	//draw eye black of soldier b
        13: begin
	    x <= bx + count_in4[1:0] + 6'd5;
	    y <= by + count_in4[3:2] + 5'd7;
	    end
	14: begin
	    x <= bx + count_in4[1:0] + 6'd23;
	    y <= by + count_in4[3:2] + 5'd7;
	    end
	//draw wow mouth of soldier b
	15: begin
	    x <= bx + count_in_wow[1:0] + 6'd14;
	    y <= by + count_in_wow[4:2] + 6'd18;
	    end
	//draw sad mouth of soldier b
	16: begin
	    x <= bx + count_in_sad[4:1] + 6'd8;
	    y <= by + count_in_sad[0] + 6'd22;
	    end
	//draw happy mouth of soldier b
	17: begin
	    x <= bx + count_in_happy1[4:1] + 6'd10;
	    y <= by + count_in_happy1[0] + 6'd20;
	    end
	18: begin
	    x <= bx + count_in_happy2[3:1] + 6'd12;
	    y <= by + count_in_happy2[0] + 6'd22;
	    end
	19: begin
	    x <= bx + count_in_happy3[2:1] + 6'd14;
	    y <= by + count_in_happy3[0] + 6'd24;
	    end
	endcase
    end
	   
    always@(posedge clk)
    begin
    if (!reset_n) begin
        ax <= 16'd0;
        ay <= 16'd0;
        bx <= 16'd0;
        by <= 16'd0;
    end
    else begin
    if (ld_x) begin
        ax <= AX;
        bx <= BX;
        end
    if (ld_y) begin
        ay <= AY;
        by <= BY;
        end
    end
    end
endmodule

module control(
    	input clk, reset_n,
	input go,
	input [1:0]mouth_sel,
	
	output [9:0] count_in64,
	output [5:0] count_in16,
	output [3:0] count_in4,
	output [4:0] count_in_sad,
	output [4:0] count_in_wow,
	output [4:0] count_in_happy1,
	output [3:0] count_in_happy2,
	output [2:0] count_in_happy3,
	output reg [2:0]color,

	output reg [4:0] state,
	output reg ld_x, ld_y, plot, done
	);
	
	reg [5:0] cur_s, nxt_s;
	
	wire stop64, stop16, stop4;
	wire stop_sm, stop_wm, stop_hm1, stop_hm2, stop_hm3;
	reg reseter64, reseter16, reseter4;
	reg reseter_sm, reseter_wm, reseter_hm1, reseter_hm2, reseter_hm3;
	
	counter32 c64(.reset_n(reseter64), .out(count_in64), .clk(clk), .stop(stop64));
	counter8 c16(.reset_n(reseter16), .out(count_in16), .clk(clk), .stop(stop16));
	counter2 c4(.reset_n(reseter4), .out(count_in4), .clk(clk), .stop(stop4));
	counter2_16 sm (.reset_n(reseter_sm), .out(count_in_sad), .clk(clk), .stop(stop_sm));
	counter6_4 wm (.reset_n(reseter_wm), .out(count_in_wow), .clk(clk), .stop(stop_wm));
	counter2_12 hm1 (.reset_n(reseter_hm1), .out(count_in_happy1), .clk(clk), .stop(stop_hm1));
	counter2_8 hm2 (.reset_n(reseter_hm2), .out(count_in_happy2), .clk(clk), .stop(stop_hm2));
	counter2_4 hm3 (.reset_n(reseter_hm3), .out(count_in_happy3), .clk(clk), .stop(stop_hm3));
	
	localparam WAIT               = 6'd26,
		   S_LOAD_XY          = 6'd0,
		   APLOTTING_64       = 6'd1,
		   APLOTTING_16_R     = 6'd2,
		   ATRANS_16          = 6'd3,
		   APLOTTING_16_L     = 6'd4,
		   APLOTTING_4_R      = 6'd5,
		   ATRANS_4           = 6'd6,
		   APLOTTING_4_L      = 6'd7,
		   APLOTTING_WOW_M    = 6'd8,
		   APLOTTING_SAD_M    = 6'd9,
		   APLOTTING_HAPPY_M1 = 6'd10,
		   APLOTTING_HAPPY_M2 = 6'd11,
		   APLOTTING_HAPPY_M3 = 6'd12,
		   BPLOTTING_64       = 6'd13,
		   BPLOTTING_16_R     = 6'd14,
		   BTRANS_16          = 6'd15,
		   BPLOTTING_16_L     = 6'd16,
		   BPLOTTING_4_R      = 6'd17,
		   BTRANS_4           = 6'd18,
		   BPLOTTING_4_L      = 6'd19,
		   BPLOTTING_WOW_M    = 6'd20,
		   BPLOTTING_SAD_M    = 6'd21,
		   BPLOTTING_HAPPY_M1 = 6'd22,
		   BPLOTTING_HAPPY_M2 = 6'd23,
		   BPLOTTING_HAPPY_M3 = 6'd24,
		   STOP_PLOTTING      = 6'd25;
		  	
		   
	always@(*)
	begin: state_table
		case (cur_s)
			WAIT : nxt_s = go? S_LOAD_XY : WAIT;
			S_LOAD_XY : nxt_s = APLOTTING_64;
			APLOTTING_64 : nxt_s = stop64? APLOTTING_16_R : APLOTTING_64;
			APLOTTING_16_R : nxt_s = stop16? ATRANS_16 : APLOTTING_16_R;
			ATRANS_16 : nxt_s = APLOTTING_16_L;
			APLOTTING_16_L : nxt_s = stop16? APLOTTING_4_R : APLOTTING_16_L;
			APLOTTING_4_R : nxt_s = stop4? ATRANS_4 : APLOTTING_4_R;
			ATRANS_4 : nxt_s = APLOTTING_4_L;
			APLOTTING_4_L : 
			begin
			if (stop4)
				begin 
					case(mouth_sel)
						0: nxt_s = BPLOTTING_64;
						1: nxt_s = APLOTTING_WOW_M;
						2: nxt_s = APLOTTING_SAD_M;
						3: nxt_s = APLOTTING_HAPPY_M1;
					endcase
				end
			else
				nxt_s = APLOTTING_4_L;
			end
			APLOTTING_WOW_M : nxt_s = stop_wm? BPLOTTING_64 : APLOTTING_WOW_M;
			APLOTTING_SAD_M : nxt_s = stop_sm? BPLOTTING_64 : APLOTTING_SAD_M;
			APLOTTING_HAPPY_M1: nxt_s = stop_hm1? APLOTTING_HAPPY_M2 : APLOTTING_HAPPY_M1;
			APLOTTING_HAPPY_M2: nxt_s = stop_hm2? APLOTTING_HAPPY_M3 : APLOTTING_HAPPY_M2;
			APLOTTING_HAPPY_M3: nxt_s = stop_hm3? BPLOTTING_64 : APLOTTING_HAPPY_M3;
			
			BPLOTTING_64 : nxt_s = stop64? BPLOTTING_16_R : BPLOTTING_64;
			BPLOTTING_16_R : nxt_s = stop16? BTRANS_16 : BPLOTTING_16_R;
			BTRANS_16 : nxt_s = BPLOTTING_16_L;
			BPLOTTING_16_L : nxt_s = stop16? BPLOTTING_4_R : BPLOTTING_16_L;
			BPLOTTING_4_R : nxt_s = stop4? BTRANS_4 : BPLOTTING_4_R;
			BTRANS_4 : nxt_s = BPLOTTING_4_L;
			BPLOTTING_4_L : 
			begin
			if (stop4)
				begin 
					case(mouth_sel)
						0: nxt_s = STOP_PLOTTING;
						1: nxt_s = BPLOTTING_WOW_M;
						2: nxt_s = BPLOTTING_SAD_M;
						3: nxt_s = BPLOTTING_HAPPY_M1;
					endcase
				end
			else
				nxt_s = BPLOTTING_4_L;
			end
			BPLOTTING_WOW_M : nxt_s = stop_wm? STOP_PLOTTING : BPLOTTING_WOW_M;
			BPLOTTING_SAD_M : nxt_s = stop_sm? STOP_PLOTTING : BPLOTTING_SAD_M;
			BPLOTTING_HAPPY_M1: nxt_s = stop_hm1? BPLOTTING_HAPPY_M2 : BPLOTTING_HAPPY_M1;
			BPLOTTING_HAPPY_M2: nxt_s = stop_hm2? BPLOTTING_HAPPY_M3 : BPLOTTING_HAPPY_M2;
			BPLOTTING_HAPPY_M3: nxt_s = stop_hm3? STOP_PLOTTING : BPLOTTING_HAPPY_M3;
			
			STOP_PLOTTING : nxt_s = WAIT;
			default: nxt_s = WAIT;
		endcase
	end
	
	always @(*)
	begin: signals
		plot = 0;
		ld_x = 0;
		ld_y = 0;
		done = 0;
		color = 3'b000;
		state = 4'd0;
		reseter64 =0;
		reseter16 =0;
		reseter4 =0;
		reseter_sm =0;
		reseter_wm =0;
		reseter_hm1 =0;
		reseter_hm2 =0;
		reseter_hm3 =0;
	case(cur_s)
		S_LOAD_XY: begin
			ld_x = 1;
			ld_y = 1;
		end
		
		APLOTTING_64 : begin
			state = 5'd0;
			reseter64 = 1;
			plot = 1;
			color = 3'b011;
		end
		
		APLOTTING_16_R : begin
			state = 5'd1;
			reseter16 = 1;
			plot = 1;
			color = 3'b111;
		end
		
		APLOTTING_16_L : begin
			state = 5'd2;
			reseter16 = 1;
			plot = 1;
			color = 3'b111;
		end
		
		APLOTTING_4_R : begin
			state = 5'd3;
			reseter4 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		APLOTTING_4_L : begin
			state = 5'd4;
			reseter4 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		APLOTTING_WOW_M : begin
			state = 5'd5;
			reseter_wm = 1;
			plot = 1;
			color = 3'b000;
		end
		
		APLOTTING_SAD_M : begin
			state = 5'd6;
			reseter_sm = 1;
			plot = 1;
			color = 3'b000;
		end
		
		APLOTTING_HAPPY_M1 : begin
			state = 5'd7;
			reseter_hm1 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		APLOTTING_HAPPY_M2 : begin
			state = 5'd8;
			reseter_hm2 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		APLOTTING_HAPPY_M3 : begin
			state = 5'd9;
			reseter_hm3 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		BPLOTTING_64 : begin
			state = 5'd10;
			reseter64 = 1;
			plot = 1;
			color = 3'b110;
		end
		
		BPLOTTING_16_R : begin
			state = 5'd11;
			reseter16 = 1;
			plot = 1;
			color = 3'b111;
		end
		
		BPLOTTING_16_L : begin
			state = 5'd12;
			reseter16 = 1;
			plot = 1;
			color = 3'b111;
		end
		
		BPLOTTING_4_R : begin
			state = 5'd13;
			reseter4 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		BPLOTTING_4_L : begin
			state = 5'd14;
			reseter4 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		BPLOTTING_WOW_M : begin
			state = 5'd15;
			reseter_wm = 1;
			plot = 1;
			color = 3'b000;
			done = 1;
		end
		
		BPLOTTING_SAD_M : begin
			state = 5'd16;
			reseter_sm = 1;
			plot = 1;
			color = 3'b000;
			done = 1;
		end
		
		BPLOTTING_HAPPY_M1 : begin
			state = 5'd17;
			reseter_hm1 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		BPLOTTING_HAPPY_M2 : begin
			state = 5'd18;
			reseter_hm2 = 1;
			plot = 1;
			color = 3'b000;
		end
		
		BPLOTTING_HAPPY_M3 : begin
			state = 5'd19;
			reseter_hm3 = 1;
			plot = 1;
			color = 3'b000;
			done = 1;
		end
		
	endcase
	end
	
	always@(posedge clk)
	begin: state_FFs
		if(!reset_n)
		cur_s <= S_LOAD_XY;
		else
		cur_s <= nxt_s;
	end // state_FFS
endmodule

module counter32(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [9:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 10'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 10'd1023)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule

module counter8(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [5:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 6'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 6'd63)
			stop <= 1;

		
		else
			out <= out +1;
	end

	end
endmodule

//actually a counter for 8*8
module counter2(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [3:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 4'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 4'd15)
			stop <= 1;

		else
			out <= out +1;
	end

	end
endmodule

//sad mouth
module counter2_16(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [4:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 5'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 5'd31)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule

//wow mouth
module counter6_4(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [4:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 5'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 5'b10111)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule

//happy mouth
module counter2_12(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [4:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 5'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 5'b10111)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule

module counter2_8(reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [3:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 4'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 4'd15)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule

module counter2_4 (reset_n, clk, out, stop);
	input reset_n, clk;
	output reg [2:0] out;
	output reg stop;

	
	always @(posedge clk)begin
	if (!reset_n)
		begin
		out <= 3'd0;
		stop <= 0;
		end
	else
	begin
		if (out == 3'd7)
			stop <= 1;			
		
		else
			out <= out +1;
	end

	end
endmodule 
