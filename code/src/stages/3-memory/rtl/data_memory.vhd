LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY data_memory IS
    PORT (
        clk : IN STD_LOGIC;
        we : IN STD_LOGIC;
        re : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        read_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
    );
END ENTITY data_memory;

ARCHITECTURE data_memory_arch OF data_memory IS
    CONSTANT mem_depth : INTEGER := 4096;
    CONSTANT word_width : INTEGER := 16;

    TYPE ram_type IS ARRAY(mem_depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR (word_width - 1 DOWNTO 0);
    SIGNAL ram : ram_type := (OTHERS => (OTHERS => '0'));

    SIGNAL one : STD_LOGIC_VECTOR(15 DOWNTO 0) := (0 => '1', OTHERS => '0');
BEGIN
    PROCESS (clk) IS
        VARIABLE i : INTEGER := 0;
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF (we = '1' AND TO_INTEGER(UNSIGNED(address)) < mem_depth - 1) THEN
                ram(TO_INTEGER(UNSIGNED(address))) <= write_data;
            END IF;
            IF (re = '1' AND TO_INTEGER(UNSIGNED(address)) < mem_depth - 1) THEN
                read_data <= ram(TO_INTEGER(UNSIGNED(address)));
            END IF;
        END IF;

    END PROCESS;

END ARCHITECTURE;