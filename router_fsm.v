`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:25:51 02/16/2025 
// Design Name: 
// Module Name:    router_fsm 
// Project Name:   RTL Design & Verification of a 1X3 Router
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
//Module name
module router_fsm(
	clock, resetn, pkt_valid, data_in, fifo_full, 
	fifo_empty_0, fifo_empty_1, fifo_empty_2, 
	soft_reset_0, soft_reset_1, soft_reset_2,
	parity_done, low_pkt_valid,
	write_enb_reg, detect_add, ld_state, laf_state, lfd_state, full_state, rst_int_reg, busy);
	 
	//Declaration
	input      clock, resetn, pkt_valid;
	input      [1:0]data_in;
	input      fifo_full, fifo_empty_0, fifo_empty_1, fifo_empty_2;
	input      soft_reset_0, soft_reset_1, soft_reset_2, parity_done, low_pkt_valid;
	output     detect_add, ld_state, laf_state, lfd_state, full_state, rst_int_reg;
	output	  write_enb_reg;
	output     busy;
	 
	//Parameter for different states
	/* old 
	parameter DECODE_ADDRESS     = 8'b00000000; //00h
	parameter LOAD_FIRST_DATA    = 8'b00000001; //01h
	parameter LOAD_DATA          = 8'b00000010; //02h
	parameter LOAD_PARITY        = 8'b00000100; //04
	parameter FIFO_FULL_STATE    = 8'b00001000; //08
	parameter LOAD_AFTER_FULL    = 8'b00010000; //10
	parameter WAIT_TILL_EMPTY    = 8'b00100000; //20
	parameter CHECK_PARITY_ERROR = 8'b01000000; //40
	*/

	//new
	parameter
		DECODE_ADDRESS=8'b00000001, //h1
		LOAD_FIRST_DATA=8'b00000010, //h2
		LOAD_DATA=8'b00000100,       //h4
		LOAD_PARITY=8'b00001000,    //h8
		FIFO_FULL_STATE=8'b00010000, //h10
		LOAD_AFTER_FULL=8'b00100000, //h20
		WAIT_TILL_EMPTY=8'b01000000, //h40
		CHECK_PARITY_ERROR=8'b10000000; //h80

	//present and next state register declaration
	reg [7:0]present_state;
	reg [7:0]next_state;
	
	//present state logic -> Sequencial
	always@(posedge clock or negedge resetn)
		begin
			if(resetn == 1'b0) //for OR comparison -> ||
				present_state <= DECODE_ADDRESS;
			else if ((soft_reset_0) || (soft_reset_1) || (soft_reset_2))
				present_state <= DECODE_ADDRESS;
			else 
				present_state <= next_state;
		end
	
	//next state logic -> combinational
	//Triggered when only an input signal(including clock edge) is changed
	always@(*)
		begin
			case(present_state)
				//S1 value -> 00h
				DECODE_ADDRESS: begin
					if(  (pkt_valid & (data_in[1:0] == 2'b00) & fifo_empty_0) //for OR operation -> |
						| (pkt_valid & (data_in[1:0] == 2'b01) & fifo_empty_1) 
						| (pkt_valid & (data_in[1:0] == 2'b10) & fifo_empty_2))
						next_state = LOAD_FIRST_DATA;
					else if(  (pkt_valid & (data_in[1:0] == 2'b00) & ~fifo_empty_0) 
						| (pkt_valid & (data_in[1:0] == 2'b01) & ~fifo_empty_1) 
						| (pkt_valid & (data_in[1:0] == 2'b10) & ~fifo_empty_2))
						next_state = WAIT_TILL_EMPTY;	
					else
						next_state = DECODE_ADDRESS;
				end
				//S2 value -> 01h
				LOAD_FIRST_DATA: begin
						next_state = LOAD_DATA;
				end
				//S3 value -> 02h
				LOAD_DATA: begin
					if(fifo_full == 1'b0 && pkt_valid == 1'b0)
						next_state = LOAD_PARITY;
					else if(fifo_full == 1'b1)
						next_state = FIFO_FULL_STATE;
					else
						next_state = LOAD_DATA;
				end
				//S4 value -> 04h
				LOAD_PARITY: begin
						next_state = CHECK_PARITY_ERROR;	
				end
				//S5 value -> 08h
				FIFO_FULL_STATE: begin
					if(fifo_full == 1'b0)
						next_state = LOAD_AFTER_FULL;
					else if(fifo_full == 1'b1)
						next_state = FIFO_FULL_STATE;
				end
				//S6 value -> 10h
				LOAD_AFTER_FULL:begin
					if(parity_done == 1'b1)
						next_state = DECODE_ADDRESS;
					else if((parity_done == 1'b0) && (low_pkt_valid == 1'b1))
						next_state = LOAD_PARITY;
					else if((parity_done == 1'b0) && (low_pkt_valid == 1'b0))
						next_state = LOAD_DATA;
				end
				//S7 value -> 20h
				WAIT_TILL_EMPTY: begin
					if(fifo_empty_0 | fifo_empty_1 | fifo_empty_2)
						next_state = LOAD_FIRST_DATA;
					else if(~fifo_empty_0 | ~fifo_empty_1 | ~fifo_empty_2)
						next_state = WAIT_TILL_EMPTY;
				end
				//S8 value -> 40h
				CHECK_PARITY_ERROR: begin
					if(fifo_full == 1'b0)
						next_state = DECODE_ADDRESS;
					else if(fifo_full == 1'b1)
						next_state = FIFO_FULL_STATE;
				end
				default: begin
					next_state = DECODE_ADDRESS;
				end
			endcase
		end
		
	/////OUTPUT LOGIC/////
	assign busy = ((present_state == LOAD_FIRST_DATA) || (present_state == LOAD_PARITY) 
	|| (present_state == FIFO_FULL_STATE) || (present_state == LOAD_AFTER_FULL) 
	|| (present_state == WAIT_TILL_EMPTY) || (present_state == CHECK_PARITY_ERROR)) ? 1'b1 : 1'b0;
	
	assign write_enb_reg = ((present_state == LOAD_DATA) || (present_state == LOAD_PARITY) 
	|| (present_state == FIFO_FULL_STATE) || (present_state == LOAD_AFTER_FULL) 
	|| (present_state == WAIT_TILL_EMPTY)) ? 1'b1 : 1'b0;
	
	assign detect_add 	= (present_state == DECODE_ADDRESS)     ? 1'b1 : 1'b0; //it is used to detect an incoming packet; also used to latch the first byte as a header byte
	assign lfd_state 		= (present_state == LOAD_FIRST_DATA)    ? 1'b1 : 1'b0; //it is used to load the first data byte to the FIFO
	assign ld_state		= (present_state == LOAD_DATA)		    ? 1'b1 : 1'b0; //it is used to load the payload data to the FIFO	
	assign full_state    = (present_state == FIFO_FULL_STATE)    ? 1'b1 : 1'b0; //it detects the FIFO full state
	assign laf_state     = (present_state == LOAD_AFTER_FULL)    ? 1'b1 : 1'b0; //it is used to latch the data after FIFO_FULL_STATE
	assign rst_int_reg	= (present_state == CHECK_PARITY_ERROR) ? 1'b1 : 1'b0; //it is used to reset low_pkt_valid signal
endmodule
