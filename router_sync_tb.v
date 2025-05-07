`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:13:38 01/23/2025
// Design Name:   router_sync
// Module Name:   C:/Users/ayand/OneDrive/Documents/VERILOG/assignments/router_sync_tb.v
// Project Name:  assignments
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: router_sync
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module router_sync_tb;

	// Inputs
	reg clk;
	reg resetn;
	reg [1:0] data_in;
	reg detect_add;
	reg full_0;
	reg full_1;
	reg full_2;
	reg empty_0;
	reg empty_1;
	reg empty_2;
	reg write_enb_reg;
	reg read_enb_0;
	reg read_enb_1;
	reg read_enb_2;

	// Outputs
	wire [2:0] write_enb;
	wire fifo_full;
	wire vld_out_0;
	wire vld_out_1;
	wire vld_out_2;
	wire soft_reset_0;
	wire soft_reset_1;
	wire soft_reset_2;

	// Instantiate the Unit Under Test (UUT)
	router_sync uut (
		.clk(clk), 
		.resetn(resetn), 
		.data_in(data_in), 
		.detect_add(detect_add), 
		.full_0(full_0), 
		.full_1(full_1), 
		.full_2(full_2), 
		.empty_0(empty_0), 
		.empty_1(empty_1), 
		.empty_2(empty_2), 
		.write_enb_reg(write_enb_reg), 
		.read_enb_0(read_enb_0), 
		.read_enb_1(read_enb_1), 
		.read_enb_2(read_enb_2), 
		.write_enb(write_enb), 
		.fifo_full(fifo_full), 
		.vld_out_0(vld_out_0), 
		.vld_out_1(vld_out_1), 
		.vld_out_2(vld_out_2), 
		.soft_reset_0(soft_reset_0), 
		.soft_reset_1(soft_reset_1), 
		.soft_reset_2(soft_reset_2)
	);
	
	//to generate clock
	initial begin
		clk = 1'b0;
		#100;
		forever clk = #5 ~clk;
	end
	
	initial begin
	#100;
	
	//add stimulus here//
	rstn;
	soft_reset_x(3'b001);
	soft_reset_x(3'b010);
	soft_reset_x(3'b100);
	fifo_select_01;
	fifo_select_02;
	fifo_select_03;
	/*//to invoke the increment counter functions
	fork
		increment_counter_0(5'hFF);
		increment_counter_1(5'hFF);
		increment_counter_2(5'hFF);
	join*/
	
	/*increment_counter_0(5'hAA);
	rstn;
	increment_counter_1(5'hAA);
	rstn;
	increment_counter_2(5'hAA);
	rstn;*/
	end
	
	//task for soft_reset
	task soft_reset_x(input [2:0]soft_reset_x);
		if(soft_reset_x == 3'b001)
			begin
				@(negedge clk)
					empty_0 = 1'b0;
					read_enb_0 = 1'b0;
				//#200;
				//@(negedge clk)
					//read_enb_0 = 1'b1;
					//empty_0 = 1'b1;
				//@(negedge clk)
					//read_enb_0 = 1'b0;
			end
		else if(soft_reset_x == 3'b010)
			begin
				@(negedge clk)
					empty_1 = 1'b0;
					read_enb_1 = 1'b0;
				#200;
				@(negedge clk)
					read_enb_1 = 1'b1;
					//empty_1 = 1'b1;
				@(negedge clk)
					read_enb_1 = 1'b0;
			end
		else if(soft_reset_x == 3'b100)
			begin
				@(negedge clk)
					empty_2 = 1'b0;
					read_enb_2 = 1'b0;
				#200;
				@(negedge clk)
					read_enb_2 = 1'b1;
				@(negedge clk)
					read_enb_2 = 1'b0;
				//empty_2 = 1'b1;
			end
	endtask
	//task to toggle full_x signals
	task toggle_full_x(input [2:0]full_x);
		begin
			if(full_x == 3'b001)
				begin
					@(negedge clk)
						full_0 = 1'b1;
					@(negedge clk)
						full_0 = 1'b0;
					@(negedge clk)
						full_0 = 1'b1;
					@(negedge clk)
						full_0 = 1'b0;
				end
			else if(full_x == 3'b010)
				begin
					@(negedge clk)
						full_1 = 1'b1;
					@(negedge clk)
						full_1 = 1'b0;
					@(negedge clk)
						full_1 = 1'b1;
					@(negedge clk)
						full_1 = 1'b0;
				end
			else if(full_x == 3'b100)
				begin
					@(negedge clk)
						full_2 = 1'b1;
					@(negedge clk)
						full_2 = 1'b0;
					@(negedge clk)
						full_2 = 1'b1;
					@(negedge clk)
						full_2 = 1'b0;
				end
		end
	endtask
	//task to select fifo
	task fifo_select_01;
		begin
			/*@(negedge clk)
				detect_add = 1'b1;
				data_in = 2'b00;
				write_enb_reg = 1'b1;
			@(negedge clk)
				detect_add = 1'b0;
				write_enb_reg = 1'b0;*/
			
			//delay in write_enb_reg
			@(negedge clk)
				detect_add = 1'b1;
				data_in = 2'b00;
			@(negedge clk)
				detect_add = 1'b0;
			@(negedge clk)
			@(negedge clk)
				write_enb_reg = 1'b1;
			@(negedge clk)
				write_enb_reg = 1'b0;
				toggle_full_x(3'b001);
			
		end
	endtask
	task fifo_select_02;
		begin
			/*@(negedge clk)
				detect_add = 1'b1;
				data_in = 2'b01;
				write_enb_reg = 1'b1;
			@(negedge clk)
				detect_add = 1'b0;
				write_enb_reg = 1'b0;*/
			
			//delay in write_enb_reg
			@(negedge clk)
				detect_add = 1'b1;
				data_in = 2'b01;
			@(negedge clk)
				detect_add = 1'b0;
			@(negedge clk)
			@(negedge clk)
				write_enb_reg = 1'b1;
			@(negedge clk)
				write_enb_reg = 1'b0;
				toggle_full_x(3'b010);
		end
	endtask
	task fifo_select_03;
		begin
			/*@(negedge clk)
				detect_add = 1'b1;
				data_in = 2'b10;
				write_enb_reg = 1'b1;
			@(negedge clk)
				detect_add = 1'b0;
				write_enb_reg = 1'b0;*/                 
				
			//delay in write_enb_reg
			@(negedge clk)
				detect_add = 1'b1;
				data_in = 2'b10;
			@(negedge clk)
				detect_add = 1'b0;
			@(negedge clk)
			@(negedge clk)
				write_enb_reg = 1'b1;
			@(negedge clk)
				write_enb_reg = 1'b0;
				toggle_full_x(3'b100);
		end
	endtask
	//task fuction for soft reset
	// because hard reset in the input means soft reset at the output
	task rstn;
		begin
			@(negedge clk);
				resetn = 1'b0;
			@(negedge clk);
				resetn = 1'b1;
		end
	endtask
	
	//task function to increment counter_0
	task increment_counter_0(input [4:0]length);
		begin
			repeat(length)
				begin
					//to increment the counter by 1;
					@(negedge clk);
						empty_0 = 1'b0;
						read_enb_0 = 1'b0;
					/*@(negedge clk);
						empty_0 = 1'b1;
						read_enb_0 = 1'b1;*/
				end
			@(negedge clk);
				empty_0 = 1'b1;
				read_enb_0 = 1'b1;
		end
	endtask
	
	//task function to increment counter_1
	task increment_counter_1(input [4:0]length);
		begin
			repeat(length)
				begin
					//to increment the counter by 1;
					@(negedge clk);
						empty_1 = 1'b0;
						read_enb_1 = 1'b0;
					/*@(negedge clk);
						empty_0 = 1'b1;
						read_enb_0 = 1'b1;*/
				end
			@(negedge clk);
				empty_1 = 1'b1;
				read_enb_1 = 1'b1;
		end
	endtask
	
	//task function to increment counter_2
	task increment_counter_2(input [4:0]length);
		begin
			repeat(length)
				begin
					//to increment the counter by 1;
					@(negedge clk);
						empty_2 = 1'b0;
						read_enb_2 = 1'b0;
					/*@(negedge clk);
						empty_0 = 1'b1;
						read_enb_0 = 1'b1;*/
				end
			@(negedge clk);
				empty_2 = 1'b1;
				read_enb_2 = 1'b1;
		end
	endtask
      
endmodule

