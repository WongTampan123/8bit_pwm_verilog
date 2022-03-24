//------------------------------------
// 8-bit PWM Core by Azhar
// Lang: Verilog HDL
//
// Desc:
// 8-bit PWM core dengan base freq ~= 1kHz
//-------------------------------------
module pwm_core(
	clk,
	duty_in,
	pwm_out, start	
);

input start;
input clk;
input [7:0] duty_in;
output pwm_out;

reg [8:0] duty_cycle=8'd250; //0-255
reg [6:0] duty_1;
reg [8:0] count=9'd0;
reg [8:0] count_pwm=9'd0;

reg clk_256kHz=1'd0;
reg state_256kHz=1'd0;
reg pwm_reg=1'd0;
reg state=1'd0;

parameter POSEDGE_256kHz = 1'd0;
parameter NEGEDGE_256kHz = 1'd1;

parameter POSEDGE = 1'd0;
parameter NEGEDGE = 1'd1;

//----Clock Devider 256kHz
always @(posedge clk) begin
	case(state_256kHz)
		POSEDGE_256kHz: begin
			if(count==8'd98) begin
				clk_256kHz<=1'd0;
				count<=count+1'd0;
				state_256kHz<=NEGEDGE_256kHz;
			end
			else begin
				count<=count+1'b1;
				clk_256kHz<=1'b1;
				state_256kHz<=POSEDGE_256kHz;
			end			
		end
		NEGEDGE_256kHz: begin
			if(count==8'd195) begin
				count<=8'd0;
				clk_256kHz<=1'b1;
				state_256kHz<=POSEDGE_256kHz;
			end
			else begin
				count<=count+1'b1;
				clk_256kHz<=1'b0;
				state_256kHz<=NEGEDGE_256kHz;
			end
		end
		default: ;
		endcase
end

//------ PWM base freq = 1kHz
always @(posedge clk_256kHz) begin
	case(state)
		POSEDGE: begin
			if(count_pwm==duty_cycle) begin 
				pwm_reg<=1'd0;
				count_pwm<=count_pwm+1'd0;
				state<=NEGEDGE;
			end
			else if (count_pwm>=duty_cycle) begin
				count_pwm<=1'b0;
				state<=POSEDGE;
			end
			else begin
				count_pwm<=count_pwm+1'b1;
				pwm_reg<=1'b1;
				state<=POSEDGE;
			end			
		end
		NEGEDGE: begin
			if(count_pwm==9'd257) begin
				pwm_reg=1'b1;
				count_pwm<=7'd0;
				state<=POSEDGE;
			end
			else begin
				count_pwm<=count_pwm+1'b1;
				pwm_reg<=1'b0;
				state<=NEGEDGE;
			end
		end
		default: ;
		endcase
end

assign pwm_out=pwm_reg;
		
endmodule 