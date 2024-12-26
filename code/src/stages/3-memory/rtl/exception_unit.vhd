LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY exception_unit IS
    PORT (
        -- stack exception
        PC_mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        stack_op : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        SP : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- memory exception
        PC_ex : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        mem_exception : IN STD_LOGIC;
        -- output
        exception : OUT STD_LOGIC;
        exception_type : OUT STD_LOGIC;
        EPC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
    );
END ENTITY exception_unit;

ARCHITECTURE exception_unit_arch OF exception_unit IS
    CONSTANT STACK_MAX_VALUE : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0FFF";
BEGIN
    PROCESS (stack_op, mem_exception, SP)
    BEGIN
        IF (stack_op = "10" AND SP >= STACK_MAX_VALUE) THEN
            exception <= '1';
            exception_type <= '0';
            EPC <= PC_mem;
        ELSIF (mem_exception = '1') THEN
            exception <= '1';
            exception_type <= '1';
            EPC <= PC_ex;
        ELSE
            exception <= '0';
            exception_type <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE;