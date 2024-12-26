LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY mux4to1_16bit IS
    PORT (
        d0, d1, d2, d3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        y : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END mux4to1_16bit;

ARCHITECTURE mux4to1_16bit_arch OF mux4to1_16bit IS
BEGIN
    PROCESS (d0, d1, d2, d3, sel)
    BEGIN
        CASE sel IS
            WHEN "00" =>
                y <= d0;
            WHEN "01" =>
                y <= d1;
            WHEN "10" =>
                y <= d2;
            WHEN "11" =>
                y <= d3;
            WHEN OTHERS =>
                y <= (OTHERS => '0');
        END CASE;
    END PROCESS;
END mux4to1_16bit_arch;