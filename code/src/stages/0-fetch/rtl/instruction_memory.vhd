LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY instruction_memory IS
    PORT (
        clk : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        inst : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        empty_stack : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        invalid_mem_add : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        INT0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        INT2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY instruction_memory;

ARCHITECTURE instruction_memory_arch OF instruction_memory IS
    CONSTANT mem_depth : INTEGER := 4096;
    CONSTANT word_width : INTEGER := 16;
    TYPE ram_type IS ARRAY(mem_depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR (word_width - 1 DOWNTO 0);
    SIGNAL ram : ram_type := (OTHERS => (OTHERS => '0'));

BEGIN
    PROCESS (clk) IS
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF (TO_INTEGER(UNSIGNED(address)) < mem_depth - 1) THEN
                inst <= ram(TO_INTEGER(UNSIGNED(address)));
            END IF;
        END IF;
    END PROCESS;
    empty_stack <= ram(0);
    invalid_mem_add <= ram(1);
    INT0 <= ram(2);
    INT2 <= ram(3);
END ARCHITECTURE;