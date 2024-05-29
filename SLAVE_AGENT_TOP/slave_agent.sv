//////////////////// SLAVE_AGENT ////////////////////
class slave_agent extends uvm_agent;
	`uvm_component_utils(slave_agent)
//Declare handle for slave_config
	slave_config  s_cfg;
//Declare handles for DRV,MON,SEQR
	slave_driver  	s_drv;
	slave_monitor	s_mon;
	slave_sequencer	s_seqr;

	extern function new(string name="slave_agent",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function slave_agent::new(string name="slave_agent",uvm_component parent);
	super.new(name,parent);
endfunction

function void slave_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Getting s_cfg[]
	if(!uvm_config_db#(slave_config)::get(this,"","slave",s_cfg)) // changed dynamic
		`uvm_fatal(get_type_name(),"s_cfg can't get Have U set it in slave_agt_top")	
	s_mon=slave_monitor::type_id::create("s_mon",this);
	if(s_cfg.is_active==UVM_ACTIVE)
		begin
			s_drv=slave_driver::type_id::create("s_drv",this);
			s_seqr=slave_sequencer::type_id::create("s_seqr",this);
		end
endfunction

function void slave_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(s_cfg.is_active==UVM_ACTIVE)
		begin
			s_drv.seq_item_port.connect(s_seqr.seq_item_export);
		end
endfunction
