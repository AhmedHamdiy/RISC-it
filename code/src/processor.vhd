LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY risc_processor IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    in_port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    out_port : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END risc_processor;

ARCHITECTURE risc_processor_arch OF risc_processor IS

  COMPONENT fetch_stage IS
    PORT (
      clk : IN STD_LOGIC;
      ---------MUX CONTROL SIGNALS---------
      HLT : IN STD_LOGIC;
      RTI : IN STD_LOGIC;
      INT : IN STD_LOGIC;
      STALL : IN STD_LOGIC;
      BRANCH : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      EXP_TYPE : IN STD_LOGIC;
      EX : IN STD_LOGIC;
      INDEX : IN STD_LOGIC;
      EX_MEM_INT : IN STD_LOGIC;
      ---------MUX INPUT SIGNALS---------
      JMP_inst : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      -------------------------------------
      instruction : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
      flush : OUT STD_LOGIC := '0';
      pc : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0')
    );
  END COMPONENT;

  COMPONENT decode_stage IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      inst : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      rti : IN STD_LOGIC;
      ret : IN STD_LOGIC;
      write_reg : IN STD_LOGIC;
      has_immediate : IN STD_LOGIC;
      data_to_write : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      PC_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      ID_EX_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      ID_EX_Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      ID_EX_Rsrc1_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      ID_EX_mem_read : IN STD_LOGIC;
      ID_EX_branch : IN STD_LOGIC;
      EX_MEM_branch : IN STD_LOGIC;
      ID_EX_stackop1 : IN STD_LOGIC;
      pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      Rsrc1, Rsrc2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      Rsrc1_add, Rsrc2_add : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      Rdst_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      imm : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      inst0 : OUT STD_LOGIC;
      hazard : OUT STD_LOGIC;
      stall : OUT STD_LOGIC;
      will_branch : OUT STD_LOGIC;
      jmp_add : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      control_signals : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT execute_stage IS
    PORT (

      -- Inputs
      clk : IN STD_LOGIC;
      src1_addr, src2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      prev1_addr, prev2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      Rsrc1, Rsrc2 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      mem_forwarded_Rsrc1, mem_forwarded_Rsrc2 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      alu_forwarded_Rsrc1, alu_forwarded_Rsrc2 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      Imm : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      flags_in : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      in_port : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      pc_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      Rdst_addr_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

      -- Control signals
      flag_restore : IN STD_LOGIC;
      alu_operation : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      has_immidiate : IN STD_LOGIC;
      store_op : IN STD_LOGIC;
      input_enable : IN STD_LOGIC;
      output_enable : IN STD_LOGIC;
      jmp_type : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      branch : IN STD_LOGIC;
      mem_read : IN STD_LOGIC;
      mem_write : IN STD_LOGIC;

      -- Outputs
      pc_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      Rdst_addr_out : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

      out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      will_jmp : OUT STD_LOGIC;
      mem_excep : OUT STD_LOGIC;
      flags_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      res : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    );
  END COMPONENT;

  COMPONENT memory_stage IS
    PORT (
      clk : IN STD_LOGIC
    );
  END COMPONENT;

  COMPONENT writeback_stage IS
    PORT (
      mem_to_reg : IN STD_LOGIC;
      mem_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      alu_result : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      final_result : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;

  -- control signals
  SIGNAL HLT, RTI, INT, STALL, BRANCH, EXP_TYPE, EX, INDEX, EX_MEM_INT : STD_LOGIC;

  -- other signals
  SIGNAL JMP_inst, instruction, pc : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL flush : STD_LOGIC;

  ---------STAGE REGISTERS---------
  SIGNAL FD_in, FD_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL DE_in, DE_out : STD_LOGIC_VECTOR (127 DOWNTO 0);
  SIGNAL EM_in, EM_out : STD_LOGIC_VECTOR (63 DOWNTO 0);
  SIGNAL MW_in, MW_out : STD_LOGIC_VECTOR (63 DOWNTO 0);

  SIGNAL FD_inst : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL FD_pc_in : STD_LOGIC_VECTOR (15 DOWNTO 0);

  SIGNAL DE_src1_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);
  SIGNAL DE_Rdst_addr_out : STD_LOGIC_VECTOR (2 DOWNTO 0);
  SIGNAL DE_Rsrc1 : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL DE_sig : STD_LOGIC_VECTOR (20 DOWNTO 0);
  SIGNAL DE_pc_in : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL DE_src2_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);
  SIGNAL DE_Rsrc1 : STD_LOGIC_VECTOR (15 DOWNTO 0);

  SIGNAL EM_sig : STD_LOGIC_VECTOR (6 DOWNTO 0);
  SIGNAL EM_Rsrc1 : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL EM_Res : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL EM_Rdest_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);
  SIGNAL EM_pc : STD_LOGIC_VECTOR (15 DOWNTO 0);

  SIGNAL MW_sig : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL MW_mem : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL MW_res : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL MW_Rdest_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);

