LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY stack_reg IS
    PORT (
        clk : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY stack_reg;

ARCHITECTURE stack_reg_arch OF stack_reg IS
    SIGNAL stack_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0FFF";
BEGIN
    PROCESS (clk) IS
    BEGIN
        IF FALLING_EDGE(clk) THEN
            stack_reg <= data_in;
        END IF;
    END PROCESS;
    data_out <= stack_reg;
END ARCHITECTURE;