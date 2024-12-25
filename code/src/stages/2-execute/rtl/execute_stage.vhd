<<<<<<< HEAD
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY execute_stage IS
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

    flag_restore : IN STD_LOGIC;
    control_signals : IN STD_LOGIC_VECTOR (20 DOWNTO 0);

    pc_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    Rdst_addr_out : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

    out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    will_jmp : OUT STD_LOGIC;
    mem_excep : OUT STD_LOGIC;
    flags_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    res : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
  );
END execute_stage;

ARCHITECTURE execute_stage_arch OF execute_stage IS

  COMPONENT alu IS
    PORT (
      flag_restore : IN STD_LOGIC;
      flags_reg : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      a, b : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      alu_operation : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

      flag_register : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      result : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT forwarding_unit IS
    PORT (
      clk : IN STD_LOGIC;
      src1_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      src2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      prev1_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      prev2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

      mux1_control : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      mux2_control : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
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

  COMPONENT mux4 IS
    PORT (
      d0, d1, d2, d3 : IN STD_LOGIC;
      sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

      y : OUT STD_LOGIC
    );
  END COMPONENT;

  -- Signals
  SIGNAL alu_in1_mux_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in2_mux_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in1_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in2_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in1_mux_sel : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in2_mux_sel : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_result : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  SIGNAL flags_out_sig : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL branch_choice : STD_LOGIC := '0';

BEGIN

  -- Components
  alu_inst : alu PORT MAP(flag_restore, flags_in, alu_in1_mux_out, alu_in2_mux_out, control_signals((6 DOWNTO 4)), flags_out_sig, alu_result);
  f_unit_inst : forwarding_unit PORT MAP(clk, src1_addr, src2_addr, prev1_addr, prev2_addr, alu_in1_mux_sel, alu_in2_mux_sel);

  -- Muxes
  op1_mux : mux2to1_16bit PORT MAP(Rsrc1, Rsrc2, control_signals(20), alu_in1_mux_in);
  op2_mux : mux2to1_16bit PORT MAP(Rsrc2, Imm, control_signals(7), alu_in2_mux_in);
  alu_in1_mux : mux4to1_16bit PORT MAP(alu_in1_mux_in, alu_in1_mux_in, mem_forwarded_Rsrc1, alu_forwarded_Rsrc1, alu_in1_mux_sel, alu_in1_mux_out);
  alu_in2_mux : mux4to1_16bit PORT MAP(alu_in2_mux_in, alu_in2_mux_in, mem_forwarded_Rsrc2, alu_forwarded_Rsrc2, alu_in2_mux_sel, alu_in2_mux_out);
  alu_result_mux : mux2to1_16bit PORT MAP(alu_result, in_port, control_signals(1), res);
  jmp_mux : mux4 PORT MAP('1', flags_out_sig(1), flags_out_sig(2), flags_out_sig(3), control_signals(13 DOWNTO 12), branch_choice);

  -- other compinational logic
  flags_out <= flags_out_sig;
  will_jmp <= control_signals(11) AND branch_choice;
  mem_excep <= '1' WHEN (alu_result > x"0FFF")
    AND (control_signals(17) = '1' OR control_signals(18) = '1') ELSE
    '0';
  out_port <= Rsrc1 WHEN control_signals(0) = '1' ELSE
    (OTHERS => 'Z');
  pc_out <= pc_in;
  Rdst_addr_out <= Rdst_addr_in;
=======
LIBRARY IEEE;SIGNAL 
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY execute_stage IS
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
    out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    will_jmp : OUT STD_LOGIC;
    mem_excep : OUT STD_LOGIC;
    flags_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    res : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
  );
END execute_stage;

ARCHITECTURE execute_stage_arch OF execute_stage IS

  COMPONENT alu IS
    PORT (
      flag_restore : IN STD_LOGIC;
      flags_reg : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      a, b : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      alu_operation : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

      flag_register : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      result : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT forwarding_unit IS
    PORT (
      clk : IN STD_LOGIC;
      src1_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      src2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      prev1_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      prev2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

      mux1_control : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      mux2_control : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
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

  COMPONENT mux4 IS
    PORT (
      d0, d1, d2, d3 : IN STD_LOGIC;
      sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

      y : OUT STD_LOGIC
    );
  END COMPONENT;

  -- Signals
  SIGNAL alu_in1_mux_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in2_mux_in : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in1_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in2_mux_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in1_mux_sel : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_in2_mux_sel : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL alu_result : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');

  SIGNAL flags_out_sig : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL branch_choice : STD_LOGIC := '0';

BEGIN

  -- Components
  alu_inst : alu PORT MAP(flag_restore, flags_in, alu_in1_mux_out, alu_in2_mux_out, alu_operation, flags_out_sig, alu_result);
  f_unit_inst : forwarding_unit PORT MAP(clk, src1_addr, src2_addr, prev1_addr, prev2_addr, alu_in1_mux_sel, alu_in2_mux_sel);

  -- Muxes
  op1_mux : mux2to1_16bit PORT MAP(Rsrc1, Rsrc2, store_op, alu_in1_mux_in);
  op2_mux : mux2to1_16bit PORT MAP(Rsrc2, Imm, has_immidiate, alu_in2_mux_in);
  alu_in1_mux : mux4to1_16bit PORT MAP(alu_in1_mux_in, alu_in1_mux_in, mem_forwarded_Rsrc1, alu_forwarded_Rsrc1, alu_in1_mux_sel, alu_in1_mux_out);
  alu_in2_mux : mux4to1_16bit PORT MAP(alu_in2_mux_in, alu_in2_mux_in, mem_forwarded_Rsrc2, alu_forwarded_Rsrc2, alu_in2_mux_sel, alu_in2_mux_out);
  alu_result_mux : mux2to1_16bit PORT MAP(alu_result, in_port, input_enable, res);
  jmp_mux : mux4 PORT MAP('1', flags_out_sig(1), flags_out_sig(2), flags_out_sig(3), jmp_type, branch_choice);

  -- other compinational logic
  flags_out <= flags_out_sig;
  will_jmp <= branch AND branch_choice;
  mem_excep <= '1' WHEN (alu_result > x"0FFF")
    AND (mem_read = '1' OR mem_write = '1') ELSE
    '0';
  out_port <= Rsrc1 WHEN output_enable = '1' ELSE
    (OTHERS => 'Z');

>>>>>>> fae72b7 (add store signal)
END execute_stage_arch;