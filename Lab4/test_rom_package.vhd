library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

package test_rom_package is

    constant minaddr: integer := 0;
    constant x_maxaddr: integer := 1920-1;
    --constant y_maxaddr : integer := 1080-1;
    type rom_type is array (0 to x_maxaddr) of std_logic_vector(11 downto 0); -- data format : [RRRRGGGGBBBB]
    function create_rom return rom_type;

    -- colours on screen from left to right
    constant white : std_logic_vector(11 downto 0) := (others => '1');
    constant yellow : std_logic_vector(11 downto 0) := x"FF0";
    constant cyan : std_logic_vector(11 downto 0) := x"0FF";
    constant green : std_logic_vector(11 downto 0) := x"0F0";
    constant magenta : std_logic_vector(11 downto 0) := x"F0F";
    constant red : std_logic_vector(11 downto 0) := x"F00";
    constant blue : std_logic_vector(11 downto 0) := x"00F";
    constant black : std_logic_vector(11 downto 0) := x"000";



end package;

package body test_rom_package is

    function create_rom return rom_type is
        variable rom_v : rom_type; --return type
        begin
        for i in minaddr to x_maxaddr loop 
            if i < 240 then
                rom_v(i) := white;
            elsif i >= 240 and i < 480 then
                rom_v(i) := yellow;
            elsif i >= 480 and i < 720 then
                rom_v(i) := cyan;
            elsif i >= 720 and i < 960 then
                rom_v(i) := green;
            elsif i >= 960 and i < 1200 then
                rom_v(i) := magenta;
            elsif i >= 1200 and i < 1440 then
                rom_v(i) := red;
            elsif i >= 1440 and i < 1700 then
                rom_v(i) := blue;
            else
                rom_v(i) := black;
            end if;
        end loop;
        return rom_v;
    end function;
    
    constant test_pattern_ROM : rom_type := create_rom; --creates a constant called rom of type rom_type, instantiated with the function create_rom

end package body;