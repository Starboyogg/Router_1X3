`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:08:15 04/07/2025 
// Design Name: 
// Module Name:    router_reg_tb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module router_reg_tb; 
	reg clock, resetn, pkt_valid, fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg;
	reg [7:0]data_in;
	wire err, parity_done, low_pkt_valid;
	wire [7:0]dout;
	router_reg uut(.clock(clock), 
						.resetn(resetn), 
						.pkt_valid(pkt_valid), 
						.fifo_full(fifo_full), 
						.detect_add(detect_add),
						.ld_state(ld_state), 
						.laf_state(laf_state), 
						.full_state(full_state), 
						.lfd_state(lfd_state), 
						.rst_int_reg(rst_int_reg), 
						.data_in(data_in), 
						.err(err), 
						.parity_done(parity_done), 
						.low_pkt_valid(low_pkt_valid),
						.dout(dout)
	);
	//generate clock
	initial begin
		clock = 1'b0;
		resetn = 1'b1;
		pkt_valid = 1'b0;
		fifo_full = 1'b0;
		detect_add = 1'b0;
		ld_state = 1'b0;
		laf_state = 1'b0;
		full_state = 1'b0;
		lfd_state = 1'b0;
		rst_int_reg = 1'b0;
		data_in = 8'b0;
		#100;
		forever #5 clock = ~clock;
	end
	//stimulus 
	initial begin
		#100;
		rstn;
		//parity_done_high(1'b0);
		//low_pkt_valid_rst;
		//parity_done_rst;
		//low_pkt_valid_high;
		data_packet_with_parity(2'b10, 6'h3gv , 1'b1); //(address, payload_length, parity true or false) 
	end
	task data_packet_with_parity(input [1:0]add, input [5:0]payload_length, input true_parity);
	reg [7:0]packet_parity = 8'b0;
	//reg [7:0]internal_parity;
	//reg [6:0]i = payload_length + 1;
		begin
			if(true_parity && (add == 2'b00 || add == 2'b01 || add == 2'b10))
				begin
					//for header
					@(negedge clock);
						detect_add = 1'b1;
						pkt_valid = 1'b1;
						data_in = {payload_length, add};
						packet_parity = data_in ^ packet_parity;
					@(negedge clock);
						detect_add = 1'b0;
						lfd_state = 1'b1;	
					//for payload
					repeat(payload_length)
						begin
							@(negedge clock);
								lfd_state = 1'b0;
								ld_state = 1'b1;
								fifo_full = 1'b0;
								data_in = $random;
								packet_parity = data_in ^ packet_parity;
						end
					//to give the packet parity to the uut
					@(negedge clock);
						//ld_state = 1'b0;
						pkt_valid = 1'b0;
						data_in = packet_parity;
					@(negedge clock);
						ld_state = 1'b0;
				end
			else if(~true_parity && (add == 2'b00 || add == 2'b01 || add == 2'b10))
				begin
					//for header
					@(negedge clock);
						detect_add = 1'b1;
						pkt_valid = 1'b1;
						data_in = {payload_length, add};
						packet_parity = data_in ^ packet_parity;
					@(negedge clock);
						detect_add = 1'b0;
						lfd_state = 1'b1;	
					//for payload
					repeat(payload_length)
						begin
							@(negedge clock);
								lfd_state = 1'b0;
								ld_state = 1'b1;
								fifo_full = 1'b0;
								data_in = $random;
								packet_parity = data_in ^ packet_parity;
						end
					//to give the packet parity to the uut
					@(negedge clock);
						//ld_state = 1'b0;
						pkt_valid = 1'b0;
						//data_in = packet_parity;
						data_in = $random;
					@(negedge clock);
						ld_state = 1'b0;
				end
		end
	endtask
	task low_pkt_valid_high;
		begin
			@(negedge clock);
				ld_state = 1'b1;
				pkt_valid = 1'b0;
			@(negedge clock);
				ld_state = 1'b0;
				pkt_valid = 1'b1;
		end
	endtask
	task parity_done_rst;
		begin
			@(negedge clock);
				detect_add = 1'b1;
			@(negedge clock);
				detect_add = 1'b0;
		end
	endtask
	task low_pkt_valid_rst;
		begin
			@(negedge clock);
				rst_int_reg = 1'b1;
			@(negedge clock);
				rst_int_reg = 1'b0;
		end
	endtask
	task rstn;
		begin
			@(negedge clock);
				resetn = 1'b0;
			@(negedge clock);
				resetn = 1'b1;
		end
	endtask
	task parity_done_high(input [1:0]condition);
		begin
			if(condition == 1'b0)
				begin
					@(negedge clock);
						ld_state = 1'b1;
						fifo_full = 1'b0;
						pkt_valid = 1'b0;
					@(negedge clock);
						ld_state = 1'b0;
						fifo_full = 1'b1;
						pkt_valid = 1'b1;
				end
			else if(condition == 1'b1)
				begin
					@(negedge clock);
						//to make low_pkt_valid high
						ld_state = 1'b1;
						pkt_valid = 1'b0;
						fifo_full = 1'b1;
					@(negedge clock);
						laf_state = 1'b1;
				end
		end
	endtask
endmodule