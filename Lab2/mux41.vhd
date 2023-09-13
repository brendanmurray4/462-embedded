library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux41 is
    generic(bit_width : integer := 24);
    port (
        sel_switch : in std_logic_vector(1 downto 0);
        inp0,inp1,inp2,inp3 : in std_logic_vector(bit_width downto 0);
        outp : out std_logic_vector(bit_width downto 0)
    );
end mux41;

architecture rtl of mux41 is

begin
    WITH sel_switch SELECT
        outp <= inp0 WHEN "00",
            inp1 WHEN "01",
            inp2 WHEN "10",
            inp3 WHEN OTHERS;
end architecture;