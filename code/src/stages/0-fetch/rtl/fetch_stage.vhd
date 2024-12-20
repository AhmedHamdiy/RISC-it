LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fetch_stage IS
  PORT (
    clk : IN STD_LOGIC;
    instruction : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
  );
END fetch_stage;

ARCHITECTURE fetch_stage_arch OF fetch_stage IS
BEGIN
  ---------MUX CONTROL SIGNALS---------
  SIGNAL HLT : STD_LOGIC := '0';
  SIGNAL RTI : STD_LOGIC := '0';
  SIGNAL INT : STD_LOGIC := '0';
  SIGNAL STALL : STD_LOGIC := '0';
  SIGNAL BRANCH : STD_LOGIC := '0';
  SIGNAL RST : STD_LOGIC := '1';
  SIGNAL EXP_TYPE : STD_LOGIC := '0';
  SIGNAL EXP : STD_LOGIC := '0';
  SIGNAL INDEX : STD_LOGIC := '0';
  SIGNAL EX_MEM_INT : STD_LOGIC := '0';
  ---------MUX SIGNALS---------
  SIGNAL JMP_inst : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
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
  SIGNAL stop_till_rst : STD_LOGIC := '0';

  SIGNAL one : STD_LOGIC_VECTOR (15 DOWNTO 0) := (0 => '1', OTHERS => '0');
  SIGNAL pc_plus : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  TYPE saved_addresses_array IS ARRAY (9 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL saved_addresses : saved_addresses_array := (OTHERS => (OTHERS => '0'));

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
      saved_addresses : OUT ARRAY(9 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    );
  END COMPONENT instruction_memory;

  COMPONENT mux2to1_16bit IS
    PORT (
      d0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      d1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      sel : IN STD_LOGIC;
      y : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;
  ---------PORT MAPPING---------
  one_cycle <= STALL OR RTI OR INT;
  -- pc_reg_inst : pc_reg PORT MAP(rst_mux_out, clk, HLT, RST, one_cycle, read_address_in); 
  -- ins_mem_inst : instruction_memory PORT MAP(clk, read_address_in, instruction, saved_addresses);
  pc_plus <= read_address_in + one;
  branching_mux : mux2to1_16bit PORT MAP(ID_branch_mux_out, pc_plus, BRANCH, branch_mux_out);
  index_mux : mux2to1_16bit PORT MAP(IM6, IM8, INDEX, ind_mux_out);
  ex_mem_int_mux : mux2to1_16bit PORT MAP(branch_mux_out, ind_mux_out, EX_MEM_INT, ex_mem_int_mux_out);
  exp_mux : mux2to1_16bit PORT MAP(IM2, IM4, EXP_TYPE, exp_mux_out);
  ex_mux : mux2to1_16bit PORT MAP(ex_mem_int_mux_out, exp_mux_out, EXP, ex_mux_out);
  rst_mux : mux2to1_16bit PORT MAP(ex_mux_out, IM0, RST, rst_mux_out);
  ------------------------------
  PROCESS (clk)
  BEGIN
    IF (RISING_EDGE(clk)) THEN
      IF (RST = '1') THEN
        stop_till_rst <= '0';
        read_address_in <= (OTHERS => '0');
      ELSIF (stop_till_rst = '0') THEN
        IF (one_cycle = '0' AND HLT = '0') THEN
          read_address_in <= rst_mux_out;
        ELSIF HLT = '1' THEN
          stop_till_rst <= '1';
        END IF;
      END IF;
    END IF;
  END PROCESS;
END fetch_stage_arch;