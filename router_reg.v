`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:23:50 04/03/2025 
// Design Name: 
// Module Name:    router_reg 
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
module router_reg(
						input clock, resetn, pkt_valid, fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg,
						input [7:0]data_in,
						output reg err, low_pkt_valid,
						output reg parity_done,
						output reg [7:0]dout
    );
	//Internal registers
	reg [7:0]header_reg; //for the header byte
	
	reg [7:0]dout_rn;
	reg [7:0]dout_rp;
	reg ld_state_delayed = 1'b0;
	reg ld_state_delayed_2 = 1'b0;
	//reg ld_state_delayed_3 = 1'b0;
	reg [7:0]temp_reg; //for the extra data byte (full_state)
	reg [7:0]packet_parity; //to calculate internal parity
	reg [7:0]internal_parity = 8'b0; //for the internal parity
	//reg [5:0]payload_counter = 6'b0; //to detect the packet parity
	reg pkt_valid_delayed = 1'b0;
	reg pkt_valid_delayed_2 = 1'b0;
	reg parity_done_delayed = 1'b0;

	//always for low_pkt_valid
	always@(posedge clock or negedge resetn)
		begin
			if(~resetn)
				begin
					low_pkt_valid <= 1'b0;
				end
			else if(rst_int_reg)
				begin
					low_pkt_valid <= 1'b0;
				end
			else if(ld_state && ~pkt_valid)
				begin
					low_pkt_valid <= 1'b1;
				end
		end
	//always for parity done
	always@(posedge clock or negedge resetn)
		begin
			if(~resetn)
				begin
					parity_done <= 1'b0;
				end
			else if((ld_state && (~fifo_full) && ~pkt_valid) ||
			  (laf_state && (low_pkt_valid) && ~parity_done))
				begin
					parity_done <= 1'b1;
				end
			else if(detect_add)
				begin
					parity_done <= 1'b0;
				end
		end
	//always for err detection
	always@(posedge clock or negedge resetn)
		begin
			if(~resetn)
				begin
					err <= 1'b0;
				end
			else if(parity_done_delayed)
				begin
					if(packet_parity != internal_parity)
						begin
							err <= 1'b1;
						end
				end
		end
	//to detect & store packet parity
	always@(posedge clock)
		begin
			//if(detect_add && pkt_valid)
				//begin
					//if(payload_counter == header_reg[7:2])
					if(ld_state && ~pkt_valid)
						begin
							packet_parity <= data_in; //last payload data
							//payload_counter <= 6'b0;
						end
					/*else
						begin
							payload_counter <= payload_counter + 1;
						end*/
				//enda
			
		end
	//always for internal parity calculation
	always@(posedge clock)
		begin
			//if(~resetn || detect_add) //detect_add added
			if(~resetn)
				begin
					internal_parity <= 8'b0;
				end
			else if(detect_add && pkt_valid)
			//else if(lfd_state && pkt_valid) //pkt_valid adder
				begin
					//internal_parity <= internal_parity ^ header_reg; 
					internal_parity <= internal_parity ^ data_in;
				end
			else if(ld_state_delayed && ~fifo_full && (pkt_valid_delayed || pkt_valid_delayed_2))  //pkt_valid added
				begin
					internal_parity <= internal_parity ^ dout;
				end
			else 
				begin
					internal_parity <= internal_parity;
				end
		end
	//always block for dout
	always@(posedge clock or negedge resetn)
		begin
			if(~resetn)
				begin
					dout <= 8'b0;
				end
			//else if(lfd_state || pkt_valid)
			else if(lfd_state)
				begin
					//$display("Entering lfd_state from register at time %0t",$time);
					dout <= header_reg;
				end
	
			else if((ld_state || ld_state_delayed) && ~fifo_full)
			//else if(ld_state && ~fifo_full)
				begin
					dout <= dout_rn;
				end
			else if(laf_state)
				begin
					dout <= temp_reg;
				end
		end
	//always block for internal regs (header and temp)
	always@(posedge clock)
		begin
			if(detect_add && pkt_valid)
				begin
					header_reg <= data_in; //1st incoming data byte treated as header
				end
			if((ld_state ||  ld_state_delayed_2)&& fifo_full)
			//if(ld_state && fifo_full)
				begin
					temp_reg <= dout_rp;
				end	
		end
		
	//always@(posedge clock)
	always@(negedge clock)
		begin
			//if(detect_add || pkt_valid || ld_state ||ld_state_delayed)
			if(lfd_state || ld_state ||ld_state_delayed)
			dout_rn <= data_in;
		end
	always@(posedge clock)
		begin
			if(ld_state ||ld_state_delayed || ld_state_delayed_2)
			dout_rp <= dout_rn;
		end
		//

   always@(posedge clock)
		begin
			ld_state_delayed<= ld_state;
		end
	always@(posedge clock)
		begin
			ld_state_delayed_2 <= ld_state_delayed;
		end
	//
	//*/
	/*always@(posedge clock)
		begin
			ld_state_delayed_3 <= ld_state_delayed_2;
		end
	*/
	always@(posedge clock)
		begin
			pkt_valid_delayed <= pkt_valid;
		end
	always@(posedge clock)
		begin
			pkt_valid_delayed_2 <= pkt_valid_delayed;
		end
	always@(posedge clock)
		begin
			parity_done_delayed <= parity_done;
		end
endmodule
