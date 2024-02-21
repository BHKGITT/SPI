///////////////////////////// SLAVE_SEQUENCE /////////////////////////////////
class slave_sequence extends uvm_sequence#(slave_txn);
	`uvm_object_utils(slave_sequence)
	
	extern function new(string name="slave_sequence");
endclass

function slave_sequence::new(string name="slave_sequence");
	super.new(name);
endfunction

///////////////////////////// SLAVE_SEQ-1 ///////////////////////////////////
class slave_seq1 extends slave_sequence;
	`uvm_object_utils(slave_seq1)

	extern function new(string name="slave_seq1");
	extern task body();
endclass

function slave_seq1::new(string name="slave_seq1");
	super.new(name);
endfunction

task slave_seq1::body();
	req=slave_txn::type_id::create("req"); //Creating instance for req

	start_item(req);
	assert(req.randomize() /*with {miso==23;}*/);
	finish_item(req);	
endtask
