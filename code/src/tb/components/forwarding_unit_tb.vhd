LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_forwarding_unit IS
END ENTITY tb_forwarding_unit;

ARCHITECTURE behavior OF tb_forwarding_unit IS
    COMPONENT forwarding_unit
        PORT (
            clk : IN STD_LOGIC;
            src1_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            src2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            dst_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            prev1_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            prev2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

            mux1_control : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            mux2_control : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL src1_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL src2_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL dst_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL prev1_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL prev2_addr : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL mux1_control : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL mux2_control : STD_LOGIC_VECTOR (1 DOWNTO 0);

    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    uut : forwarding_unit
    PORT MAP(
        clk => clk,
        src1_addr => src1_addr,
        src2_addr => src2_addr,
        dst_addr => dst_addr,
        prev1_addr => prev1_addr,
        prev2_addr => prev2_addr,
        mux1_control => mux1_control,
        mux2_control => mux2_control
    );

    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period / 2;
        clk <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    stim_proc : PROCESS
    BEGIN
        src1_addr <= "000";
        src2_addr <= "000";
        prev1_addr <= "000";
        prev2_addr <= "000";
        dst_addr <= "000";
        WAIT FOR clk_period;

        -- Test Case 1: No match (mux1_control = "00", mux2_control = "00")
        WAIT UNTIL clk = '1';
        src1_addr <= "001";
        src2_addr <= "010";
        prev1_addr <= "011";
        prev2_addr <= "100";
        WAIT FOR clk_period;

        -- Test Case 2: Forward src1 from prev1 (mux1_control = "11")
        WAIT UNTIL clk = '1';
        src1_addr <= "011";
        src2_addr <= "010";
        prev1_addr <= "011";
        prev2_addr <= "100";
        WAIT FOR clk_period;

        -- Test Case 3: Forward src1 from prev2 (mux1_control = "10")
        WAIT UNTIL clk = '1';
        src1_addr <= "100";
        src2_addr <= "010";
        prev1_addr <= "011";
        prev2_addr <= "100";
        WAIT FOR clk_period;

        -- Test Case 4: Forward src2 from prev1 (mux2_control = "11")
        WAIT UNTIL clk = '1';
        src1_addr <= "001";
        src2_addr <= "011";
        prev1_addr <= "011";
        prev2_addr <= "100";
        WAIT FOR clk_period;

        -- Test Case 5: Forward src2 from prev2 (mux2_control = "10")
        WAIT UNTIL clk = '1';
        src1_addr <= "001";
        src2_addr <= "100";
        prev1_addr <= "011";
        prev2_addr <= "100";
        WAIT FOR clk_period;

        -- Test Case 6: Forward both src1 and src2 from prev1
        WAIT UNTIL clk = '1';
        src1_addr <= "011";
        src2_addr <= "011";
        prev1_addr <= "011";
        prev2_addr <= "100";
        WAIT FOR clk_period;

        -- Test Case 7: Forward both src1 and src2 from prev2
        WAIT UNTIL clk = '1';
        src1_addr <= "100";
        src2_addr <= "100";
        prev1_addr <= "011";
        prev2_addr <= "100";
        WAIT FOR clk_period;

        -- Test Case 8: No forwarding (mux1_control = "00", mux2_control = "00")
        WAIT UNTIL clk = '1';
        src1_addr <= "110";
        src2_addr <= "101";
        prev1_addr <= "011";
        prev2_addr <= "100";
        WAIT FOR clk_period;

        -- Hold the final state to observe the results
        WAIT FOR 5 * clk_period;

        -- End the simulation
        WAIT;
    END PROCESS;
END ARCHITECTURE;