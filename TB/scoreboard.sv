////////////////////  SCOREBOARD  /////////////////
class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)
	env_config  env_cfg;
//Declare analysis_fifo handles
	uvm_tlm_analysis_fifo#(master_txn)   m_fifo[];
	uvm_tlm_analysis_fifo#(slave_txn)    s_fifo[];
//Declare ctrl as int type to get config from test 
	int ctrl;
//Declare local var for monitor how many times data verified
	int miso_Verified,miso_Failed,mosi_Verified,mosi_Failed;
//Declare local Var MOSI_H & MISO_H of bit type
	bit[127:0] MOSI_H;
	bit[127:0] MISO_H;
//Declare handles for get data from fifo's and store
	master_txn  mfifo_txn;
	slave_txn   sfifo_txn;
//Declare handles for coverage coverpoints
	master_txn   cov_data;
covergroup cg;
	CHAR_LEN:coverpoint cov_data.CTRL[6:0]{
						bins a1={[1:32]};
						bins a2={[33:64]};
						bins a3={[65:127]};
					      }
	RX_NEG:coverpoint cov_data.CTRL[9];
	TX_NEG:coverpoint cov_data.CTRL[10];
 	LSB:coverpoint cov_data.CTRL[11];
endgroup

	extern function new(string name="scoreboard",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task compare_data();
	extern function void report_phase(uvm_phase phase);
endclass

function scoreboard::new(string name="scoreboard",uvm_component parent);
	super.new(name,parent);
	cg=new();
endfunction

function void scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Getting  env_config
	if(!uvm_config_db#(env_config)::get(this,"","ENV_CFG",env_cfg))
		`uvm_fatal(get_type_name(),"env_cfg can't get Have U set it in TEST")
//Getting ctrl from test
	if(!uvm_config_db#(int)::get(this,"","CTRL",ctrl))
		`uvm_fatal(get_type_name(),"can't get ctrl,Have U set it in Test?")
//Create instances for fifos
	m_fifo=new[env_cfg.no_of_magent];
	foreach(m_fifo[i])
		m_fifo[i]=new($sformatf("m_fifo[%0d]",i),this);

	s_fifo=new[env_cfg.no_of_sagent];
	foreach(s_fifo[i])
		s_fifo[i]=new($sformatf("s_fifo[%0d]",i),this);
endfunction

task scoreboard::run_phase(uvm_phase phase);
	fork
		foreach(m_fifo[i])
			m_fifo[i].get(mfifo_txn);
		foreach(s_fifo[i])
			s_fifo[i].get(sfifo_txn);
	join
//Concatenate all registers & assign for comparing 128 bits
	MISO_H={mfifo_txn.TX0,mfifo_txn.TX1,mfifo_txn.TX2,mfifo_txn.TX3};
	MOSI_H={mfifo_txn.RX0,mfifo_txn.RX1,mfifo_txn.RX2,mfifo_txn.RX3};
//Calling compare_data task
	compare_data();
	cov_data = new mfifo_txn;
	cg.sample();
endtask

task scoreboard::compare_data();
	`uvm_info(get_type_name(),$sformatf("Monitored %s",mfifo_txn.sprint()),UVM_LOW)

	for(int i=0;i<ctrl[6:0];i++)
		if(MISO_H[i]==sfifo_txn.mosi[i])
			mosi_Verified++;
		else
			mosi_Failed++;  

	for(int i=0;i<ctrl[6:0];i++)
		if(MOSI_H[i] == sfifo_txn.miso[i])
			miso_Verified++;
		else
			miso_Failed++;

endtask

function void scoreboard::report_phase(uvm_phase phase);
	$display("=======================================================\n");
	$display("\t MOSI VERIFIED=%0d \n",mosi_Verified);
	$display("\t MOSI FAILED=%0d \n",mosi_Failed);
	$display("\t MISO VERIFIED=%0d\n",miso_Verified);
	$display("\t MISO FAILED=%0d\n",miso_Failed);
	$display("=======================================================");
endfunction 

