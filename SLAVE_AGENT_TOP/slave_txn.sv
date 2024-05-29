//////////////////// SLAVE_TXN ///////////////////
class slave_txn extends uvm_sequence_item;
	`uvm_object_utils(slave_txn)
	
	     bit[127:0]  mosi;
	rand bit[127:0]  miso;

	extern function new(string name="slave_txn");
	extern function void do_print(uvm_printer printer);	
endclass

function slave_txn::new(string name="slave_txn");
	super.new(name);
endfunction

function void slave_txn::do_print(uvm_printer printer);
	printer.print_field("mosi",this.mosi,128,UVM_BIN);
	printer.print_field("miso",this.miso,128,UVM_BIN);
endfunction
