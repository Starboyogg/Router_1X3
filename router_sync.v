`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:51:57 01/21/2025 
// Design Name: 
// Module Name:    router_sync 
// Project Name: RTL Design & Verification of 1x3 Roter
// Target Devices: 
// Tool versions: 
// Description: 
// Protocol:Functionality:

/*This module provides synchronization between router 
FSM and router FIFO modules. It provides faithful 
communication between the single input port and three 
output ports.

? detect_add and data_in signals are used to select 
a FIFO till a packet routing is over for the selected FIFO

? Signal fifo_full signal is asserted based on 
full status of FIFO_0 or FIFO_1 or FIFO_2.

? If data in = 2'600 then fifo_full = full_0

? If data_in = 2'b01 then fifo_full = full_1

? If data_in = 2'b10 then fifo_full = full_2 else fifo_full = 0

? The signal vld_out_x signal is generated based on 
empty status of the FIFO as shown

below:

vld_out_0=-empty_0

o vld_out_1=~empty_1

o vld_out_2=-empty_2

? The write_enb_reg signal is used to generate write_enb signal 
for the write operation of the selected FIFO.

? There are 3 internal reset signals (soft_reset_0,soft_reset_1,soft_reset_2) 
for each of the FIFO respectively. The respective internal reset signals 
goes high if read enb X (read_enb_0, read_enb_1 or read_enb_2) is not asserted 
within 30 clock cycles of the vld_out_X (vld_out_0, vld_out_1 or vld_out_2) 
being asserted respectively.// Dependencies: 
//*/
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module router_sync (
    input wire clk,
    input wire resetn,
    input wire [1:0] data_in,
    input wire detect_add, //from FSM
    input wire full_0, //from FIFO 0
    input wire full_1, //from FIFO 1
    input wire full_2, //from FIFO 2
    input wire empty_0, //from FIFO 0
    input wire empty_1, //from FIFO 1
    input wire empty_2, //from FIFO 2
    input wire write_enb_reg, //from FSM
    input wire read_enb_0,
    input wire read_enb_1,
    input wire read_enb_2,
    output reg [2:0] write_enb,
    output reg fifo_full,
    output vld_out_0,
    output vld_out_1,
    output vld_out_2,
    output reg soft_reset_0,
    output reg soft_reset_1,
    output reg soft_reset_2
);
		//resetn = 1'b1;
    // Internal counters for soft reset logic
    reg [4:0] counter_0;
    reg [4:0] counter_1;
    reg [4:0] counter_2;
	 
	 reg [1:0]temp;
	 
	 //always @(posedge clk)
	 always @(*)
		begin
			if(~resetn)
				temp <= 2'b00;
			else if(detect_add)
				temp <= data_in;
		end

    // FIFO full logic
    always @*
		begin
			case (temp)
            2'b00: fifo_full = full_0;
            2'b01: fifo_full = full_1;
            2'b10: fifo_full = full_2;
            default: fifo_full = 1'b0;
			endcase
		end

    // Valid output logic
        assign vld_out_0 = ~empty_0;
        assign vld_out_1 = ~empty_1;
        assign vld_out_2 = ~empty_2;

    // Write enable logic
    always @(temp or write_enb_reg or  write_enb)
		begin
			if(write_enb_reg)
				begin
					case (temp)
					2'b00: write_enb <= 3'b001;
					2'b01: write_enb <= 3'b010;
					2'b10: write_enb <= 3'b100;
					2'b11: write_enb <= 3'b000;
					default: write_enb <= 3'b000;
					endcase
				end
			else
				write_enb <= 3'b000;
		end

    //Soft reset logic & Counter logic
	 always @(posedge clk or negedge resetn) 
		begin
			if(~resetn) 
				begin
					// Reset all counters and soft reset signals
					soft_reset_0 <= 1'b0;
					counter_0 <= 5'd0;
				end 
			else if(~read_enb_0)
				begin
					// Counter for FIFO 0
					if (vld_out_0)
						begin
							// Increment counters for valid FIFOs
							if(counter_0 < 30)
								begin
									counter_0 <= counter_0 + 1'b1;
									soft_reset_0 <= 1'b0;
								end
							else
								begin
									// Trigger soft reset if counters exceed 30
									counter_0 <= 5'd0;
									soft_reset_0 <= 1'b1;
								end
						end
					else
						begin
							counter_0 <= 5'b0;
							soft_reset_0 <= 1'b0;
						end
				end
			//To not hold the current data in counter_0
			else if(read_enb_0)
				begin
					counter_0 <= 5'd0;
					soft_reset_0 <= 1'b0;
				end
		end
	 //Soft reset logic & Counter logic
	 always @(posedge clk or negedge resetn) 
		begin
			if (~resetn) 
				begin
					// Reset all counters and soft reset signals
					soft_reset_1 <= 1'b0;
					counter_1 <= 5'd0;
				end 
			else if(~read_enb_1)
				begin
					// Counter for FIFO 0
					if (vld_out_1)
						begin
							// Increment counters for valid FIFOs
							if(counter_1 < 30)
								begin
									counter_1 <= counter_1 + 1'b1;
									soft_reset_1 <= 1'b0;
								end
							else
								begin
									// Trigger soft reset if counters exceed 30
									counter_1 <= 5'd0;
									soft_reset_1 <= 1'b1;
								end
						end
					else
						begin
							counter_1 <= 5'b0;
							soft_reset_1 <= 1'b0;
						end
				end
			//To not hold the current data in counter_1
			else if(read_enb_1)
				begin
					counter_1 <= 5'd0;
					soft_reset_1 <= 1'b0;
				end
		end
		// Soft reset logic & Counter logic
	 always @(posedge clk or negedge resetn) 
		begin
			if (~resetn) 
				begin
					// Reset all counters and soft reset signals
					soft_reset_2 <= 1'b0;
					counter_2 <= 5'd0;
				end 
			else if(~read_enb_2)
				begin
					// Counter for FIFO 0
					if (vld_out_2)
						begin
							// Increment counters for valid FIFOs
							if(counter_2 < 30)
								begin
									counter_2 <= counter_2 + 1'b1;
									soft_reset_2 <= 1'b0;
								end
							else
								begin
									// Trigger soft reset if counters exceed 30
									counter_2 <= 5'd0;
									//ThisIsTheChange
									soft_reset_2 <= 1'b1;
								end
						end
					else
						begin
							counter_2 <= 5'b0;
							soft_reset_2 <= 1'b0;
						end
				end
			//To not hold the current data in counter_2
			else if(read_enb_2)
				begin
					counter_2 <= 5'd0;
					soft_reset_2 <= 1'b0;
				end
		end		
endmodule
