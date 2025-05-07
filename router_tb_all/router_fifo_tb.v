`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:43:37 10/27/2024
// Design Name:   fifo_3
// Module Name:   C:/Users/ayand/OneDrive/Documents/VERILOG/assignments/fifo_3_tb.v
// Project Name:  assignments
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fifo_3
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module router_fifo_tb;

	// Inputs
	reg clk;
	reg resetn;
	reg soft_reset;
	reg [7:0] data_in;
	reg read_enb;
	reg write_enb;
	reg lfd_state;

	// Outputs
	wire [7:0] data_out;
	wire full;
	wire empty;

	// Instantiate the Unit Under Test (UUT)
	fifo_3 uut (
		.clk(clk), 
		.resetn(resetn), 
		.soft_reset(soft_reset), 
		.data_in(data_in), 
		.read_enb(read_enb), 
		.write_enb(write_enb), 
		.lfd_state(lfd_state), 
		.data_out(data_out), 
		.full(full), 
		.empty(empty)
	);

	integer i;
	//to generate clk
	initial begin
		clk = 1'b0;
		#100;
		forever #5 clk = ~clk;
	end
    
	initial begin
		/*fork
			
				rstn;//invoke resetn
				soft_rst;//invoke soft_reset
			
		join*/
		
		
		//to store data
		//d_in(length,addr)
		d_in(6'h0E,2'b01); //invokes task d_in; mem full at 0E
		
		//d_in(6'h01,2'b11); 
		
		
		//to read data
		d_out(5'h0E);
		
		//d_out(4'h03);
		
		/*//header 
		@(negedge clk);
			write_enb = 1'b1;
			data_in = 8'hFF;
			lfd_state = 1'b1;
		@(negedge clk);
			write_enb = 1'b0;
			lfd_state = 1'b0;*/
			
		//01 storing data
		/*repeat(15)
		begin
			@(negedge clk);
				write_enb = 1'b1;
				data_in = $random;
				//lfd_state = 1'b1;
			@(negedge clk); 
				write_enb = 1'b0;
				//lfd_state = 1'b0;
		end*/
		
		/*//02 fetching data
		repeat(5)
		begin
			@(negedge clk);
			read_enb = 1'b1;
			@(negedge clk);
			read_enb = 1'b0;
		end*/
		
		/*//03 storing data
		repeat(20)
		begin
			@(negedge clk);
				write_enb = 1'b0;
				data_in = $random;
			@(negedge clk);
				write_enb = 1'b1;
		end*/
		
		/*//04 fetching data
		repeat(20)
		begin
		@(negedge clk);
			read_enb = 1'b0;
		@(negedge clk);
			read_enb = 1'b1;
		end*/
		
		#1000;
		$finish;
	end
	
	//task for resetn
	task rstn;
		begin
			@(negedge clk);
				resetn = 1'b0;
			@(negedge clk);
				resetn = 1'b1;
		end
	endtask
	//task for soft_reset
	task soft_rst;
		begin
			@(negedge clk);
				soft_reset = 1'b1;
			@(negedge clk);
				soft_reset = 1'b0;
		end
	endtask
	
	//task to generate header and data and parity
	task d_in(input [5:0]length, input [1:0]addr); //6-bit length and 2-bit address
		reg [7:0]parity = 8'h00; //to calculate parity, 8-bit parity register
		
		begin
			///for header
			@(negedge clk);
				write_enb = 1'b1;
				lfd_state = 1'b1;
				//00010111
				data_in = {length,addr}; //concaticnation; generates header
				parity = data_in ^ parity; //XOR operation
			@(negedge clk);
				write_enb = 1'b0;
				lfd_state = 1'b0;
			
			//for payload
			repeat(length)
				begin
					@(negedge clk);
						write_enb = 1'b1;
						data_in = $random;
						parity = data_in ^ parity;
					@(negedge clk);
						write_enb = 1'b0;	
				end
				
			//for payrity
			@(negedge clk);
				write_enb = 1'b1;
				data_in = parity; //stores the parity into fifo
			@(negedge clk);
				write_enb = 1'b0;	
		end
	endtask
	
	//task to read data
	task d_out(input [5:0]length);
		begin
			repeat(length)
				begin
					@(negedge clk);
						read_enb = 1'b1;
					@(negedge clk);
						read_enb = 1'b0;
				end
		end
	endtask
      
endmodule

