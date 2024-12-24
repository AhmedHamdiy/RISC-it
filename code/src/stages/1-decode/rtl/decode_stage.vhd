LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY decode_stage IS
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
    pc_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
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
END decode_stage;

ARCHITECTURE decode_stage_arch OF decode_stage IS

  COMPONENT hazard_detection_unit IS PORT (
    IF_ID_Rsrc1, IF_ID_Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    ID_EX_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    ID_EX_mem_read : IN STD_LOGIC;
    ret : IN STD_LOGIC;
    rti : IN STD_LOGIC;
    ID_EX_branch : IN STD_LOGIC;
    EX_MEM_branch : IN STD_LOGIC;
    hazard : OUT STD_LOGIC;
    stall : OUT STD_LOGIC;
    will_branch : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT control_unit IS
    PORT (
      clk : IN STD_LOGIC;
      opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      in_enable, out_enable, reg_write, mem_write, mem_read, mem_to_reg, is_immediate,
      branch, call, ret, interrupt, rti, freeze : OUT STD_LOGIC;
      alu_operation : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      stack_operation : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      jump_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT register_file IS
    PORT (
      write_reg : IN STD_LOGIC;
      clk, reset : IN STD_LOGIC;
      write_address, read_address_0, read_address_1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      write_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      read_data_0, read_data_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT mux2to1_16bit IS
    PORT (
      d0, d1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      sel : IN STD_LOGIC;
      y : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL control_unit_out : STD_LOGIC_VECTOR(19 DOWNTO 0);
  SIGNAL JMP_dst_Mux_selector, NOP_mux_selector, signals_mux_selector : STD_LOGIC;
  SIGNAL NOP : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
  SIGNAL rsrc1_address, rsrc2_address : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL hazard_signal : STD_LOGIC;
  SIGNAL selected_inst : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL dummy : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL dumy : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
  inst0 <= selected_inst(0);

  Rsrc1_add <= selected_inst(10 DOWNTO 8);
  Rsrc2_add <= selected_inst(4 DOWNTO 2);
  rsrc1_address <= selected_inst(10 DOWNTO 8);
  rsrc2_address <= selected_inst(4 DOWNTO 2);

  reg_file : register_file
  PORT MAP(
    write_reg => write_reg,
    clk => clk,
    reset => reset,
    write_address => WB_Rdst,
    read_address_0 => selected_inst(10 DOWNTO 8),
    read_address_1 => selected_inst(4 DOWNTO 2),
    write_data => data_to_write,
    read_data_0 => Rsrc1,
    read_data_1 => Rsrc2
  );

  CU : control_unit
  PORT MAP(
    clk => clk,
    opcode => selected_inst(15 DOWNTO 11),
    in_enable => control_unit_out(0),
    out_enable => control_unit_out(1),
    reg_write => control_unit_out(2),
    mem_write => control_unit_out(3),
    mem_read => control_unit_out(4),
    mem_to_reg => control_unit_out(5),
    alu_operation => control_unit_out(8 DOWNTO 6),
    is_immediate => control_unit_out(9),
    stack_operation => control_unit_out(11 DOWNTO 10),
    branch => control_unit_out(12),
    jump_type => control_unit_out(14 DOWNTO 13),
    call => control_unit_out(15),
    ret => control_unit_out(16),
    interrupt => control_unit_out(17),
    rti => control_unit_out(18),
    freeze => control_unit_out(19)
  );

  HDU : hazard_detection_unit
  PORT MAP(
    IF_ID_Rsrc1 => rsrc1_address,
    IF_ID_Rsrc2 => rsrc2_address,
    ID_EX_Rdst => ID_EX_Rdst,
    ID_EX_mem_read => ID_EX_mem_read,
    ret => ret,
    rti => rti,
    ID_EX_branch => ID_EX_branch,
    EX_MEM_branch => EX_MEM_branch,
    hazard => hazard_signal,
    stall => stall,
    will_branch => will_branch
  );

  JMP_dst_Mux_selector <= ret OR rti;

  JMP_dst_mux : mux2to1_16bit
  PORT MAP(
    d0 => ID_EX_Rsrc1_data,
    d1 => data_to_write,
    sel => JMP_dst_Mux_selector,
    y => jmp_add
  );

  NOP_mux_selector <= rti OR has_immediate;

  NOP_inst_mux : mux2to1_16bit
  PORT MAP(
    d0 => NOP,
    d1 => inst,
    sel => NOP_mux_selector,
    y => selected_inst
  );

  signals_mux_selector <= hazard_signal OR has_immediate;

  selected_signals_mux1 : mux2to1_16bit
  PORT MAP(
    d0 => control_unit_out(19 DOWNTO 4),
    d1 => x"0000",
    sel => signals_mux_selector,
    y => control_signals(19 DOWNTO 4)
  );

  dumy <= "000000000000" & control_unit_out(3 DOWNTO 0);

  selected_signals_mux2 : mux2to1_16bit
  PORT MAP(
    d0 => dumy,
    d1 => x"0000",
    sel => signals_mux_selector,
    y => dummy
  );

  control_signals(3 DOWNTO 0) <= dummy(3 DOWNTO 0);
  pc_out <= pc_in;
  Rdst_address <= ID_EX_Rdst;
END decode_stage_arch;