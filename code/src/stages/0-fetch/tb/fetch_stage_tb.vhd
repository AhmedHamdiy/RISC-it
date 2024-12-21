LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fetch_stage_tb IS
END fetch_stage_tb;

ARCHITECTURE behavior OF fetch_stage_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT fetch_stage IS
        PORT (
            clk : IN STD_LOGIC;
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
            JMP_inst : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            instruction : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            flush : OUT STD_LOGIC;
            pc : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals for driving inputs and monitoring outputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL HLT : STD_LOGIC := '0';
    SIGNAL RTI : STD_LOGIC := '0';
    SIGNAL INT : STD_LOGIC := '0';
    SIGNAL STALL : STD_LOGIC := '0';
    SIGNAL BRANCH : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL EXP_TYPE : STD_LOGIC := '0';
    SIGNAL EX : STD_LOGIC := '0';
    SIGNAL INDEX : STD_LOGIC := '0';
    SIGNAL EX_MEM_INT : STD_LOGIC := '0';
    SIGNAL JMP_inst : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL flush : STD_LOGIC;
    SIGNAL pc : STD_LOGIC_VECTOR (15 DOWNTO 0);

    -- Clock generation
    CONSTANT CLK_PERIOD : TIME := 20 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : fetch_stage PORT MAP(
        clk => clk,
        HLT => HLT,
        RTI => RTI,
        INT => INT,
        STALL => STALL,
        BRANCH => BRANCH,
        RST => RST,
        EXP_TYPE => EXP_TYPE,
        EX => EX,
        INDEX => INDEX,
        EX_MEM_INT => EX_MEM_INT,
        JMP_inst => JMP_inst,
        instruction => instruction,
        flush => flush,
        pc => pc
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
        -- Test Case 1: Reset
        RST <= '1';
        WAIT FOR 2 * CLK_PERIOD;
        RST <= '0';
        WAIT FOR CLK_PERIOD;

        -- Test Case 2: Normal operation (no control signals active)
        HLT <= '0';
        RTI <= '0';
        INT <= '0';
        STALL <= '0';
        BRANCH <= '0';
        EXP_TYPE <= '0';
        EX <= '0';
        INDEX <= '0';
        EX_MEM_INT <= '0';
        JMP_inst <= X"1234";
        WAIT FOR 2 * CLK_PERIOD;

        -- Test Case 3: Branching
        BRANCH <= '1';
        JMP_inst <= X"5678";
        WAIT FOR 2 * CLK_PERIOD;
        BRANCH <= '0';
        WAIT FOR CLK_PERIOD;

        -- Test Case 4: Interrupt
        INT <= '1';
        WAIT FOR 2 * CLK_PERIOD;
        INT <= '0';
        WAIT FOR CLK_PERIOD;

        -- Test Case 5: Stalling
        STALL <= '1';
        WAIT FOR 2 * CLK_PERIOD;
        STALL <= '0';
        WAIT FOR CLK_PERIOD;

        -- Test Case 6: Halt
        HLT <= '1';
        WAIT FOR 2 * CLK_PERIOD;
        HLT <= '0';
        WAIT FOR CLK_PERIOD;

        -- Test Case 7: Exception Handling
        EXP_TYPE <= '1';
        WAIT FOR 2 * CLK_PERIOD;
        EXP_TYPE <= '0';
        WAIT FOR CLK_PERIOD;

        -- Test Case 8: Exhaustive MUX control signal combinations
        FOR i IN 0 TO 255 LOOP
            HLT <= STD_LOGIC(to_unsigned(i, 8)(7));
            RTI <= STD_LOGIC(to_unsigned(i, 8)(6));
            INT <= STD_LOGIC(to_unsigned(i, 8)(5));
            STALL <= STD_LOGIC(to_unsigned(i, 8)(4));
            BRANCH <= STD_LOGIC(to_unsigned(i, 8)(3));
            EXP_TYPE <= STD_LOGIC(to_unsigned(i, 8)(2));
            EX <= STD_LOGIC(to_unsigned(i, 8)(1));
            INDEX <= STD_LOGIC(to_unsigned(i, 8)(0));
            WAIT FOR CLK_PERIOD;
        END LOOP;

        WAIT;
    END PROCESS;

END behavior;