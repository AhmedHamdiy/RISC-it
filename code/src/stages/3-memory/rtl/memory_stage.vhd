LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY memory_stage IS
    PORT (
      -- Inputs
      clk : IN STD_LOGIC;
      alu_result: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      Rsrc1 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      stack_reg_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      flags_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      pc  : IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
      rdst_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      mem_exception : IN STD_LOGIC;

      -- Control signals
      stack_op : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      int_ex_in : IN STD_LOGIC;
      int_wb_in : IN STD_LOGIC;
      call : IN STD_LOGIC;
      rti : IN STD_LOGIC;
      mem_read : IN STD_LOGIC;
      mem_write : IN STD_LOGIC;

      -- Outputs
      mem_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      stack_reg_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
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
      int: IN STD_LOGIC;
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
      d0,d1,d2,d3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      y : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
    END COMPONENT;

    -- signals
    mem_read_enable : STD_LOGIC;
    mem_write_enable : STD_LOGIC;
    write_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
    memory_address : STD_LOGIC_VECTOR(15 DOWNTO 0);
    stack_address :  STD_LOGIC_VECTOR(15 DOWNTO 0):=x"0FFF";
    stack_sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
    stack_updated : STD_LOGIC_VECTOR(15 DOWNTO 0):= x"0FFF";
    BEGIN
    
    mem : data_memory PORT MAP (
      clk => clk,
      we => mem_write,
      re => mem_read,
      address => alu_result,
      write_data => Rsrc1,
      read_data => mem_data
    );

    st : stack_reg PORT MAP (
      clk => clk,
      data_in => stack_reg_in,
      data_out => stack_updated
    );

    ssu : stack_selector_unit PORT MAP (
      rti => rti,
      int => int_ex_in,
      stack_op => stack_op,
      stack_sel => stack_sel
    );

    excep_unit : exeception_unit PORT MAP (
      PC_mem => pc,
      stack_op => stack_op,
      SP => stack_reg_in,
      PC_ex => pc,
      mem_exception => mem_exception,
      exception => open,
      exception_type => open,
      EPC => open
    );

    mux2to1_16bit_0 : mux2to1_16bit PORT MAP (
      d0 => alu_result,
      d1 => pc,
      sel => call,
      y => memory_address
    );

    mux2to1_16bit_0 : mux2to1_16bit PORT MAP (
      d0 => alu_result,
      d1 => pc,
      sel => call,
      y => memory_address
    );

    mux2to1_16bit_1 : mux2to1_16bit PORT MAP (
      d0 => alu_result,
      d1 => pc,
      sel => call,
      y => memory_address
    );

    mux4to1_16bit_0 : mux4to1_16bit PORT MAP (
      d0 => alu_result,
      d1 => pc,
      d2 => stack_updated,
      d3 => pc,
      sel => stack_sel,
      y => stack_address
    );

    mux4to1_16bit_1 : mux4to1_16bit PORT MAP (
      d0 => alu_result,
      d1 => pc,
      d2 => stack_updated,
      d3 => pc,
      sel => stack_sel,
      y => stack_address
    );



    stack_reg_out <= stack_updated;

  END memory_stage_arch;