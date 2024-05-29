///////////////////  TOP  /////////////////////
`timescale 1ns/10ps
module top();
	import spi_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
//	`include "timescale.v"
//	`include "spi_defines.v"
//Generate clock
	bit clock;
	always#5 clock =~ clock;
	
//Instantiate interface
	wishbone_if  w_if(clock);
	slave_if     s_if(clock);//clk passed
//Instantiate DUV
	spi_top DUV(//Wishbone signal
			.wb_clk_i(clock), .wb_rst_i(w_if.wb_rst_i), .wb_adr_i(w_if.wb_adr_i),
			.wb_dat_i(w_if.wb_dat_i), .wb_dat_o(w_if.wb_dat_o), .wb_sel_i(w_if.wb_sel_i),
			 .wb_we_i(w_if.wb_we_i ), .wb_stb_i(w_if.wb_stb_i), .wb_cyc_i(w_if.wb_cyc_i), 
			.wb_ack_o(w_if.wb_ack_o), .wb_err_o(w_if.wb_err_o), .wb_int_o(w_if.wb_int_o),
		   //Slave signals
  			.ss_pad_o(s_if.ss), .sclk_pad_o(s_if.sclk), .mosi_pad_o(s_if.mosi), .miso_pad_i(s_if.miso)
		   );


initial
	begin
		`ifdef VCS
       		$fsdbDumpvars(0, top);
       		`endif
//Setting Interface

		  uvm_config_db #(virtual slave_if)::set(null,"*","slave",s_if);
		uvm_config_db #(virtual wishbone_if)::set(null,"*","wish",w_if);
		run_test();
	end
endmodule
