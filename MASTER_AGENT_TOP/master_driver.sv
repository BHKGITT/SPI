//////////////// MASTER_DRIVER //////////////
class master_driver extends uvm_driver#(master_txn);
	`uvm_component_utils(master_driver)
//Declare virtual interface handle
	virtual wishbone_if.MDRV_MP  vif;
//Declare master config handle 
	master_config  m_cfg;

	extern function new(string name="master_driver",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task master_to_spi(master_txn mtxn);
endclass

function master_driver::new(string name="master_driver",uvm_component parent);
	super.new(name,parent);
endfunction

function void master_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Getting m_cfg from master_agt_top
	if(!uvm_config_db#(master_config)::get(this,"","master",m_cfg))
		`uvm_fatal(get_type_name(),"m_cfg cant get Have U set it in master_agt_top")
endfunction

function void master_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif=m_cfg.vif;
endfunction

task master_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);
	@(vif.master_drv_cb);
	vif.master_drv_cb.wb_rst_i <= 1'b1;
	@(vif.master_drv_cb);
	vif.master_drv_cb.wb_rst_i <= 1'b0;
	forever
		begin
			seq_item_port.get_next_item(req);
			master_to_spi(req);
			seq_item_port.item_done();
		end	
endtask

task master_driver::master_to_spi(master_txn  mtxn);  

//	`uvm_info(get_type_name(),$sformatf("Driving seqs to DUV \n %s",mtxn.sprint()),UVM_LOW)
	@(vif.master_drv_cb);
	vif.master_drv_cb.wb_we_i  <= mtxn.wb_we_i;
	vif.master_drv_cb.wb_adr_i <= mtxn.wb_adr_i;
	vif.master_drv_cb.wb_dat_i <= mtxn.wb_dat_i;
	vif.master_drv_cb.wb_stb_i <= 1'b1;
	vif.master_drv_cb.wb_cyc_i <= 1'b1;
	vif.master_drv_cb.wb_sel_i <= 4'b1111; //Design supports 32 bit data transfer at a time so,all bits 1111
	while(vif.master_drv_cb.wb_ack_o != 1) //Checking condition until ack=1
	@(vif.master_drv_cb);
	vif.master_drv_cb.wb_stb_i <= 1'b0;
	vif.master_drv_cb.wb_cyc_i <= 1'b0;
	@(vif.master_drv_cb);	
//	@(vif.master_drv_cb);
	//@(vif.master_drv_cb);
	`uvm_info(get_type_name(),$sformatf("Driving seqs to DUV \n %s",mtxn.sprint()),UVM_LOW)
endtask

