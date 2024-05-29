////////////////////////  ENV /////////////////////

class spi_env extends uvm_env;
	`uvm_component_utils(spi_env)
//Declare env_config handle
	env_config  env_cfg;
//Declare master & slave agent_top handles
	master_agt_top  m_agt_top;
	slave_agt_top   s_agt_top;
//Declare handle for scoreboard
	scoreboard  sb;
//Declare handle for virtual_seqr
	virtual_sequencer   env_v_seqr;

	extern function new(string name="spi_env",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function spi_env::new(string name="spi_env",uvm_component parent);
	super.new(name,parent);
endfunction

function void spi_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Get env_config
	if(!uvm_config_db#(env_config)::get(this,"","ENV_CFG",env_cfg))
		`uvm_fatal(get_type_name(),"env_cfg can't get Have U set it in TEST")
//Create instance for master & slave agent_top
	m_agt_top=master_agt_top::type_id::create("m_agt_top",this);
	s_agt_top=slave_agt_top::type_id::create("s_agt_top",this);
//Create instance for virtual_seqr handle
	env_v_seqr=virtual_sequencer::type_id::create("env_v_seqr",this);

	if(env_cfg.has_scoreboard)
//Create instance for scoreboard
		sb=scoreboard::type_id::create("sb",this);
endfunction

function void spi_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(env_cfg.has_virtual_sequencer)
		begin
			if(env_cfg.has_magent)
				foreach(env_v_seqr.m_seqrh[i])
				begin
//Pointing physical seqr 
					env_v_seqr.m_seqrh[i]=m_agt_top.m_agent[i].m_seqr;
				end
		end	
	if(env_cfg.has_virtual_sequencer)
		begin
			if(env_cfg.has_sagent)
				foreach(env_v_seqr.s_seqrh[i])
				begin
//Pointing physical seqr
					env_v_seqr.s_seqrh[i]=s_agt_top.s_agent[i].s_seqr;
				end
		end
	if(env_cfg.has_scoreboard)
		foreach(env_cfg.m_cfg[i])
//Connecting master_monitor with scoreboard
			begin
				m_agt_top.m_agent[i].m_mon.m_port.connect(sb.m_fifo[i].analysis_export);
			end
////////////////////////Scoreboard fifo connection need to write for slave side

	if(env_cfg.has_scoreboard)
		foreach(env_cfg.s_cfg[i])
//Connecting master_monitor with scoreboard
			begin
				s_agt_top.s_agent[i].s_mon.s_port.connect(sb.s_fifo[i].analysis_export);
			end
			
endfunction
