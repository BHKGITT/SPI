////////////////////  TEST  ///////////////////

class test extends uvm_test;
	`uvm_component_utils(test);
//Declare env_config handle
	env_config     env_cfg;
	master_config  m_cfg[];
	slave_config   s_cfg[];
//Declare spi_env handle
	spi_env     envh;
//Declare local properties
	bit has_magent=1;
	bit has_sagent=1;
	int no_of_magent=1;
	int no_of_sagent=1;
	bit has_scoreboard=1;
//Virtual_sequence_handle
	virtual_sequence  v_seqh;
	int ctrl; 

	extern function new(string name="test",uvm_component parent);
	extern function void config_spi();
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

function test::new(string name="test",uvm_component parent);
	super.new(name,parent);
endfunction

function void test::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Create instance for env_config 
	env_cfg=env_config::type_id::create("env_cfg");

	v_seqh=virtual_sequence::type_id::create("v_seqh");
	config_spi(); //calling function
//Create instance for spi_env class
	envh=spi_env::type_id::create("envh",this);

endfunction

function void test::config_spi();
	if(has_magent)
		begin
			m_cfg=new[no_of_magent];
			env_cfg.m_cfg=new[no_of_magent];
			foreach(m_cfg[i])
				begin
				m_cfg[i]=master_config::type_id::create($sformatf("m_cfg[[%0d]",i));
        //Getting wishbone_if
				if(!uvm_config_db#(virtual wishbone_if)::get(this,"","wish",m_cfg[i].vif))
					`uvm_fatal(get_type_name(),"wb_if cant get Have U set it in TOP?")
				if(m_cfg[i].is_active==UVM_ACTIVE)
					env_cfg.m_cfg[i]=m_cfg[i];//Pointing env_cfg.m_cfg[] with local m_cfg[]
				end
		end  
	
	if(has_sagent)
		begin
			s_cfg=new[no_of_sagent];
			env_cfg.s_cfg=new[no_of_sagent];
			foreach(s_cfg[i])
				begin
				s_cfg[i]=slave_config::type_id::create($sformatf("s_cfg[%0d]",i));
	//Getting slave_if
				if(!uvm_config_db#(virtual slave_if)::get(this,"","slave",s_cfg[i].vif))
					`uvm_fatal(get_type_name(),"vif can't get Have U set it in TOP?")
				if(s_cfg[i].is_active==UVM_ACTIVE)
					env_cfg.s_cfg[i]=s_cfg[i];//pointing env_cfg.s_cfg[] with local s_cfg[] 
				end
		end
//Set env_config	
	uvm_config_db#(env_config)::set(this,"*","ENV_CFG",env_cfg);
	
	env_cfg.has_magent=has_magent;
	env_cfg.has_sagent=has_sagent;
	env_cfg.no_of_magent=no_of_magent;
	env_cfg.no_of_sagent=no_of_sagent;
	env_cfg.has_scoreboard=has_scoreboard;
endfunction


function void test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
	uvm_top.print_topology();
endfunction

//////////////////////////////////// TEST-1 //////////////////////////////////////
class test_1 extends test;
	`uvm_component_utils(test_1)
//Declare virtual_seq1 handle
	virtual_seq1	v_seqh1;

	extern function new(string name="test_1",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function test_1::new(string name="test_1",uvm_component parent);
	super.new(name,parent);
endfunction

function void test_1::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Configuring CTRL register
	ctrl[6:0] = 7'd32;  //Character_length
	ctrl[7]   =  0;  //Reseved
	ctrl[8]   =  1;  //Go busy
	ctrl[9]	  =  1;  //Rx_neg
	ctrl[10]  =  0;  //Tx_neg
	ctrl[11]  =  1;  //LSB
	ctrl[12]  =  1;  //Interrupt Enable
	ctrl[13]  =  1;  //Auto slave select
	ctrl[31:14]= 0;  //Reserved

//Setting ctrl register
	uvm_config_db#(int)::set(this,"*","CTRL",ctrl);	

endfunction

task test_1::run_phase(uvm_phase phase);
	super.run_phase(phase);
	begin
		v_seqh1=virtual_seq1::type_id::create("v_seqh1"); //Creating instance for v_seqh1
		phase.raise_objection(this);
		v_seqh1.start(envh.env_v_seqr); // Starting v_seqh1 on env_v_seqr
		#100;
		phase.drop_objection(this);
	end
endtask
//////////////////////////////////// TEST-2 //////////////////////////////////////
class test_2 extends test;
	`uvm_component_utils(test_2)
//Declare virtual_seq1 handle
	virtual_seq1	v_seqh1;		
	extern function new(string name="test_2",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function test_2::new(string name="test_2",uvm_component parent);
	super.new(name,parent);
endfunction

function void test_2::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Configuring CTRL register
	ctrl[6:0] = 7'd64;  //Character_length
	ctrl[7]   =  0;  //Reseved
	ctrl[8]   =  1;  //Go busy
	ctrl[9]	  =  1;  //Rx_neg
	ctrl[10]  =  0;  //Tx_neg
	ctrl[11]  =  1;  //LSB
	ctrl[12]  =  1;  //Interrupt Enable
	ctrl[13]  =  1;  //Auto slave select
	ctrl[31:14]= 0;  //Reserved

//Setting ctrl register
	uvm_config_db#(int)::set(this,"*","CTRL",ctrl);	
endfunction

task test_2::run_phase(uvm_phase phase);
	super.run_phase(phase);
	begin
		v_seqh1=virtual_seq1::type_id::create("v_seqh1"); //Creating instance for v_seqh1
		phase.raise_objection(this);
		v_seqh1.start(envh.env_v_seqr); // Starting v_seqh1 on env_v_seqr
		#100;
		phase.drop_objection(this);
	end
endtask

//////////////////////////////////// TEST-3 //////////////////////////////////////
class test_3 extends test;
	`uvm_component_utils(test_3)
//Declare virtual_seq1 handle
	virtual_seq1	v_seqh1;		
//	int ctrl;
	extern function new(string name="test_3",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function test_3::new(string name="test_3",uvm_component parent);
	super.new(name,parent);
endfunction

function void test_3::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Configuring CTRL register
	ctrl[6:0] = 7'd127;  //Character_length
	ctrl[7]   =  0;  //Reseved
	ctrl[8]   =  1;  //Go busy
	ctrl[9]	  =  1;  //Rx_neg
	ctrl[10]  =  0;  //Tx_neg
	ctrl[11]  =  1;  //LSB
	ctrl[12]  =  1;  //Interrupt Enable
	ctrl[13]  =  1;  //Auto slave select
	ctrl[31:14]= 0;  //Reserved

//Setting ctrl register
	uvm_config_db#(int)::set(this,"*","CTRL",ctrl);	
endfunction

task test_3::run_phase(uvm_phase phase);
	super.run_phase(phase);
	begin
		v_seqh1=virtual_seq1::type_id::create("v_seqh1"); //Creating instance for v_seqh1
		phase.raise_objection(this);
		v_seqh1.start(envh.env_v_seqr); // Starting v_seqh1 on env_v_seqr
		#100;
		phase.drop_objection(this);
	end
endtask

