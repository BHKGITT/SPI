//////////////////// SLAVE_AGT_TOP /////////////////
class slave_agt_top extends uvm_agent;
	`uvm_component_utils(slave_agt_top)

//Declare handle of env_config
	env_config   env_cfg;
//Declare slave_config handle
	slave_config   s_cfg;
//Declare handle for slave_agent
	slave_agent   s_agent[];
	extern function new(string name="slave_agt_top",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass

function slave_agt_top::new(string name="slave_agt_top",uvm_component parent);
	super.new(name,parent);
endfunction

function void slave_agt_top::build_phase(uvm_phase phase);
	super.build_phase(phase);
//Getting env_config
	if(!uvm_config_db#(env_config)::get(this,"","ENV_CFG",env_cfg))
		`uvm_fatal(get_type_name(),"env_cfg cant get Have U set it in TEST")
//Create instance for slave_agent
	s_agent=new[env_cfg.no_of_sagent];
	foreach(s_agent[i])
		begin
		s_agent[i]=slave_agent::type_id::create($sformatf("s_agent[%0d]",i),this);
//Set s_cfg[]
	uvm_config_db#(slave_config)::set(this,$sformatf("s_agent[%0d]*",i),"slave",env_cfg.s_cfg[i]);
		end
endfunction
