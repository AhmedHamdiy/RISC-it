LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY execute_stage_tb IS
END execute_stage_tb;

ARCHITECTURE behavior OF execute_stage_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
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
            
            out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            will_jmp : OUT STD_LOGIC;
            mem_excep : OUT STD_LOGIC;
            flags_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            res : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals for driving inputs and monitoring outputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL src1_addr, src2_addr : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL prev1_addr, prev2_addr : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rsrc1, Rsrc2 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_forwarded_Rsrc1, mem_forwarded_Rsrc2 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL alu_forwarded_Rsrc1, alu_forwarded_Rsrc2 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Imm : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL flags_in : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL in_port : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL out_port : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL res : STD_LOGIC_VECTOR (15 DOWNTO 0);

    SIGNAL flag_restore : STD_LOGIC := '0';
    SIGNAL alu_operation : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL has_immidiate : STD_LOGIC := '0';
    SIGNAL store_op : STD_LOGIC := '0';
    SIGNAL input_enable : STD_LOGIC := '0';
    SIGNAL output_enable : STD_LOGIC := '0';
    SIGNAL jmp_type : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL branch : STD_LOGIC := '0';
    SIGNAL mem_read : STD_LOGIC := '0';
    SIGNAL mem_write : STD_LOGIC := '0';

    SIGNAL will_jmp : STD_LOGIC;
    SIGNAL mem_excep : STD_LOGIC;
    SIGNAL flags_out : STD_LOGIC_VECTOR (3 DOWNTO 0);

    -- Clock generation
    CONSTANT CLK_PERIOD : TIME := 20 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : execute_stage PORT MAP(
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

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR CLK_PERIOD / 2;
        clk <= '1';
        WAIT FOR CLK_PERIOD / 2;
    END PROCESS;

    -- Stimulus process
    stimulus_process : PROCESS
    BEGIN
        -- Test Case 1: Simple ALU operation
        Rsrc1 <= X"0001";
        Rsrc2 <= X"0002";
        alu_operation <= "000"; -- Add operation
        WAIT FOR 2 * CLK_PERIOD;

        -- Test Case 2: Immediate value
        has_immidiate <= '1';
        Imm <= X"0005";
        WAIT FOR 2 * CLK_PERIOD;

        -- Test Case 3: Branching
        branch <= '1';
        flags_in(1) <= '1'; -- Set condition flag
        jmp_type <= "01";
        WAIT FOR 2 * CLK_PERIOD;

        -- Additional tests...
        WAIT;
    END PROCESS;

END behavior;
