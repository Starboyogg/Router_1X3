`timescale 1ns / 1ps
module router_top_tb;
	//Declare inputs and outputs
	reg clock;
	reg resetn;
	reg [7:0]data_in;
	reg pkt_valid;
	reg read_enb_0;
	reg read_enb_1;
	reg read_enb_2;
	
	wire [7:0]data_out_0;
	wire [7:0]data_out_1;
	wire [7:0]data_out_2;
	wire vld_out_0;
	wire vld_out_1;
	wire vld_out_2;
	wire err;
	wire busy;
	
	//Instantiation
	router_top uut(
					.clock(clock),
					.resetn(resetn),
					.data_in(data_in),
					.pkt_valid(pkt_valid),
					.read_enb_0(read_enb_0),
					.read_enb_1(read_enb_1),
					.read_enb_2(read_enb_2),
					.data_out_0(data_out_0),
					.data_out_1(data_out_1),
					.data_out_2(data_out_2),
					.vld_out_0(vld_out_0),
					.vld_out_1(vld_out_1),
					.vld_out_2(vld_out_2),
					.err(err),
					.busy(busy)
	);
	initial begin
		clock = 1'b0;
		pkt_valid = 1'b0;
		resetn = 1'b1;
		read_enb_0 = 1'b0;
		read_enb_1 = 1'b0;
		read_enb_2 = 1'b0;
		#100;
		forever #5 clock = ~clock; 
	end
	initial begin
		#100;
		rst;

		/*//test case 1 explanation     		-> 5 data in, into the all 3 FIFOs, simultaneously 
		//										-> including header & parity
		//saranity check 						-> 5 data out
		test_case_1; //VERIFIED TEST CASE//
		//*/

		/*//test case 2 explanation				-> 5 data in, including header & parity
		//										-> into all 3 FIFOs simultaneously
		//saranity check 						-> 5 data out, including header & parity
		//										-> 6 data in
		//										-> 6 data out
		test_case_2; //VERIFIED TEST CASE//
		//*/

		//test case 3 explanation				-> 16 data in, and fifo gets full
		//										-> into all 3 FIFOs simultaneously
		//saranity check 						-> 16 data out, and fifo gets empty
		test_case_3; //VERIFIED TEST CASE//
		//

		/*//test case 4 explanation 	    	    -> 17 data in, but still fifo does not get full;  
		//				 				    	-> as data out starts from when 15 no. data in going in, i.e fifo does not get full
		//								    	-> extra 1 data stored in fifo, overwrite
		//								    	-> 17 data out in total
		test_case_4; //VERIFIED TEST CASE//
		//*/

		/*//test case 5(temp_reg) explanation	-> 17 data in, fifo gets full in 16th data, 1 extra data stored in temp_reg, 
		//									     that 1 extra data gets overwrite in fifo memory, when we starts reading data packets
		//				 				     	-> 17 data out in total
		test_case_5; //VERIFIED TEST CASE//
		//*/

		/*//test case 6(soft_reset_x) explanation	-> 16 data in, fifo gets full
		//									    -> no read operation upto 30 clock cycles()
		//				 				     	-> so soft_reset_x get triggered and fifo memory gets reset internally
		test_case_6; //VERIFIED TEST CASE//
		//*/
		
		/*//test case 7(err high) explanation	    -> 16 data in, fifo gets full
		//										    -> we will give a Random Packet Parity 
		//										    -> Parity Missmatch between Packet Parity & Internal Parity
		//										    -> Error signal gets high							 
		test_case_7; //VERIFIED TEST CASE//
		//*/
	end

	//task function for test case 7(err high)   -> 16 data in, fifo gets full
		//										-> we will give a Random Packet Parity 
		//										-> Parity Missmatch between Packet Parity & Internal Parity
		//	
	task test_case_7;
		begin
			data_packet_in(2'b00, 6'he, 1'b0); //data packet with random packet parity
			rst;
			data_packet_in(2'b01, 6'he, 1'b0); //data packet with random packet parity
			rst;
			data_packet_in(2'b10, 6'he, 1'b0); //data packet with random packet parity
			rst;
		end	
	endtask
	//task function for test case 6(soft_reset_x)	-> 16 data in, fifo gets full
	//									    		-> no read operation upto 30 clock cycles()
	//				 				     			-> so soft_reset_x get triggered and fifo memory gets reset internally
	task test_case_6;
		begin
			//for FIFO 0
			data_packet_in(2'b00, 5'he, 1'b1);	//he = 16 in decimal
			repeat(40)
				begin
					@(negedge clock);
				end
			data_packet_out(2'b00, 5'he);
			//for FIFO 1
			data_packet_in(2'b01, 5'he, 1'b1);	//he = 16 in decimal
			repeat(40)
				begin
					@(negedge clock);
				end
			data_packet_out(2'b01, 5'he);
			//for FIFO 2
			data_packet_in(2'b10, 5'he, 1'b1);	//he = 16 in decimal
			repeat(40)
				begin
					@(negedge clock);
				end
			data_packet_out(2'b10, 5'he);
		end
	endtask
	//task function for test case 5 -> 17 data in, fifo gets full in 16th data, 1 extra data stored in temp_reg, 
	//									that 1 extra data gets overwrite in fifo memory, when we starts reading data packets
	//				 				-> 17 data out in total
	task test_case_5;
		begin
			//data_in
			//17 data in i.e 1 data extra to check temp_reg
			//temp_reg has been stored 17th no. data
			data_packet_in(2'b00, 5'hf, 1'b1);
			

			//data out
			//check that, temp_reg data in latching into top data_out or not
			//yes its overwrite into the FIFO memory and get latched out properly
			data_packet_out(2'b00, 5'hf);

			//same as before for other 2 FIFOs
			data_packet_in(2'b01, 5'hf, 1'b1);
			data_packet_out(2'b01, 5'hf);
			data_packet_in(2'b10, 5'hf, 1'b1);
			data_packet_out(2'b10, 5'hf);
		end
	endtask

	//data_packet_in for test_case_4
	task data_packet_in_and_out_for_test_case_4(input [1:0]add, input [5:0]payload_length, input true_parity);
		reg [7:0]packet_parity = 8'b0;
		begin
			//to generate header
			@(negedge clock);
				pkt_valid = 1'b1;
				data_in = {payload_length, add};
				packet_parity = packet_parity ^ data_in; 
			//buffer
			/*//repeat(1)
				begin
					@(negedge clock);
					data_in = 8'bz;
				end
				*/
			//to generate payload
			repeat(payload_length)
				begin
					@(negedge clock);
						pkt_valid = 1'b1;
						data_in = $random;
						packet_parity = packet_parity ^ data_in;
				end
			/*//last data, right before the parity
			@(negedge clock);
				pkt_valid = 1'b1;
				data_in = $random;
				packet_parity = packet_parity ^ data_in;
				*/
			//parity
			@(negedge clock);
				if(true_parity)
					begin
						pkt_valid = 1'b0;
						data_in = packet_parity;
						if(add == 2'b00)
							read_enb_0 = 1'b1;
						else if(add == 2'b01)
							read_enb_1 = 1'b1;
						else if(add == 2'b10)
							read_enb_2 = 1'b1;
					end
				else if (~true_parity)
					begin
						pkt_valid = 1'b0;
						data_in = $random;
					end
			//@(negedge clock);
			repeat(3)
				begin
		   			@(negedge clock);
						data_in = 8'bz;
				end
			@(negedge clock);
				repeat(12)
					begin
						@(negedge clock);
						if(add == 2'b00)
							read_enb_0 = 1'b1;
						else if(add == 2'b01)
							read_enb_1 = 1'b1;
						else if(add == 2'b10)
							read_enb_2 = 1'b1;
					end
			@(negedge clock);	
				read_enb_0 = 1'b0;
				read_enb_1 = 1'b0;
				read_enb_2 = 1'b0;
		end
	endtask

	//task function for test case 4 -> 17 data in, still fifo does not get full, extra 1 data stored in fifo, over writed 
	//saranity check 				-> 17 data out, starts from when 15 no. data in going in
	task test_case_4;
		begin
				//data in and out
				data_packet_in_and_out_for_test_case_4(2'b00, 5'hf, 1'b1);
				//data in and out
				data_packet_in_and_out_for_test_case_4(2'b01, 5'hf, 1'b1);
				//data in and out
				data_packet_in_and_out_for_test_case_4(2'b10, 5'hf, 1'b1);
		end
	endtask
	
	//task function for test case 3 -> 16 data in, fifo full
	//saranity check 				-> 16 data out, fifo empty
	task test_case_3;
		begin
			//data in
			data_packet_in(2'b00, 5'he, 1'b1);
			data_packet_out(2'b00, 5'he);
			data_packet_in(2'b01, 5'he, 1'b1);
			data_packet_out(2'b01, 5'he);
			data_packet_in(2'b10, 5'he, 1'b1);
			data_packet_out(2'b10, 5'he);
			////
			/*//data out
			data_packet_out(2'b00, 5'he);
			data_packet_out(2'b01, 5'he);
			data_packet_out(2'b10, 5'he);
			//*/
		end
	endtask
	//task function for test case 2 -> 5 data in, including header & parity
	//saranity check 				-> 5 data out, including header & parity
	//								-> 6 data in
	//								-> 6 data out
	task test_case_2;
		begin
			//data in
			data_packet_in(2'b00, 5'h3, 1'b1);
			data_packet_out(2'b00, 5'h3);
			data_packet_in(2'b01, 5'h3, 1'b1);
			data_packet_out(2'b01, 5'h3);
			data_packet_in(2'b10, 5'h3, 1'b1);
			data_packet_out(2'b10, 5'h3);
			////
			//data out
			
			
			
			//data in
			data_packet_in(2'b00, 5'h4, 1'b1);
			data_packet_out(2'b00, 5'h4);
			data_packet_in(2'b01, 5'h4, 1'b1);
			data_packet_out(2'b01, 5'h4);
			data_packet_in(2'b10, 5'h4, 1'b1);
			data_packet_out(2'b10, 5'h4);
			/////////////////////////////*/
			////
			//data out
			
			
			
		end
	endtask
	//task function for test case 1 -> 5 data in, including header & parity
	//saranity check 				-> 5 data out
	task test_case_1;
		begin
			//data in
			data_packet_in(2'b00, 5'h3, 1'b1);
			data_packet_out(2'b00, 5'h3);
			data_packet_in(2'b01, 5'h3, 1'b1);
			data_packet_out(2'b01, 5'h3);
			data_packet_in(2'b10, 5'h3, 1'b1);
			data_packet_out(2'b10, 5'h3);
			////
			//data out
			
			
			
		end
	endtask
	//task funtion for data out
	task data_packet_out(input [1:0]add, input [5:0]data_out_length);
		begin
			repeat(data_out_length + 2)
				begin
					@(negedge clock);
						if(add == 2'b00)
							begin
								read_enb_0 = 1'b1;
							end
						else if(add == 2'b01)
							begin
								read_enb_1 = 1'b1;
							end
						else if(add == 2'b10)
							begin
								read_enb_2 = 1'b1;
							end
				end
			@(negedge clock);
				read_enb_0 = 1'b0;
				read_enb_1 = 1'b0;
				read_enb_2 = 1'b0;
		end
	endtask
	//task funtion for full data packet
	task data_packet_in(input [1:0]add, input [5:0]payload_length, input true_parity);
		reg [7:0]packet_parity = 8'b0;
		begin
			//to generate header
			@(negedge clock);
				pkt_valid = 1'b1;
				data_in = {payload_length, add};
				packet_parity = packet_parity ^ data_in; 
			//buffer
			/*//repeat(1)
				begin
					@(negedge clock);
					data_in = 8'bz;
				end
				*/
			//to generate payload
			repeat(payload_length)
				begin
					@(negedge clock);
						pkt_valid = 1'b1;
						data_in = $random;
						packet_parity = packet_parity ^ data_in;
				end
			@(negedge clock);
				if(true_parity)
					begin
						pkt_valid = 1'b0;
						data_in = packet_parity;
					end
				else if (~true_parity)
					begin
						pkt_valid = 1'b0;
						data_in = $random;
					end
			repeat(3)
				begin
		   			@(negedge clock);
						data_in = 8'bz;
				end
		end
	endtask
	
	//task funtion for resetn pin
	task rst;
		begin
			@(negedge clock);
				resetn = 1'b0;
			@(negedge clock);
				resetn = 1'b1;
		end
	endtask

endmodule