`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:18:10 02/21/2025 
// Design Name: 
// Module Name:    router_fsm_tb 
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
//Module name
module router_fsm_tb;

	//INPUTS AS REG
	reg clock;
	reg resetn;
	reg pkt_valid;
	reg [1:0]data_in;
	reg fifo_full;
	reg fifo_empty_0;
	reg fifo_empty_1;
	reg fifo_empty_2; 
	reg soft_reset_0;
	reg soft_reset_1;
	reg soft_reset_2; 
	reg parity_done;
	reg low_packet_valid; 
	
	//OUTPUTS AS WIRE
	wire write_enb_reg; 
	wire detect_add;
	wire ld_state;
	wire laf_state;
	wire lfd_state;
	wire full_state;
	wire rst_int_reg; 
	wire busy;
	
	//instantiate the DEVICE UNDER TEST
	router_fsm dut(
	.clock(clock),
	.resetn(resetn),
	.pkt_valid(pkt_valid),
	.data_in(data_in),
	.fifo_full(fifo_full),
	.fifo_empty_0(fifo_empty_0),
	.fifo_empty_1(fifo_empty_1),
	.fifo_empty_2(fifo_empty_2),
	.soft_reset_0(soft_reset_0),
	.soft_reset_1(soft_reset_1),
	.soft_reset_2(soft_reset_2),
	.parity_done(parity_done),
	.low_packet_valid(low_packet_valid),
	.write_enb_reg(write_enb_reg),
	.detect_add(detect_add),
	.ld_state(ld_state),
	.laf_state(laf_state),
	.lfd_state(lfd_state),
	.full_state(full_state),
	.rst_int_reg(rst_int_reg),
	.busy(busy));
	
	//Add stimulus here
	//Reset Initialization and clock generation
	initial begin
		clock  = 1'b0;
		resetn = 1'b1;
		//fifo_full = 1'b0;
		#100;
		forever #5 clock = ~clock;	
	end
	
	//drive DUT here
	initial begin
		#100;
		rstn;
		//After rst, FSM is starting from DECODE_ADDRESS
		//Add program here to start the FSM from DECODE_ADDRESS
		//path_1;
		//path_2;
		//path_11;
		//path_13;
		path_14;
	end
	//PATH 14 -> DA -> Default -> DA -> WTE -> Same State -> WTE -> LFD -> LD -> Default -> LD -> FFS -> LAF -> LP
	// -> CPE -> FFS -> Same State -> FFS -> LAF -> LD -> LP -> CPE -> FFS -> LAF -> LP -> CPE -> FFS -> LAF -> LD 
	//-> Default -> LD -> LP -> CPE -> FFS -> LAF -> DA
	task path_14;
		begin
			//DA -> Default DA
			@(negedge clock);
				pkt_valid = 1'b0;
				data_in = 2'b00;
				fifo_empty_0 = 1'b1;
			@(negedge clock);
				//Check for DA
				if(detect_add)
					begin
						$display("Test Passed: FSM transitioned to DECODE_ADDRESS state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to DECODE_ADDRESS.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//DA -> WTE
				pkt_valid = 1'b1;
				data_in = 2'b00;
				fifo_empty_0 = 1'b0;
			@(negedge clock);
				//Check for WTE
				if((busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to WAIT_TILL_EMPTY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to WAIT_TILL_EMPTY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//WTE -> Same State WTE
				fifo_empty_0 = 1'b0;
			@(negedge clock);
				//Check for WTE
				if((busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to WAIT_TILL_EMPTY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to WAIT_TILL_EMPTY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//WTE -> LFD
				fifo_empty_0 = 1'b1;
			@(negedge clock);
				//Check for LFD
				if((lfd_state) && (busy))
					begin
						$display("Test Passed: FSM transitioned to LOAD_FIRST_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_FIRST_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LFD -> LD
				//(Unconditional)
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> Default LD
				fifo_full = 1'b0;
				pkt_valid = 1'b1;
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> LAF
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for LAF
				if((laf_state) && (busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LAF -> LP
				parity_done = 1'b0;
				low_packet_valid = 1'b1;
			@(negedge clock);
				//Check for LP
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LP -> CPE
				//(unconditional)
			@(negedge clock);
				//Check for CPE
				if((rst_int_reg) && (busy))
					begin
						$display("Test Passed: FSM transitioned to CHECK_PARITY_EROOR state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_EROOR.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//CPE -> FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> Same State FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> LAF
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for LAF 
				if((laf_state) && (busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LAF -> LD
				parity_done = 1'b0;
				low_packet_valid = 1'b0;
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> LP
				fifo_full = 1'b0;
				pkt_valid = 1'b0;
			@(negedge clock);
				//Check for LP
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LP -> CPE
				//(Unconditional)
			@(negedge clock);
				//Check for CPE
				if((rst_int_reg) && (busy))
					begin
						$display("Test Passed: FSM transitioned to CHECK_PARITY_EROOR state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_EROOR.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//CPE -> FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> LAF
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for LAF
				if((laf_state) && (busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LAF -> LP
				parity_done = 1'b0;
				low_packet_valid = 1'b1;
			@(negedge clock);
				//Check for LP
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LP -> CPE
				//(Unconditional)
			@(negedge clock);
				//Check for CPE
				if((rst_int_reg) && (busy))
					begin
						$display("Test Passed: FSM transitioned to CHECK_PARITY_EROOR state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_EROOR.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//CPE -> FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> LAF
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for LAF
				if((laf_state) && (busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LAF -> LD
				parity_done = 1'b0;
				low_packet_valid = 1'b0;
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> Defualt LD
				fifo_full = 1'b0;
				pkt_valid = 1'b1;
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> LP
				fifo_full = 1'b0;
				pkt_valid = 1'b0;
			@(negedge clock);
				//Check for LP
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LP -> CPE 
				//(Unconditional)
			@(negedge clock);
				//Check for CPE
				if((rst_int_reg) && (busy))
					begin
						$display("Test Passed: FSM transitioned to CHECK_PARITY_EROOR state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_EROOR.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//CPE -> FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> LAF
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for LAF
				if((laf_state) && (busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LAF -> DA
				parity_done = 1'b1;
			@(negedge clock);
				//Check for DA
				if(detect_add)
					begin
						$display("Test Passed: FSM transitioned to DECODE_ADDRESS state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to DECODE_ADDRESS.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
		end
	endtask
	//PATH 13 -> DA -> by deafult -> DA -> LFD -> LD -> by Default -> LD -> FFS -> Same State -> FFS -> LAF -> LD 
	//-> Default -> LD -> LP -> CPE -> FFS -> LAF -> LD -> Default -> LD -> LP -> CPE -> DA
	task path_13;
		begin
			//DA -> DA
			@(negedge clock);
				pkt_valid = 1'b0;
				data_in = 2'b00;
				fifo_empty_0 = 1'b1;
			@(negedge clock);
				//Check for DA
				if(detect_add)
					begin
						$display("Test Passed: FSM transitioned to DECODE_ADDRESS state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to DECODE_ADDRESS.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//DA -> LFD
				pkt_valid = 1'b1;
				data_in = 2'b00;
				fifo_empty_0 = 1'b1;
			@(negedge clock);
				//Check for LFD
				if((lfd_state) && (busy))
					begin
						$display("Test Passed: FSM transitioned to LOAD_FIRST_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_FIRST_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LFD -> LD (Unconditionaly)
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> By Default LD
				pkt_valid = 1'b1;
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> LAF
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for LAF
				if((laf_state) && (busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LAF -> LD
				parity_done = 1'b0;
				low_packet_valid = 1'b0;
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> By Default LD
				fifo_full = 1'b0;
				pkt_valid = 1'b1;
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> LP
				fifo_full = 1'b0;
				pkt_valid = 1'b0;
			@(negedge clock);
				//Check for LP 
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LP -> CPE
				//(Unconditional)
			@(negedge clock);
				//Check for CPE
				if((rst_int_reg) && (busy))
					begin
						$display("Test Passed: FSM transitioned to CHECK_PARITY_EROOR state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_EROOR.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//CPE -> FFS
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//FFS -> LAF
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for LAF
				if((laf_state) && (busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LAF -> LD
				parity_done = 1'b0;
				low_packet_valid = 1'b0;
			@(negedge clock);
				//Check for LD 
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> By Default LD
				fifo_full = 1'b0;
				pkt_valid = 1'b1;
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LD -> LP
				fifo_full = 1'b0;
				pkt_valid = 1'b0;
			@(negedge clock);
				//Check for LP
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//LP -> CPE
				//(Unconditional)
			@(negedge clock);
				//Check for CPE;
				if((rst_int_reg) && (busy))
					begin
						$display("Test Passed: FSM transitioned to CHECK_PARITY_EROOR state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_EROOR.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//CPE -> DA
				fifo_full = 1'b0;
			@(negedge clock);
				//Check for DA
				if(detect_add)
					begin
						$display("Test Passed: FSM transitioned to DECODE_ADDRESS state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to DECODE_ADDRESS.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
		end
	endtask
	//PATH 11 -> DA -> WTE -> SAME STATE (WTE) -> LFD -> LD -> LP -> CPE -> FFS -> LAF -> LD -> LP -> CPE -> FFS -> LAF -> DA
	task path_11;
		begin
			//DA -> WTE
			@(negedge clock);
				pkt_valid = 1'b1;
				data_in[1:0] = 2'b00;
				fifo_empty_0 = 1'b0;
			@(negedge clock);
				//Check for WTE
				if((busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to WAIT_TILL_EMPTY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to WAIT_TILL_EMPTY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//pkt_valid = 1'b0;
				//WTE -> Same State (WTE)
				fifo_empty_0 = 1'b0;
			//WTE -> Same State (WTE)
			@(negedge clock);
				if((busy) && (~write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to WAIT_TILL_EMPTY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to WAIT_TILL_EMPTY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_empty_0 = 1'b1;
			//WTE -> LFD
			@(negedge clock);
				if((lfd_state) && (busy))
					begin
						$display("Test Passed: FSM transitioned to LOAD_FIRST_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_FIRST_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_empty_0 = 1'b0;
			//WTE -> LFD
			//@(negedge clock);
				//fifo_empty_0 = 1'b1;
			//@(negedge clock);
				//fifo_empty_0 = 1'b0;
			//LFD -> LD
			//(Unconditional)
			//LD -> LP
			@(negedge clock);
				//Check for LD
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				pkt_valid = 1'b0;
				fifo_full = 1'b0;
			//LP -> CPE
			//(Unconditional)
			//CPE -> FFS
			@(negedge clock);
				//Check for LP
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
			@(negedge clock);
				//Check for CPE
				if((rst_int_reg) && (busy))
					begin
						$display("Test Passed: FSM transitioned to CHECK_PARITY_EROOR state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_EROOR.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_full = 1'b1;
			@(negedge clock);
				//Check for FFS
				if((busy) && (write_enb_reg) && (full_state))
					begin
						$display("Test Passed: FSM transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_full = 1'b0;
			//FFS -> LAF
			@(negedge clock);
				//Check for LAF
				if((busy) && (write_enb_reg) && (laf_state))
					begin
						$display("Test Passed: FSM transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				parity_done = 1'b0;
				low_packet_valid = 1'b0;
			@(negedge clock);
				//Check for LD
				if((~busy) && (write_enb_reg) && (ld_state))
					begin
						$display("Test Passed: FSM transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_full = 1'b0;
				pkt_valid = 1'b0;
			//LAF -> LD
			@(negedge clock);
				//Check for LP
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//parity_done = 1'b0;
				//low_pkt_valid = 1'b0;
				//LP -> CPE (Unconditional)
			@(negedge clock);
				//Check for CPE
				if((busy) && (rst_int_reg))
					begin
						$display("Test Passed: FSM transitioned to CHECK_PARITY_ERROR state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_ERROR.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_full = 1'b0;
				//parity_done = 1'b1;
				//low_pkt_valid = 1'b1;
			//LD -> LP
			@(negedge clock);
				//Check for DA
				if(detect_add)
					begin
						$display("Test Passed: FSM transitioned to DECODE_ADDRESS state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to DECODE_ADDRESS.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				//pkt_valid = 1'b0;
				//fifo_full = 1'b0;
			//@(negedge clock);
				//pkt_valid = 1'b1;
				//fifo_full = 1'b1;
			//LP -> CPE
			//(Unconditional)
			//CPE -> FFS
			//@(negedge clock);
				//fifo_full = 1'b1;
			//@(negedge clock);
				//fifo_full = 1'b0;
			//FFS -> LAF
			//@(negedge clock);
				//fifo_full = 1'b0;
			//@(negedge clock);
				//fifo_full = 1'b1;
			//LAF -> DA
			//@(negedge clock);
				//parity_done = 1'b1;
			//@(negedge clock);
				//parity_done = 1'b0;
		end
	endtask
	//PATH 2 -> DA -> WTE -> LFD -> LD -> LP -> CPE -> DA
	task path_2;
		begin
			// DA -> WTE
			@(negedge clock);
				pkt_valid = 1'b1;
				data_in[1:0] = 2'b00;
				fifo_empty_0 = 1'b0;
			@(negedge clock);
				if((busy) && (~write_enb_reg))
					begin
					$display("Test Passed: FSM transitioned to WAIT_TILL_EMPTY state.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
					$display("Test Failed: FSM did not transit correctly to WAIT_TILL_EMPTY.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				pkt_valid = 1'b0;
				data_in[1:0] = 2'b00;
				fifo_empty_0 = 1'b1;
			//WTE -> LFD
			@(negedge clock);
				if((lfd_state) && (busy))
					begin
					$display("Test Passed: FSM transitioned to LOAD_FIRST_DATA state.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
					$display("Test Failed: FSM did not transit correctly to LOAD_FIRST_DATA.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				pkt_valid = 1'b1;
				data_in[1:0] = 2'b00;
				fifo_empty_0 = 1'b1;
			//LFD -> LD
			//(Unconditional)
			@(negedge clock);
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
					$display("Test Passed: FSM transitioned to LOAD_DATA state.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
					$display("Test Failed: FSM did not transit correctly to LOAD_DATA.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				pkt_valid = 1'b0;
				data_in[1:0] = 2'b00;
				fifo_empty_0 = 1'b0;
				fifo_full = 1'b0;
			
			//LD -> LP
			@(negedge clock);
				if((busy) && (write_enb_reg))
					begin
						$display("Test Passed: FSM transitioned to LOAD_PARITY state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
					$display("Test Failed: FSM did not transit correctly to LOAD_PARITY.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				pkt_valid = 1'b0;
			//LP -> CPE
			//(Unconditional)
			//CPE -> DA
			@(negedge clock);
				if((busy) && (rst_int_reg))
					begin
					$display("Test Passed: FSM transitioned to CHECK_PARITY_ERROR state.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
					$display("Test Failed: FSM did not transit correctly to CHECK_PARITY_ERROR.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_full = 1'b0;
			//To check Present State value	
			@(negedge clock);
				if(detect_add)
					begin
					$display("Test Passed: FSM transitioned to DECODE_ADDRESS state.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
					$display("Test Failed: FSM did not transit correctly to DECODE_ADDRESS.");
					$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
		end
	endtask
	//PATH 1 -> DA -> LFD -> LD -> FFS -> LAF -> DA
	task path_1;
		begin
			// DA -> LFD
			@(negedge clock);
				pkt_valid = 1'b1;
				data_in[1:0] = 2'b00;
				fifo_empty_0 = 1'b1;
			//In this negedge, Present State is in the LFD State
			@(negedge clock);
				pkt_valid = 1'b0;
				fifo_empty_0 = 1'b0;
				if((lfd_state) && (busy))
					begin
						$display("Test Passed: FSM transitioned to LOAD_FIRST_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed: FSM did not transit correctly to LOAD_FIRST_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
			// LFD -> LD (unconditional)
			
			// LD -> FFS
			@(negedge clock);
				if((ld_state) && (~busy) && (write_enb_reg))
					begin
						$display("Test Passed: Present State transitioned to LOAD_DATA state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed:  Present State did not transit correctly to LOAD_DATA.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_full = 1'b1;
			// FFS -> LAF
			@(negedge clock);
				if((full_state) && (busy) && (~write_enb_reg))
					begin
						$display("Test Passed: Present State transitioned to FIFO_FULL_STATE state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed:  Present State did not transit correctly to FIFO_FULL_STATE.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				fifo_full = 1'b0;
			// LAF -> DA
			@(negedge clock);
				if((laf_state) && (busy) && (write_enb_reg))
					begin
						$display("Test Passed: Present State transitioned to LOAD_AFTER_FULL state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed:  Present State did not transit correctly to LOAD_AFTER_FULL.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				parity_done = 1'b1;
			@(negedge clock);
				if(detect_add)
					begin
						$display("Test Passed: Present State transitioned to DECODE_ADDRESS state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed:  Present State did not transit correctly to DECODE_ADDRESS.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				parity_done = 1'b0;
		end
	endtask
	
	//to apply SOFT RESET into the FSM
	//Present State would go to DECODE_ADDRESS from any state
	task soft_rst_0;
		begin
			@(negedge clock);
				soft_reset_0 = 1'b1;
			@(negedge clock);
				soft_reset_0 = 1'b0;		
		end
	endtask
	
	//to apply hard reset into the FSM
	//Present State would go to DECODE_ADDRESS from any state
	task rstn;
		begin
			@(negedge clock);
				resetn = 1'b0;
			@(negedge clock);
				resetn = 1'b1;
				if(detect_add)
					begin
						$display("Test Passed: Present State transitioned to DECODE_ADDRESS state.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
				else
					begin
						$display("Test Failed:  Present State did not transit correctly to DECODE_ADDRESS.");
						$display("Present State Value in 2-digit hex: %02h", router_fsm_tb.dut.present_state);
					end
		end
	endtask
endmodule
