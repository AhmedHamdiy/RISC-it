LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY forwarding_unit IS
    PORT (
        clk : IN STD_LOGIC;
        src1_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        src2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        prev1_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        prev2_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

        mux1_control : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        mux2_control : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END ENTITY forwarding_unit;

ARCHITECTURE forwarding_unit_arch OF forwarding_unit IS
    SIGNAL mux1_control_sig : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
    SIGNAL mux2_control_sig : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
BEGIN
    PROCESS (clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF src1_addr = prev1_addr THEN
                mux1_control_sig <= "11";
            ELSIF src1_addr = prev2_addr THEN
                mux1_control_sig <= "10";
            ELSE
                mux1_control_sig <= "00";
            END IF;

            IF src2_addr = prev1_addr THEN
                mux2_control_sig <= "11";
            ELSIF src2_addr = prev2_addr THEN
                mux2_control_sig <= "10";
            ELSE
                mux2_control_sig <= "00";
            END IF;
        END IF;
    END PROCESS;

    mux1_control <= mux1_control_sig;
    mux2_control <= mux2_control_sig;
END ARCHITECTURE forwarding_unit_arch;