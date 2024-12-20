LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY pc_reg IS
    PORT (
        pc_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        clk, hlt, rst, one_cycle : IN STD_LOGIC;
        next_ins_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END ENTITY pc_reg;

ARCHITECTURE pc_reg_arch OF pc_reg IS
    SIGNAL stop_till_rst : STD_LOGIC := '0';
BEGIN
    PROCESS (clk)
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            IF (rst) THEN
                stop_till_reset <= '0';
                next_ins_address <= (OTHERS => '0');
            ELSIF (NOT stop_till_reset) THEN
                IF ((NOT one_cycle) AND (NOT hlt)) THEN
                    next_ins_address <= pc_in;
                ELSIF hlt THEN
                    stop_till_reset <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;