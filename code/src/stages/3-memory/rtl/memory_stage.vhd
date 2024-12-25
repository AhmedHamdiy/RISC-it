LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory_stage IS
  PORT (
    -- Inputs
    clk : IN STD_LOGIC;
    alu_result : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    Rsrc1 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    stack_reg_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    flags_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
    pc : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
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
END memory_stage;

ARCHITECTURE memory_stage_arch OF memory_stage IS

  COMPONENT data_memory IS
    PORT (
      clk : IN STD_LOGIC;
      we : IN STD_LOGIC;
      re : IN STD_LOGIC;
      address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      write_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      read_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;
  COMPONENT stack_reg IS
    PORT (
      clk : IN STD_LOGIC;
      data_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      data_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;
  COMPONENT stack_selector_unit IS
    PORT (
      rti : IN STD_LOGIC;
      int : IN STD_LOGIC;
      stack_op : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      stack_sel : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
  END COMPONENT;
  COMPONENT exeception_unit IS
    PORT (
      PC_mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      stack_op : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      SP : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      PC_ex : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      mem_exception : IN STD_LOGIC;
      exception : OUT STD_LOGIC;
      exception_type : OUT STD_LOGIC;
      EPC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
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

  COMPONENT mux4to1_16bit IS
    PORT (
      d0, d1, d2, d3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      y : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;

  -- signals
  SIGNAL mem_read_enable : STD_LOGIC := '0';
  SIGNAL mem_write_enable : STD_LOGIC := '0';
  SIGNAL write_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL memory_address : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL stack_address : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL stack_sel : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL stack_updated : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0FFF";
  SIGNAL push_pc : STD_LOGIC := '0';
  SIGNAL write_data_sel : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL incremented_pc : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL EPC : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN
  mem_write_enable <= mem_write OR int_wb_in;
  mem_read_enable <= mem_read OR rti_wb_in;
  stack_updated <= SP - 1 WHEN stack_op = '11' ELSE
    SP + 1 WHEN stack_op = '10' ELSE
    SP;
  stack_address <= stack_updated WHEN stack_op(0) = '1' ELSE
    SP;
  memory_address <= alu_result WHEN stack_op(1) = '1' ELSE
    stack_address;
  push_pc <= call OR int_ex_in;
  write_data_sel <= {int_wb_in, push_pc};
  incremented_pc <= pc_ex + 1;
  --mux to decide the write data
  mux : mux4to1_16bit PORT MAP(
    d0 => Rsrc1,
    d1 => incremented_pc,
    d2 => flags_in,
    d3 => flags_in,
    sel => write_data_sel,
    y => write_data
  );

  mem : data_memory PORT MAP(
    clk => clk,
    we => mem_write_enable,
    re => mem_read_enable,
    address => memory_address,
    write_data => write_data,
    read_data => mem_data
  );

  st : stack_reg PORT MAP(
    clk => clk,
    data_in => stack_reg_in,
    data_out => SP
  );

  ssu : stack_selector_unit PORT MAP(
    rti => rti_wb_in,
    int => int_wb_in,
    stack_op => stack_op,
    stack_sel => stack_sel
  );

  excep_unit : exeception_unit PORT MAP(
    PC_mem => pc_mem,
    stack_op => stack_op,
    SP => stack_address,
    PC_ex => pc_ex,
    mem_exception => mem_exception,
    exception => exception,
    exception_type => exception_type,
    EPC => EPC
  );
  stack_reg_out <= stack_updated;
END memory_stage_arch;