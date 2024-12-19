LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY exp_next_mux IS
    PORT (
        exp_ins, control_mux_out : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        exp_control : IN STD_LOGIC;
        exp_next_mux_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END ENTITY exp_next_mux;

ARCHITECTURE exp_next_mux_arch OF exp_next_mux IS
BEGIN
    PROCESS (exp_control, exp_ins, control_mux_out)
        IF (exp_control = "0") THEN
            exp_next_mux_out <= control_mux_out;
        ELSE
            exp_next_mux_out <= exp_ins;
        END IF;
    END PROCESS;
END ARCHITECTURE;