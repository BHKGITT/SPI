////////////////// SLAVE_DRIVER /////////////////

class slave_driver extends uvm_driver#(slave_txn);
	`uvm_component_utils(slave_driver)
//Declare virtual interface handle
	virtual slave_if.SDRV_MP  vif;
//Declare salve_config handle
	slave_config  s_cfg;
//Declare ctrl as int type to get config
	int ctrl;
	bit[6:0] ctrl_h;  //char_len

	extern function new(string name="slave_driver",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task slave_to_spi(slave_txn stxn);
endclass

function slave_driver::new(string name="slave_driver",uvm_component parent);
	super.new(name,parent);
endfunction

function void slave_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Getting s_cfg from slave_agt_top
	if(!uvm_config_db#(slave_config)::get(this,"","slave",s_cfg))
		`uvm_fatal(get_type_name(),"s_cfg cant get Have U set it in slave_agt_top")
//Getting ctrl from Test
	if(!uvm_config_db#(int)::get(this,"","CTRL",ctrl))
		`uvm_fatal(get_type_name(),"ctrl cant get Have U set it in Test")
endfunction

function void slave_driver::connect_phase(uvm_phase phase);
//	super.connect_phase(phase);
	vif=s_cfg.vif;
endfunction

task slave_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever
		begin
			seq_item_port.get_next_item(req);
			slave_to_spi(req);
			seq_item_port.item_done();				
		end
endtask

task slave_driver::slave_to_spi(slave_txn stxn);

	ctrl_h = ctrl[6:0];
	if(ctrl[11]==1) //Checking LSB==1
		begin
			if(ctrl[9]==1) //Checking Rx==1 (Drive at Falling edge)
				begin
					for(int i=0;i<ctrl_h;i++)
						begin
							@(negedge vif.slave_drv_cb.sclk);
							vif.slave_drv_cb.miso <= stxn.miso[i];
						end
				end
			else  //Drive at Rising edge
				begin
					for(int i=0;i<ctrl_h;i++)
						begin
							@(posedge vif.slave_drv_cb.sclk);
							vif.slave_drv_cb.miso <= stxn.miso[i];
						end
				end 
		end		
	else //MSB
		begin
			if(ctrl[9]==1)	//Checking Rx==1 (Drive at Falling edge)
				begin
					for(int i=ctrl_h;i>0;i--)
						begin
							@(negedge vif.slave_drv_cb.sclk);
							vif.slave_drv_cb.miso <= stxn.miso[i];
						end
				end
			else	 //Drive at Rising edge
				begin
					for(int i=ctrl_h;i>0;i--)
						begin
							@(posedge vif.slave_drv_cb.sclk)
							vif.slave_drv_cb.miso <= stxn.miso[i];
						end
				end
		end

	`uvm_info(get_type_name(),$sformatf("Driving seqs to DUV \n %s",stxn.sprint()),UVM_LOW)

@(vif.slave_drv_cb);
@(vif.slave_drv_cb);
@(vif.slave_drv_cb);
@(vif.slave_drv_cb);

endtask

