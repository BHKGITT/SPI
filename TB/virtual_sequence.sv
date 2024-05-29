////////////////// VIRTUAL_SEQUENCE ///////////////////
class virtual_sequence extends uvm_sequence#(uvm_sequence_item);
	`uvm_object_utils(virtual_sequence)
//Declare env_config handle
	env_config  env_cfg;
//Declare virtual_sequencer handle
	virtual_sequencer   v_seqrh;
//Declare master & slave seqr handle
	master_sequencer   m_seqrh[];
	slave_sequencer    s_seqrh[];
	
	extern function new(string name="virtual_sequence");
	extern task body();
endclass

function virtual_sequence::new(string name="virtual_sequence");
	super.new(name);
endfunction

task virtual_sequence::body();
//Getting env_config
	if(!uvm_config_db#(env_config)::get(null,get_full_name(),"ENV_CFG",env_cfg))
		`uvm_fatal(get_type_name(),"env_cfg can't get Have U set in TEST")
	
	if($cast(v_seqrh,m_sequencer))  //Checking compatability  (P=C or P!=C)
//Declaring size 
	m_seqrh=new[env_cfg.no_of_magent];
	s_seqrh=new[env_cfg.no_of_sagent];
	
//Pointing virtual_seqr of env
	foreach(m_seqrh[i]) 
		begin
			m_seqrh[i]=v_seqrh.m_seqrh[i];
		end
	foreach(s_seqrh[i])
		begin
			s_seqrh[i]=v_seqrh.s_seqrh[i];
		end
endtask


//////////////////////////// virtual_seq1 ///////////////////////////////////////////
class virtual_seq1 extends virtual_sequence;
	`uvm_object_utils(virtual_seq1)

//Declare master sequence handle 
	master_seq1    m_seq1; 
//Declare Slave sequence handle
	slave_seq1     s_seq1;

	extern function new(string name="virtual_seq1");
	extern task body();
endclass

function virtual_seq1::new(string name="virtual_seq1");
	super.new(name);
endfunction

task virtual_seq1::body();
	super.body();
//Creating instance for m_seq1 & s_seq1
	m_seq1=master_seq1::type_id::create("m_seq1");
	s_seq1=slave_seq1::type_id::create("s_seq1");
	fork
		begin
			foreach(m_seqrh[i])	
			m_seq1.start(m_seqrh[i]); //Starting m_seq1 on m_seqrh[i]
		end
		begin
			foreach(s_seqrh[i])
			s_seq1.start(s_seqrh[i]); //Starting s_seq1 on s_seqrh[i]
		end 
	join
	
endtask
