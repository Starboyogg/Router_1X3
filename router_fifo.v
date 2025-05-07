`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:59:25 10/27/2024 
// Design Name: 
// Module Name:    fifo_3 
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
//Structured design
module router_fifo(
input clk, resetn, soft_reset,
input [7:0] data_in,
input read_enb, write_enb, lfd_state,
output reg [7:0] data_out,
output full, empty
    );
	 // Parameters
    parameter fifo_depth = 16;
    parameter fifo_width = 9;
    parameter addr_width = 6;
	 
	 // Memory and pointers
    reg [fifo_width-1:0] mem [0:fifo_depth-1]; //internal memory of fifo
    reg [addr_width-1:0] rd_ptr = 5'h0;
	 reg [addr_width-1:0] wr_ptr = 5'h0;
    reg [addr_width:0] payload_counter = 7'h00; //it checks the packet is valid or not; to make the fifo intelligent
	 //it counts the no. of length from the header and gives only upto the valid data in output
	 //integer i;
	 
	 reg write_enb_delayed = 1'b0;
	 //for reset, data read and write logic
	 always@(posedge clk)
		begin
			if(!resetn || soft_reset)
				begin
					payload_counter <= 7'h00;
					data_out <= 9'bz;
					
					/*for(i = 1'b0; i < fifo_depth; i = i+1)
						begin
							mem[i] <= 8'h0;
						end*/
				end
			else
				begin
					// Write operation
					if ((write_enb || write_enb_delayed)&& !full) 
					//if ((lfd_state || write_enb)&& !full)
						begin
							
										 //if {1      , length + addr} means header
										 //if {0      , payload} means payload data
							//bit slicing				
							//mem[wr_ptr] <= {lfd_state,data_in}; //bit select
							mem[wr_ptr[3:0]][8:0] <= {lfd_state,data_in}; //bit select
						end
					// Read operation
					if (read_enb && !empty)
						begin
							if(mem[rd_ptr][8] == 1'b1) //if 9th bit is 1, means header then...
								begin
									payload_counter <= mem[rd_ptr][7:2] + 1; //00010111 
									//here [7:2] is the length of data and "+ 1" is for parity count
									
									data_out <= mem[rd_ptr[3:0]];
								end
							else
								begin
									data_out <= mem[rd_ptr[3:0]];
									payload_counter <= payload_counter - 1;
								end
						end
					//for data out
					else if(payload_counter == 7'h00)
						data_out <= 8'hzz;
					else if(~read_enb)
						begin
							data_out <= 8'hz;
						end
				end
		end
		
		// fifo address logic
		always @(posedge clk) 
		begin
			if (!resetn || soft_reset) 
				begin
					rd_ptr <= 0;
					wr_ptr <= 0;
					//payload_counter <= 7'h00;
				end
			else 
				begin
					// Write operation
					if ((write_enb || write_enb_delayed)&& !full) 
					//if ((lfd_state || write_enb)&& !full)
						begin
							wr_ptr <= wr_ptr + 1;
						end
					// Read operation
					if (read_enb && !empty)
						begin
							if(mem[rd_ptr][8] == 1'b1)
								begin
									rd_ptr <= rd_ptr + 1;
								end
							else
								begin
									rd_ptr <= rd_ptr + 1;
								end
						end
				end
		end
		
	// Status signal logic
	 assign full = ((wr_ptr[4] != rd_ptr[4])  &&  (wr_ptr[3:0] == rd_ptr[3:0])) ? 1'b1:1'b0;
	 assign empty = (wr_ptr == rd_ptr) ? 1'b1:1'b0;
	 always@(posedge clk)
		begin
			write_enb_delayed <= write_enb;
		end
endmodule
