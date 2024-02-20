///////////////// SLAVE_MONITOR ///////////////
class slave_monitor extends uvm_monitor;
	`uvm_component_utils(slave_monitor)
//Declare analysis port handle
	uvm_analysis_port#(slave_txn)  s_port;
//Declare virtual interface handle
	virtual slave_if.SMON_MP vif;
//Declare slave config handle
	slave_config s_cfg;
//Declare ctrl as int type to get config 
	int ctrl;
	bit[6:0] ctrl_h;
//Declare slave_txn handle for collect seqs
	slave_txn  stxn1;
	extern function new(string name="slave_monitor",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass

function slave_monitor::new(string name="slave_monitor",uvm_component parent);
	super.new(name,parent);
//Create instance for s_port
	s_port=new("s_port",this);
endfunction

function void slave_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Getting s_cfg from slave_agt_top
	if(!uvm_config_db#(slave_config)::get(this,"","slave",s_cfg))
		`uvm_fatal(get_type_name(),"s_cfg can't get Have U set it in slave_agt_top")
//Getting ctrl from Test
	if(!uvm_config_db#(int)::get(this,"","CTRL",ctrl))
		`uvm_fatal(get_type_name(),"ctrl can't get Have U set it in Test")
endfunction

function void slave_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif=s_cfg.vif;
endfunction

task slave_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);
	stxn1=slave_txn::type_id::create("stxn1",this);
	forever
		begin
			collect_data();
		end	
endtask

task slave_monitor::collect_data();
	@(vif.slave_mon_cb);
	@(vif.slave_mon_cb);

	ctrl_h = ctrl[6:0];
	if(ctrl[11]==1) //Checking LSB==1
		begin	
			if(ctrl[9]==1) //Checking Rx==1 (Sampling at Rising edge)
				begin
					for(int i=0;i<ctrl_h;i++)
                                     		begin
							@(posedge vif.slave_mon_cb.sclk);
							stxn1.miso[i] = vif.slave_mon_cb.miso;
							stxn1.mosi[i] = vif.slave_mon_cb.mosi;
                                    		 end 
				end
			else  //Sampling at Falling edge
				begin
					for(int i=0;i<ctrl_h;i++)
                                       		 begin
							@(negedge vif.slave_mon_cb.sclk);
							stxn1.miso[i] = vif.slave_mon_cb.miso;
							stxn1.mosi[i] = vif.slave_mon_cb.mosi;
                                       		 end
				end 
		end	
	else //MSB
		begin
			if(ctrl[9]==1)	//Checking Rx==1 (Sampling at Falling edge)
				begin
					for(int i=ctrl_h;i>0;i--)
                                      		begin
							@(negedge vif.slave_mon_cb.sclk);
							stxn1.miso[i] = vif.slave_mon_cb.miso;
							stxn1.mosi[i] = vif.slave_mon_cb.mosi ;
                                     		 end
				end
			else	 //Sampling at Rising edge
				begin
					for(int i=ctrl_h;i>0;i--)
                                  		 begin
							@(posedge vif.slave_mon_cb.sclk)
							stxn1.miso[i] = vif.slave_mon_cb.miso;
							stxn1.mosi[i] = vif.slave_mon_cb.mosi ;
                                  		 end
				end
		end
	`uvm_info(get_type_name(),$sformatf("Sampling seqs from DUV \n %s",stxn1.sprint()),UVM_LOW)

	s_port.write(stxn1);
endtask
