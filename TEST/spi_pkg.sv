///////////////// SPI_PKG  /////////////
package spi_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	
	`include "master_txn.sv"
	`include "master_config.sv"
	`include "slave_config.sv"
	`include "env_config.sv"
	`include "master_driver.sv"
	`include "master_monitor.sv"
	`include "master_sequence.sv" //
	`include "master_sequencer.sv"
	`include "master_agent.sv"
	`include "master_agt_top.sv"
	
	`include "slave_txn.sv"
	`include "slave_driver.sv"
	`include "slave_monitor.sv"
	`include "slave_sequence.sv"
	`include "slave_sequencer.sv"
	`include "slave_agent.sv"
	`include "slave_agt_top.sv"
	`include "scoreboard.sv"

	`include "virtual_sequencer.sv"

	`include "virtual_sequence.sv"

	`include "spi_env.sv"
	`include "test.sv"	
endpackage
