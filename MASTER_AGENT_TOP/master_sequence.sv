///////////////////////////// MASTER_SEQUENCE ////////////////////////////
class master_sequence extends uvm_sequence#(master_txn);
	`uvm_object_utils(master_sequence)
	
	function new(string name="master_sequence");
		super.new(name);
	endfunction
endclass

//////////////////////// MASTER_SEQUENCE-1 ///////////////////////////////
class master_seq1 extends master_sequence;
	`uvm_object_utils(master_seq1)

//Declare ctrl register as int type for getting config
	int ctrl;

	extern function new(string name="master_seq1");
	extern task body();
endclass

function master_seq1::new(string name="master_seq1");
	super.new(name);
endfunction

task master_seq1::body();
//Getting config for ctrl register
	if(!uvm_config_db#(int)::get(null,get_full_name(),"CTRL",ctrl))
		`uvm_fatal(get_type_name(),"ctrl can't get Have U set it in Test")
//	int ctrl_h=ctrl[6:0];
	req=master_txn::type_id::create("req");
//For TX0 register
	start_item(req);
	assert(req.randomize() with {wb_adr_i==5'h00 ; wb_we_i==1'b1 ; wb_dat_i==1000;});
	finish_item(req);
//For TX1 register
	start_item(req);
	assert(req.randomize() with {wb_adr_i==5'h04 ; wb_we_i==1'b1 ; wb_dat_i==1000;});
	finish_item(req);
//For TX2 register
	start_item(req);
	assert(req.randomize() with {wb_adr_i==5'h08 ; wb_we_i==1'b1 ; wb_dat_i==1000;});
	finish_item(req);
//For TX3 register
	start_item(req);
	assert(req.randomize() with {wb_adr_i==5'h0C ; wb_we_i==1'b1 ; wb_dat_i==1000;});
	finish_item(req);
//For RX0 register
	start_item(req);
	assert(req.randomize() with {wb_adr_i==5'h00 ; wb_we_i==1'b0 ;});
	finish_item(req);
//For RX1 register
	start_item(req);
	assert(req.randomize() with{wb_adr_i==5'h04 ; wb_we_i==1'b0 ;});
	finish_item(req);
//For RX2 register
	start_item(req);
	assert(req.randomize() with{wb_adr_i==5'h08 ; wb_we_i==1'b0 ;});
	finish_item(req);
//For RX3 register
	start_item(req);
	assert(req.randomize() with{wb_adr_i==5'h0C ; wb_we_i==1'b0 ;});
	finish_item(req);
//For CTRL register
//	int ctrl_h=ctrl[6:0];

	start_item(req);
	assert(req.randomize() with{wb_adr_i==5'h10 ; wb_we_i==1'b1 ; wb_dat_i==ctrl[6:0];});
	finish_item(req);
//For Divider register
	start_item(req);
	assert(req.randomize() with{wb_adr_i==5'h14 ; wb_we_i==1'b1 ; wb_dat_i[15:0]==16'b0000_0010; wb_dat_i[31:16]==16'b0000_0000;});
	finish_item(req);
//For SS register
	start_item(req);
	assert(req.randomize() with{wb_adr_i==5'h18 ; wb_we_i==1'b1 ; wb_dat_i[7:0]==8'b0000_0001; wb_dat_i[31:8]=='b0;});
	finish_item(req);

//	`uvm_info(get_type_name(),$sformatf("Generated  seqs at MASTER \n %s",req.sprint()),UVM_LOW)

endtask


