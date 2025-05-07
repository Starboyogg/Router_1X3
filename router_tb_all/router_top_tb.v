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
		test_case_1;
		test_case_2;
	end
	
	//task function for test case 2 -> 5 data in, including header & parity
	//saranity check 				-> 5 data out, including header & parity
	//								-> 6 data in
	//								-> 6 data out
	task test_case_2;
		begin
			//data in
			data_packet_in(2'b00, 5'h3, 1'b1);
			data_packet_in(2'b01, 5'h3, 1'b1);
			data_packet_in(2'b10, 5'h3, 1'b1);
			////
			//data out
			data_packet_out(2'b00, 5'h3);
			data_packet_out(2'b01, 5'h3);
			data_packet_out(2'b10, 5'h3);
			//data in
			data_packet_in(2'b00, 5'h4, 1'b1);
			data_packet_in(2'b01, 5'h4, 1'b1);
			data_packet_in(2'b10, 5'h4, 1'b1);
			/////////////////////////////*/
			////
			//data out
			data_packet_out(2'b00, 5'h4);
			data_packet_out(2'b01, 5'h4);
			data_packet_out(2'b10, 5'h4);
		end
	endtask
	//task function for test case 1 -> 5 data in, including header & parity
	//saranity check 				-> 5 data out
	task test_case_1;
		begin
			//data in
			data_packet_in(2'b00, 5'h3, 1'b1);
			data_packet_in(2'b01, 5'h3, 1'b1);
			data_packet_in(2'b10, 5'h3, 1'b1);
			////
			//data out
			data_packet_out(2'b00, 5'h3);
			data_packet_out(2'b01, 5'h3);
			data_packet_out(2'b10, 5'h3);
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