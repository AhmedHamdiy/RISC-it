LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_alu IS
END tb_alu;

ARCHITECTURE behavior OF tb_alu IS

    COMPONENT alu
        PORT(
            flag_restore : IN STD_LOGIC;
            flags_reg    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            a, b         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            alu_operation: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            flag_register: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            result       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk          : STD_LOGIC := '0';
    SIGNAL flag_restore : STD_LOGIC := '0';
    SIGNAL flags_reg    : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL a, b         : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL alu_operation: STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL flag_register: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL result       : STD_LOGIC_VECTOR(15 DOWNTO 0);

    CONSTANT clk_period: TIME := 10 ns;

BEGIN

    uut: alu PORT MAP (
        flag_restore   => flag_restore,
        flags_reg      => flags_reg,
        a              => a,
        b              => b,
        alu_operation  => alu_operation,
        flag_register  => flag_register,
        result         => result
    );

    -- Clock generation process
    clk_process: PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period / 2;
        clk <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    -- Stimulus process
    stimulus: PROCESS
    BEGIN
        -- Test Case 1: NOT operation 
        a <= x"0000"; b <= x"0000"; alu_operation <= "101";
        WAIT FOR clk_period;
        ASSERT result = x"FFFF" AND flag_register = "0100" REPORT "NOT operation failed for a = 0x0000" SEVERITY ERROR;

        -- Test Case 2: ADD operation
        a <= x"0001"; b <= x"0001"; alu_operation <= "000";
        WAIT FOR clk_period;
        ASSERT result = x"0002" AND flag_register = "0000" REPORT "ADD operation failed for a = 0x0001, b = 0x0001" SEVERITY ERROR;

        -- Test Case 3: SUB operation
        a <= x"0002"; b <= x"0001"; alu_operation <= "001";
        WAIT FOR clk_period;
        ASSERT result = x"0001" AND flag_register = "0000" REPORT "SUB operation failed for a = 0x0002, b = 0x0001" SEVERITY ERROR;

        -- Test Case 4: AND operation
        a <= x"FFFF"; b <= x"0F0F"; alu_operation <= "010";
        WAIT FOR clk_period;
        ASSERT result = x"0F0F" AND flag_register = "0000" REPORT "AND operation failed for a = 0xFFFF, b = 0x0F0F" SEVERITY ERROR;

        -- Test Case 5: INC operation (alu_operation = "100")
        a <= x"FFFF"; b <= x"0000"; alu_operation <= "100";
        WAIT FOR clk_period;
        ASSERT result = x"0000" AND flag_register = "1001" REPORT "INC operation failed for a = 0xFFFF" SEVERITY ERROR;

        -- Test Case 6: MOV operation (alu_operation = "101")
        a <= x"1234"; b <= x"0000"; alu_operation <= "011";
        WAIT FOR clk_period;
        ASSERT result = x"1234" REPORT "MOV operation failed for a = 0x1234" SEVERITY ERROR;

        -- Test Case 7: SETC operation (alu_operation = "111")
        alu_operation <= "110";
        WAIT FOR clk_period;
        ASSERT flag_register(1 DOWNTO 0) = "01" REPORT "SETC operation failed" SEVERITY ERROR;

        -- Test Case 7: SETC operation (alu_operation = "111")
        flag_restore<='1';
        flags_reg<="1111";
        WAIT FOR clk_period;
        ASSERT flag_register = "1111" REPORT "Flags restore failed"  SEVERITY ERROR;

        WAIT;
    END PROCESS;

END behavior;
