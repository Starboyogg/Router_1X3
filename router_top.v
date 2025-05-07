`timescale 1ns / 1ps
module router_top(
				  input clock, 
				  input resetn, 
				  input pkt_valid, 
				  input read_enb_0, 
				  input read_enb_1, 
				  input read_enb_2,
				  input [7:0]data_in,
				  output [7:0]data_out_0, 
				  output [7:0]data_out_1, 
				  output [7:0]data_out_2,
				  output vld_out_0, 
				  output vld_out_1, 
				  output vld_out_2, 
				  output err, 
				  output busy
// Declear all  the input and output ports
	);
	
	reg lfd_state_int;
wire [7:0]data_in_fifo;
wire [2:0] write_enb_wire;
router_fsm INST_FSM(
			 //.port_name(signal_name)
			   .clock(clock), 
			   .resetn(resetn), 
			   .pkt_valid(pkt_valid), 
			   .data_in(data_in[1:0]), 
			   .fifo_full(fifo_full), 
			   .fifo_empty_0(empty_0), 
			   .fifo_empty_1(empty_1), 
			   .fifo_empty_2(empty_2), 
	           .soft_reset_0(soft_reset_0), 
			   .soft_reset_1(soft_reset_1), 
			   .soft_reset_2(soft_reset_2),
	           .parity_done(parity_done), 
			   .low_pkt_valid(low_pkt_valid),
	           .write_enb_reg(write_enb_reg), 
			   .detect_add(detect_add), 
			   .ld_state(ld_state), 
			   .laf_state(laf_state), 
			   .lfd_state(lfd_state), 
			   .full_state(full_state), 
			   .rst_int_reg(rst_int_reg), 
			   .busy(busy)
	);

router_reg INST_REG(
					.clock(clock), 
					.resetn(resetn), 
					.pkt_valid(pkt_valid), 
					.fifo_full(fifo_full), 
					.detect_add(detect_add), 
					.ld_state(ld_state), 
					.laf_state(laf_state), 
					.full_state(full_state), 
					//.lfd_state(lfd_state_int),
					.lfd_state(lfd_state), 
					.rst_int_reg(rst_int_reg),
					.data_in(data_in),
					.err(err), 
					.low_pkt_valid(low_pkt_valid),
					.parity_done(parity_done),
					.dout(data_in_fifo)
    );	
	
router_sync INST_SYNC(
					  .clk(clock),
					  .resetn(resetn),
					  .data_in(data_in[1:0]),
					  .detect_add(detect_add), //from FSM
                      .full_0(full_0), //from FIFO 0
                      .full_1(full_1), //from FIFO 1
                      .full_2(full_2), //from FIFO 2
                      .empty_0(empty_0), //from FIFO 0
					  .empty_1(empty_1), //from FIFO 1
                      .empty_2(empty_2), //from FIFO 2
                      .write_enb_reg(write_enb_reg), //from FSM
                      .read_enb_0(read_enb_0),
                      .read_enb_1(read_enb_1),
					  .read_enb_2(read_enb_2),
					//.port_name({signal_a, signal_b, signal_c})
                      //.write_enb({write_enb_0, write_enb_1, write_enb_2}),
					  //.sync port (top module wire), // with same bit
					  .write_enb(write_enb_wire),
                      .fifo_full(fifo_full),
                      .vld_out_0(vld_out_0),
                      .vld_out_1(vld_out_1),
                      .vld_out_2(vld_out_2),
                      .soft_reset_0(soft_reset_0),
                      .soft_reset_1(soft_reset_1),
                      .soft_reset_2(soft_reset_2)
	);
	
router_fifo INST_FIFO_0(
						.clk(clock), 
						.resetn(resetn), 
						.soft_reset(soft_reset_0),
						.data_in(data_in_fifo),
						.read_enb(read_enb_0), 
						.write_enb(write_enb_wire[0]), 
						.lfd_state(lfd_state_int),
						.data_out(data_out_0),
						.full(full_0), 
						.empty(empty_0)
    );
	
router_fifo INST_FIFO_1(
						.clk(clock), 
						.resetn(resetn), 
						.soft_reset(soft_reset_1),
						.data_in(data_in_fifo),
						.read_enb(read_enb_1), 
						.write_enb(write_enb_wire[1]), 
						.lfd_state(lfd_state_int),
						.data_out(data_out_1),
						.full(full_1), 
						.empty(empty_1)
    );
	
router_fifo INST_FIFO_2(
						.clk(clock), 
						.resetn(resetn), 
						.soft_reset(soft_reset_2),
						.data_in(data_in_fifo),
						.read_enb(read_enb_2), 
						.write_enb(write_enb_wire[2]), 
						.lfd_state(lfd_state_int),
						.data_out(data_out_2),
						.full(full_2), 
						.empty(empty_2)
    );
	
	
	
	always@(posedge clock or negedge resetn)
		begin
			if(~resetn)
				begin
					lfd_state_int<= 1'b0;
				end
			else 
				lfd_state_int<= lfd_state;
		end
endmodule 