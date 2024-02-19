///////////////// MASTER_MONITOR //////////////
class master_monitor extends uvm_monitor;
	`uvm_component_utils(master_monitor)
//Declare analysis port handle
	uvm_analysis_port#(master_txn)  m_port;
//Declare master config handle
	master_config  m_cfg;
//Declare virtual interface handle
	virtual wishbone_if.MMON_MP vif;

		master_txn mtxn1;
	extern function new(string name="master_monitor",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass

function master_monitor::new(string name="master_monitor",uvm_component parent);
	super.new(name,parent);
//Create instance for analysis port
	m_port=new("m_port",this);
endfunction

function void master_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Getting m_cfg from master_agt_top
	if(!uvm_config_db#(master_config)::get(this,"","master",m_cfg))
		`uvm_fatal(get_type_name(),"m_cfg cant get Have U set it in master_agt_top")
endfunction

function void master_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif=m_cfg.vif;
endfunction

task master_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);
		mtxn1=master_txn::type_id::create("mtxn",this);
	forever
		begin
			collect_data();
		end
endtask

task master_monitor::collect_data();
	begin
		@(vif.master_mon_cb);
		while(vif.master_mon_cb.wb_ack_o != 1) //Checking condition until ack=1
		@(vif.master_mon_cb);
		mtxn1.wb_we_i  = vif.master_mon_cb.wb_we_i;
		mtxn1.wb_adr_i = vif.master_mon_cb.wb_adr_i;
//For TX0 & RX0 registers
		if(mtxn1.wb_we_i==1 && mtxn1.wb_adr_i == 5'h00)
			mtxn1.TX0 = vif.master_mon_cb.wb_dat_i;
		else if(mtxn1.wb_we_i==0 && mtxn1.wb_adr_i == 5'h00)
			mtxn1.RX0 = vif.master_mon_cb.wb_dat_o;

//For TX1 & RX1 registers
		if(mtxn1.wb_we_i==1 && mtxn1.wb_adr_i == 5'h04)
			mtxn1.TX1 = vif.master_mon_cb.wb_dat_i;
		else if(mtxn1.wb_we_i==0 && mtxn1.wb_adr_i == 5'h04)
			mtxn1.RX1 = vif.master_mon_cb.wb_dat_o;

//For TX2 & RX2 registers
		if(mtxn1.wb_we_i==1 && mtxn1.wb_adr_i == 5'h08)
			mtxn1.TX2 = vif.master_mon_cb.wb_dat_i;
		else if(mtxn1.wb_we_i==0 && mtxn1.wb_adr_i == 5'h08)
			mtxn1.RX2 = vif.master_mon_cb.wb_dat_o;

//For TX3 & RX3 registers
		if(mtxn1.wb_we_i==1 && mtxn1.wb_adr_i == 5'h0C)
			mtxn1.TX3 = vif.master_mon_cb.wb_dat_i;
		else if(mtxn1.wb_we_i==0 && mtxn1.wb_adr_i == 5'h0C)
			mtxn1.RX3 = vif.master_mon_cb.wb_dat_o;
//For Divider register		
		if(mtxn1.wb_we_i==1 && mtxn1.wb_adr_i == 5'h14)
			mtxn1.DIV = vif.master_mon_cb.wb_dat_i;
//For Slave-Select register
		if(mtxn1.wb_we_i==1 && mtxn1.wb_adr_i == 5'h18)
			mtxn1.SS = vif.master_mon_cb.wb_dat_i;
//For CTRL register
		if(mtxn1.wb_we_i==1 && mtxn1.wb_adr_i == 5'h10)
			mtxn1.CTRL = vif.master_mon_cb.wb_dat_i;
		`uvm_info(get_type_name(),$sformatf("Collected  master_seqs1 at MASTER_MON \n %s",mtxn1.sprint()),UVM_LOW)
//Write mtxn1 into scoreboard
		m_port.write(mtxn1);

	end	
endtask
