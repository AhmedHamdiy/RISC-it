
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_pc_reg IS
END ENTITY;

ARCHITECTURE behavior OF tb_pc_reg IS

    COMPONENT pc_reg
        PORT (
            pc_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            clk, hlt, rst, one_cycle : IN STD_LOGIC;
            next_ins_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL pc_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL hlt : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '0';
    SIGNAL one_cycle : STD_LOGIC := '0';
    SIGNAL next_ins_address : STD_LOGIC_VECTOR(15 DOWNTO 0);

    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    uut : pc_reg PORT MAP(
        pc_in => pc_in,
        clk => clk,
        hlt => hlt,
        rst => rst,
        one_cycle => one_cycle,
        next_ins_address => next_ins_address
    );

    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
        WAIT;
    END PROCESS;

    stim_proc : PROCESS
    BEGIN
        -- Initialize Inputs
        rst <= '1';
        WAIT FOR clk_period;

        rst <= '0';
        pc_in <= X"0001";
        WAIT FOR clk_period;

        -- Test case: Load pc_in into next_ins_address
        one_cycle <= '0';
        hlt <= '0';
        WAIT FOR clk_period;

        -- Check halt behavior
        hlt <= '1';
        WAIT FOR clk_period;

        -- Clear halt with reset
        rst <= '1';
        WAIT FOR clk_period;
        rst <= '0';

        -- Test one_cycle (no action expected when one_cycle = '1')
        hlt <= '0';
        one_cycle <= '1';
        pc_in <= X"0010";
        WAIT FOR clk_period;

        -- Final test case: Normal operation
        one_cycle <= '0';
        pc_in <= X"0020";
        WAIT FOR clk_period;

        WAIT;
    END PROCESS;

END ARCHITECTURE;