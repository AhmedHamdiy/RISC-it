LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY risc_processor IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    input_port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    output_port : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
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
      MEM_WB_rti : IN STD_LOGIC;
      ID_EX_rti : IN STD_LOGIC;
      ret : IN STD_LOGIC;
      write_reg : IN STD_LOGIC;
      has_immediate : IN STD_LOGIC;
      data_to_write : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      PC_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      ID_EX_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
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
      control_signals : OUT STD_LOGIC_VECTOR(20 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT execute_stage IS
    PORT (
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

      control_signals : IN STD_LOGIC_VECTOR (20 DOWNTO 0);

      pc_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      Rdst_addr_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);

      out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      will_jmp : OUT STD_LOGIC;
      mem_excep : OUT STD_LOGIC;
      flags_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      res : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT memory_stage IS
    PORT (
      -- Inputs
      clk : IN STD_LOGIC;
      alu_result : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      Rsrc1 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      stack_reg_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      flags_in : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      pc_mem, pc_ex : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      rdst_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      mem_exception : IN STD_LOGIC;

      -- Control signals
      stack_op : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      int_ex_in : IN STD_LOGIC;
      int_wb_in : IN STD_LOGIC;
      call : IN STD_LOGIC;
      rti_ex_in : IN STD_LOGIC;
      rti_wb_in : IN STD_LOGIC;
      mem_read : IN STD_LOGIC;
      mem_write : IN STD_LOGIC;

      -- Outputs
      mem_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      stack_reg_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      exception : OUT STD_LOGIC;
      exception_type : OUT STD_LOGIC
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

  ---------STAGE REGISTERS---------
  SIGNAL FD_in, FD_out : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL DE_in, DE_out : STD_LOGIC_VECTOR (127 DOWNTO 0) := (OTHERS => '0');
  SIGNAL EM_in, EM_out : STD_LOGIC_VECTOR (127 DOWNTO 0) := (OTHERS => '0');
  SIGNAL MW_in, MW_out : STD_LOGIC_VECTOR (63 DOWNTO 0) := (OTHERS => '0');
  ---------REGISTERS OUTPUTS---------
  SIGNAL FD_inst : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL FD_pc_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  SIGNAL DE_src1_addr : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL DE_Rdst_addr_out : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL DE_Rsrc1 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL DE_sig : STD_LOGIC_VECTOR (20 DOWNTO 0) := (OTHERS => '0');
  SIGNAL DE_pc_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL DE_src2_addr : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL DE_Rsrc2 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  SIGNAL EM_sig : STD_LOGIC_VECTOR (10 DOWNTO 0) := (OTHERS => '0');
  SIGNAL EM_Rsrc1 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL EM_Res : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL EM_Rdest_addr : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL EM_pc : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL EM_flags : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');

  SIGNAL MW_sig : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL MW_mem : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL MW_res : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL MW_Rdest_addr : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL MW_flags : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL MW_stack_reg : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  ---------SIGNALS ORDER-------------
  -- DE_sig :
  -- reg_write => control_unit_out(0),
  -- mem_to_reg => control_unit_out(1),
  -- interrupt => control_unit_out(2),
  -- rti => control_unit_out(3),
  -- mem_write => control_unit_out(4),
  -- mem_read => control_unit_out(5),
  -- stack_operation => control_unit_out(7 DOWNTO 6),
  -- branch => control_unit_out(8),
  -- call => control_unit_out(9),
  -- ret => control_unit_out(10),
  -- in_enable => control_unit_out(11),
  -- out_enable => control_unit_out(12),
  -- alu_operation => control_unit_out(15 DOWNTO 13),
  -- is_immediate => control_unit_out(16),
  -- jump_type => control_unit_out(18 DOWNTO 17),
  -- freeze => control_unit_out(19),
  -- store_op => control_unit_out(20)

  -- EM_sig :
  -- reg_write => control_unit_out(0),
  -- mem_to_reg => control_unit_out(1),
  -- interrupt => control_unit_out(2),
  -- rti => control_unit_out(3),
  -- mem_write => control_unit_out(4),
  -- mem_read => control_unit_out(5),
  -- stack_operation => control_unit_out(7 DOWNTO 6),
  -- branch => control_unit_out(8),
  -- call => control_unit_out(9),
  -- ret => control_unit_out(10)

  -- MW_sig :
  -- reg_write => control_unit_out(0),
  -- mem_to_reg => control_unit_out(1),
  -- interrupt => control_unit_out(2),
  -- rti => control_unit_out(3)
  ---------REGISTERS INPUTS---------
  SIGNAL pc_FD, instruction : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL flush, flush_branch, flush_hazard : STD_LOGIC := '0';

  SIGNAL pc_DE : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL Rsrc1_DE, Rsrc2_DE : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL Rsrc1_addr_DE, Rsrc2_addr_DE, Rdest_addr_DE : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL control_signals_DE : STD_LOGIC_VECTOR(20 DOWNTO 0) := (OTHERS => '0');

  SIGNAL pc_EM : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL Rdest_addr_EM : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL branch_EM : STD_LOGIC := '0';
  SIGNAL res_EM : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL flags_EM, flags_MW : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');

  SIGNAL mem_MW, stack_reg_MW : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

  ---------OTHER SIGNALS---------
  SIGNAL imm_value : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL jmp_add : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL final_result : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL int_index, stall, branch, mem_excep, excep, excep_type : STD_LOGIC := '0';

BEGIN

  fetch : fetch_stage PORT MAP(
    clk => clk,
    HLT => DE_sig(19),
    RTI => DE_sig(3),
    INT => DE_sig(2),
    STALL => stall,
    BRANCH => branch,
    RST => rst,
    EXP_TYPE => excep_type,
    EX => excep,
    INDEX => int_index,
    EX_MEM_INT => EM_sig(2),
    JMP_inst => jmp_add,
    instruction => instruction,
    flush => flush_branch,
    pc => pc_FD
  );

  decode : decode_stage PORT MAP(
    clk => clk,
    reset => rst,
    inst => FD_inst,
    MEM_WB_rti => MW_sig(3),
    ID_EX_rti => DE_sig(3),
    ret => DE_sig(10),
    write_reg => MW_sig(0),
    has_immediate => DE_sig(16),
    data_to_write => final_result,
    WB_Rdst => MW_Rdest_addr,
    pc_in => DE_pc_in,
    ID_EX_Rdst => DE_Rdst_addr_out,
    ID_EX_Rsrc1_data => DE_Rsrc1,
    ID_EX_mem_read => DE_sig(5),
    ID_EX_branch => DE_sig(8),
    EX_MEM_branch => EM_sig(8),
    ID_EX_stackop1 => DE_sig(7),
    pc_out => pc_DE,
    Rsrc1 => Rsrc1_DE,
    Rsrc2 => Rsrc2_DE,
    Rsrc1_add => Rsrc1_addr_DE,
    Rsrc2_add => Rsrc2_addr_DE,
    Rdst_address => Rdest_addr_DE,
    imm => imm_value,
    inst0 => int_index,
    hazard => flush_hazard,
    stall => stall,
    will_branch => branch,
    jmp_add => jmp_add,
    control_signals => control_signals_DE
  );

  execute : execute_stage PORT MAP(
    clk => clk,
    src1_addr => DE_src1_addr,
    src2_addr => DE_src2_addr,
    prev1_addr => EM_Rdest_addr,
    prev2_addr => MW_Rdest_addr,
    Rsrc1 => DE_Rsrc1,
    Rsrc2 => DE_Rsrc2,
    mem_forwarded_Rsrc1 => MW_res,
    mem_forwarded_Rsrc2 => MW_res,
    alu_forwarded_Rsrc1 => EM_Res,
    alu_forwarded_Rsrc2 => EM_Res,
    Imm => imm_value,
    flags_in => final_result(3 DOWNTO 0),
    in_port => input_port,
    pc_in => DE_pc_in,
    Rdst_addr_in => DE_Rdst_addr_out,
    control_signals => DE_sig,
    pc_out => pc_EM,
    Rdst_addr_out => Rdest_addr_EM,
    out_port => output_port,
    will_jmp => branch_EM,
    mem_excep => mem_excep,
    flags_out => flags_EM,
    res => res_EM
  );

  memory : memory_stage PORT MAP(
    clk => clk,
    alu_result => EM_Res,
    Rsrc1 => EM_Rsrc1,
    stack_reg_in => MW_stack_reg,
    flags_in => flags_EM,
    pc_mem => pc_EM,
    pc_ex => pc_DE,
    rdst_addr => EM_Rdest_addr,
    mem_exception => mem_excep,
    stack_op => EM_sig(7 DOWNTO 6),
    int_ex_in => EM_sig(2),
    int_wb_in => MW_sig(2),
    call => EM_sig(9),
    rti_ex_in => EM_sig(3),
    rti_wb_in => MW_sig(3),
    mem_read => EM_sig(5),
    mem_write => EM_sig(4),
    mem_data => mem_MW,
    stack_reg_out => stack_reg_MW,
    exception => excep,
    exception_type => excep_type
  );

  writeback : writeback_stage PORT MAP(
    mem_to_reg => MW_sig(1),
    mem_data => MW_mem,
    alu_result => MW_res,
    final_result => final_result
  );

  flush <= flush_branch OR flush_hazard;

  PROCESS (clk)
  BEGIN
    IF (FALLING_EDGE(clk)) THEN

      FD_in(15 DOWNTO 0) <= pc_FD;
      FD_in(31 DOWNTO 16) <= instruction;

      IF (flush = '1') THEN
        FD_in <= (OTHERS => '0');
        FD_out <= (OTHERS => '0');
      END IF;

      DE_in(2 DOWNTO 0) <= Rsrc1_addr_DE;
      DE_in(5 DOWNTO 3) <= Rdest_addr_DE;
      DE_in(21 DOWNTO 6) <= Rsrc1_DE;
      DE_in(42 DOWNTO 22) <= control_signals_DE;
      DE_in(58 DOWNTO 43) <= pc_DE;
      DE_in(61 DOWNTO 59) <= Rsrc2_addr_DE;
      DE_in(77 DOWNTO 62) <= Rsrc2_DE;

      EM_in(10 DOWNTO 0) <= DE_sig(10 DOWNTO 0);
      EM_in(26 DOWNTO 11) <= DE_Rsrc1;
      EM_in(42 DOWNTO 27) <= res_EM;
      EM_in(45 DOWNTO 43) <= Rdest_addr_EM;
      EM_in(61 DOWNTO 46) <= pc_EM;
      EM_in(65 DOWNTO 62) <= flags_EM;

      MW_in(3 DOWNTO 0) <= EM_sig(3 DOWNTO 0);
      MW_in(19 DOWNTO 4) <= mem_MW;
      MW_in(35 DOWNTO 20) <= EM_Res;
      MW_in(38 DOWNTO 36) <= EM_Rdest_addr;
      MW_in(54 DOWNTO 39) <= stack_reg_MW;
      MW_in(58 DOWNTO 55) <= flags_MW;
    END IF;

    IF (RISING_EDGE(clk)) THEN
      FD_out <= FD_in;
      DE_out <= DE_in;
      EM_out <= EM_in;
      MW_out <= MW_in;

    END IF;
  END PROCESS;

END ARCHITECTURE risc_processor_arch;