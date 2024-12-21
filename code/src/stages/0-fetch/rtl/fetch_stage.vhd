LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fetch_stage IS
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
END fetch_stage;

ARCHITECTURE fetch_stage_arch OF fetch_stage IS
  ---------MUX SIGNALS---------
  SIGNAL adder_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL branch_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ID_branch_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  SIGNAL ind_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ex_mem_int_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL exp_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ex_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL rst_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  ---------IM SIGNALS---------
  SIGNAL IM0 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL IM2 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL IM4 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL IM6 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL IM8 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  ---------OTHER SIGNALS---------
  SIGNAL one_cycle : STD_LOGIC := '0';
  SIGNAL read_address_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL instruction_sig : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL stop_till_rst : STD_LOGIC := '0';

  SIGNAL one : STD_LOGIC_VECTOR (15 DOWNTO 0) := (0 => '1', OTHERS => '0');
  SIGNAL pc_plus : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  ---------COMPONENTS---------
  COMPONENT pc_reg IS
    PORT (
      pc_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      clk, hlt, rst, one_cycle : IN STD_LOGIC;
      next_ins_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT instruction_memory IS
    PORT (
      clk : IN STD_LOGIC;
      address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      inst : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      empty_stack : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      invalid_mem_add : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      INT0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      INT2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT mux2to1_16bit IS
    PORT (
      d0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      d1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      sel : IN STD_LOGIC;
      y : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;
BEGIN
  ---------PORT MAPPING---------
  pc_plus <= read_address_in + one;
  one_cycle <= STALL OR RTI OR INT;
  pc_reg_inst : pc_reg PORT MAP(rst_mux_out, clk, HLT, RST, one_cycle, read_address_in);
  ins_mem_inst : instruction_memory PORT MAP(clk, read_address_in, instruction_sig, IM2, IM4, IM6, IM8);
  branching_mux : mux2to1_16bit PORT MAP(pc_plus, ID_branch_mux_out, BRANCH, branch_mux_out);
  index_mux : mux2to1_16bit PORT MAP(IM6, IM8, INDEX, ind_mux_out);
  ex_mem_int_mux : mux2to1_16bit PORT MAP(branch_mux_out, ind_mux_out, EX_MEM_INT, ex_mem_int_mux_out);
  exp_mux : mux2to1_16bit PORT MAP(IM2, IM4, EXP_TYPE, exp_mux_out);
  ex_mux : mux2to1_16bit PORT MAP(ex_mem_int_mux_out, exp_mux_out, EX, ex_mux_out);
  rst_mux : mux2to1_16bit PORT MAP(ex_mux_out, IM0, RST, rst_mux_out);

  PROCESS (clk)
  BEGIN
    IF (rising_edge(clk)) THEN
      pc <= read_address_in;
      flush <= BRANCH;
      instruction <= instruction_sig;
    END IF;
  END PROCESS;
END fetch_stage_arch;