BEGIN

  fetch : fetch_stage PORT MAP(
    clk => clk,
    HLT => HLT,
    RTI => RTI,
    INT => INT,
    STALL => STALL,
    BRANCH => BRANCH,
    RST => rst,
    EXP_TYPE => EXP_TYPE,
    EX => EX,
    INDEX => INDEX,
    EX_MEM_INT => EX_MEM_INT,
    JMP_inst => JMP_inst,
    instruction => instruction,
    flush => flush,
    pc => pc
  );

  decode : decode_stage PORT MAP(
    clk => clk,
    reset => rst,
    inst => instruction,
    rti => RTI,
    ret => EX_MEM_INT,
    write_reg => EXP_TYPE,
    has_immediate => EXP_TYPE,
    data_to_write => pc,
    WB_Rdst => pc,
    PC_in => pc,
    ID_EX_Rdst => pc,
    ID_EX_Rsrc1 => pc,
    ID_EX_Rsrc1_data => pc,
    ID_EX_mem_read => pc,
    ID_EX_branch => pc,
    EX_MEM_branch => pc,
    ID_EX_stackop1 => pc,
    pc_out => pc,
    Rsrc1 => pc,
    Rsrc2 => pc,
    Rsrc1_add => pc,
    Rsrc2_add => pc,
    Rdst_address => pc,
    imm => pc,
    inst0 => pc,
    hazard => pc,
    stall => pc,
    will_branch => pc,
    jmp_add => pc,
    control_signals => pc
  );

  execute : execute_stage PORT MAP(
    clk => clk,
    src1_addr => src1_addr,
    src2_addr => src2_addr,
    prev1_addr => prev1_addr,
    prev2_addr => prev2_addr,
    Rsrc1 => Rsrc1,
    Rsrc2 => Rsrc2,
    mem_forwarded_Rsrc1 => mem_forwarded_Rsrc1,
    mem_forwarded_Rsrc2 => mem_forwarded_Rsrc2,
    alu_forwarded_Rsrc1 => alu_forwarded_Rsrc1,
    alu_forwarded_Rsrc2 => alu_forwarded_Rsrc2,
    Imm => Imm,
    flags_in => flags_in,
    in_port => in_port,
    flag_restore => flag_restore,
    alu_operation => alu_operation,
    has_immidiate => has_immidiate,
    store_op => store_op,
    input_enable => input_enable,
    output_enable => output_enable,
    jmp_type => jmp_type,
    branch => branch,
    mem_read => mem_read,
    mem_write => mem_write,
    out_port => out_port,
    will_jmp => will_jmp,
    mem_excep => mem_excep,
    flags_out => flags_out,
    res => res
  );

  memory : memory_stage PORT MAP(
    clk => clk
  );

  writeback : writeback_stage PORT MAP(
    mem_to_reg => mem_to_reg,
    mem_data => mem_data,
    alu_result => alu_result,
    final_result => final_result
  );

  PROCESS (clk)
  BEGIN
    -- sycnronous code
  END PROCESS;

END ARCHITECTURE risc_processor_arch;