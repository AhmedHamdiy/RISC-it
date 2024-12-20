LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY hazard_detection_tb IS
END hazard_detection_tb;

ARCHITECTURE behavior OF hazard_detection_tb IS

    COMPONENT hazard_detection_unit
    PORT(
        IF_ID_Rsrc1    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        IF_ID_Rsrc2    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ID_EX_Rdst     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ID_EX_mem_read : IN  STD_LOGIC;
        ret            : IN  STD_LOGIC;
        rti            : IN  STD_LOGIC;
        ID_EX_branch   : IN  STD_LOGIC;
        EX_MEM_brach   : IN  STD_LOGIC;
        hazard         : OUT STD_LOGIC;
        stall          : OUT STD_LOGIC;
        will_branch    : OUT STD_LOGIC
    );
    END COMPONENT;

    SIGNAL IF_ID_Rsrc1    : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IF_ID_Rsrc2    : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_Rdst     : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_mem_read : STD_LOGIC := '0';
    SIGNAL ret            : STD_LOGIC := '0';
    SIGNAL rti            : STD_LOGIC := '0';
    SIGNAL ID_EX_branch   : STD_LOGIC := '0';
    SIGNAL EX_MEM_brach   : STD_LOGIC := '0';
    SIGNAL hazard         : STD_LOGIC;
    SIGNAL stall          : STD_LOGIC;
    SIGNAL will_branch    : STD_LOGIC;

BEGIN

    uut: hazard_detection_unit PORT MAP (
        IF_ID_Rsrc1    => IF_ID_Rsrc1,
        IF_ID_Rsrc2    => IF_ID_Rsrc2,
        ID_EX_Rdst     => ID_EX_Rdst,
        ID_EX_mem_read => ID_EX_mem_read,
        ret            => ret,
        rti            => rti,
        ID_EX_branch   => ID_EX_branch,
        EX_MEM_brach   => EX_MEM_brach,
        hazard         => hazard,
        stall          => stall,
        will_branch    => will_branch
    );

    stimulus_process: PROCESS
    BEGIN
        -- Test 1: No hazard
        ID_EX_mem_read <= '0';
        IF_ID_Rsrc1 <= "001";
        IF_ID_Rsrc2 <= "010";
        ID_EX_Rdst <= "011";
        WAIT FOR 10 ns;
        ASSERT hazard = '0' AND stall='0' REPORT "Test Failed:no hazard"  SEVERITY ERROR;

        -- Test 1: No hazard
        ID_EX_mem_read <= '0';
        IF_ID_Rsrc1 <= "001";
        IF_ID_Rsrc2 <= "010";
        ID_EX_Rdst <= "001";
        WAIT FOR 10 ns;
        ASSERT hazard = '0' AND stall='0' REPORT "Test Failed:no hazard"  SEVERITY ERROR;


        -- Test 2: Load-use hazard
        ID_EX_mem_read <= '1';
        IF_ID_Rsrc1 <= "001";
        ID_EX_Rdst <= "001"; -- Resource conflict
        WAIT FOR 10 ns;
        ASSERT hazard = '1' AND stall='1' REPORT "Test Failed:hazard detection"  SEVERITY ERROR;


        -- Test 3: Control hazard (ret signal high)
        ID_EX_mem_read <= '0';
        ret <= '1';
        ID_EX_branch <= '0';
        EX_MEM_brach <= '0';
        rti <= '0';
        WAIT FOR 10 ns;
        ASSERT hazard = '0' AND stall='0'AND will_branch='1' REPORT "Test Failed:control hazard"  SEVERITY ERROR;

        -- Test 4: Control hazard (rti signal high)
        rti <= '1';
        WAIT FOR 10 ns;
        ASSERT hazard = '0' AND stall='0'AND will_branch='1' REPORT "Test Failed:control hazard"  SEVERITY ERROR;

        -- Test 5: Branch hazards (ID_EX_branch and EX_MEM_brach)
        ID_EX_branch <= '0';
        EX_MEM_brach <= '0';
        ret <= '0';
        rti <= '0';
        ASSERT hazard = '0' AND stall='0'AND will_branch='1' REPORT "Test Failed:no control hazard"  SEVERITY ERROR;

        -- Test complete
        WAIT;
    END PROCESS;

END behavior;
