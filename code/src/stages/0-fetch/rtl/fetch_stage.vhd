LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fetch_stage IS
  PORT (
    clk : IN STD_LOGIC;
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
  SIGNAL RESET : STD_LOGIC := '1';
  SIGNAL EXP_TYPE : STD_LOGIC := '0';
  SIGNAL EXP : STD_LOGIC := '0';
  SIGNAL INDEX : STD_LOGIC := '0';
  SIGNAL EX_MEM_INT : STD_LOGIC := '0';
  ---------OTHER CONTROL SIGNALS---------
  SIGNAL PC_ENABLE : STD_LOGIC := '0';
  SIGNAL read_address_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL pc_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  SIGNAL one : STD_LOGIC_VECTOR (15 DOWNTO 0) := (0 => '1', OTHERS => '0');
  ---------MUX SIGNALS---------
  SIGNAL JMP_inst : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL adder_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL branch_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  SIGNAL ind_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ex_mem_int_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL exp_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ex_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL rst_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

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
  ------------------------------
  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      PC_ENABLE <= INT OR RTI OR STALL;
      IF (PC_ENABLE) THEN

      END IF;

    END IF;
  END PROCESS;
END fetch_stage_arch;