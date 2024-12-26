LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY stack_selector_unit IS
    PORT (
        rti : IN STD_LOGIC;
        int : IN STD_LOGIC;
        stack_op : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        stack_sel : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END stack_selector_unit;

ARCHITECTURE stack_selector_unit_arch OF stack_selector_unit IS
BEGIN
    stack_sel <= "11" WHEN (int = '1') ELSE
        "10" WHEN (rti = '1') ELSE
        stack_op;
END stack_selector_unit_arch;