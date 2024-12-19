LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY pc_in_mux IS
    PORT (
        first_ins, exp_next_mux_out : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        reset : IN STD_LOGIC;
        pc_in_mux_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END ENTITY pc_in_mux;

ARCHITECTURE exp_next_mux_arch OF exp_next_mux IS
BEGIN
    PROCESS (first_ins, exp_next_mux_out, reset)
        IF (reset = "0") THEN
            pc_in_mux_out <= exp_next_mux_out;
        ELSE
            pc_in_mux_out <= first_ins;
        END IF;
    END PROCESS;
END ARCHITECTURE;