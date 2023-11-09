library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.res_1080p_package.all;
use work.test_rom_package.all;

entity video_controller is
    port (
        clk : in std_logic;
        rst : in std_logic;
        SW7 : in std_logic; --if '1' rotate right
        SW6 : in std_logic; --if '1' rotate left
        hsync: out std_logic;
        vsync: out std_logic;
        VGA_G: out std_logic_vector(3 downto 0);
        VGA_B: out std_logic_vector(3 downto 0);
        VGA_R: out std_logic_vector(3 downto 0)
    );
end video_controller;

architecture rtl of video_controller is
signal xpos: integer range 0 to MAX_X_RES;
signal ypos: integer range 0 to MAX_Y_RES;
signal offset : integer range 0 to MAX_X_PIXELS := 0;
--signal index : integer range 0 to MAX_X_RES;
constant test_pattern_ROM : rom_type := create_rom; --creates a constant called rom of type rom_type, instantiated with the function create_rom
begin

    
    COUNTER_PROC: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                xpos <= horizontal_back_porch;
                ypos <= vertical_back_porch;
            end if;
            if xpos = MAX_X_RES then
                xpos <= 0;
                if ypos = MAX_Y_RES then
                    ypos <= 0;

                    if SW6 = '0' and SW7 = '1' then --rotate right
                        if offset = 1916 then
                            offset <= 0;
                        else
                            offset <= offset + 4;
                        end if;
                    elsif SW6  = '1' and SW7 = '0' then --rotate left
                        if offset = 0 then
                            offset <= 1916;
                        else
                            offset <= offset - 4;
                        end if;                  
                    end if;
                else
                    ypos <= ypos +1;
                end if;
            else
                xpos <= xpos +1;
            end if;
        end if;
    end process;

    HSYNC_PROC: process(xpos)
    begin
        if xpos > MAX_X_FRONT then
            hsync <= '0';
        else
            hsync <= '1';
        end if;
    end process;

    VSYNC_PROC: process(ypos)
    begin
        if ypos > MAX_Y_FRONT then
            vsync <= '0';
        else
            vsync <= '1';
        end if;
    end process;

    OUTPUT_PROC: process(xpos, ypos)
    begin
        if xpos >= horizontal_back_porch AND xpos <= MAX_X_DRAWING then
            if ypos >= vertical_back_porch AND ypos <= MAX_Y_DRAWING then
                if xpos - horizontal_back_porch + offset > 1919 then
                    --index <= xpos - horizontal_back_porch + offset - 1920;
                    VGA_G <= test_pattern_ROM(xpos - horizontal_back_porch + offset - 1920)(7 downto 4);
                    VGA_B <= test_pattern_ROM(xpos - horizontal_back_porch + offset - 1920)(3 downto 0);
                    VGA_R <= test_pattern_ROM(xpos - horizontal_back_porch + offset - 1920)(11 downto 8);
                else
                    VGA_G <= test_pattern_ROM(xpos - horizontal_back_porch + offset)(7 downto 4);
                    VGA_B <= test_pattern_ROM(xpos - horizontal_back_porch + offset)(3 downto 0);
                    VGA_R <= test_pattern_ROM(xpos - horizontal_back_porch + offset)(11 downto 8);
                end if;
                    
            else
                VGA_G <= (others => '0');
                VGA_B <= (others => '0');
                VGA_R <= (others => '0');
            end if;
        else
            VGA_G <= (others => '0');
            VGA_B <= (others => '0');
            VGA_R <= (others => '0');
        end if;
    end process;

end architecture;