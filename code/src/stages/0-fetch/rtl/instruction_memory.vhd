LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY instruction_memory IS
    TYPE saved_array_type IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    PORT (
        clk : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        inst : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        saved_addresses : OUT saved_array_type
    );
END ENTITY instruction_memory;

ARCHITECTURE instruction_memory_arch OF instruction_memory IS
    CONSTANT mem_depth : INTEGER := 4096;
    CONSTANT word_width : INTEGER := 16;

    TYPE ram_type IS ARRAY(mem_depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR (word_width - 1 DOWNTO 0);
    SIGNAL ram : ram_type := (OTHERS => (OTHERS => '0'));

BEGIN
    PROCESS (clk) IS
        VARIABLE addr_var := ;
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF (TO_INTEGER(UNSIGNED(address)) < mem_depth - 1) THEN
                inst <= ram(TO_INTEGER(UNSIGNED(address)));
            END IF;
        END IF;
    END PROCESS;
    saved_addresses <= ram(3 DOWNTO 0);
END ARCHITECTURE;