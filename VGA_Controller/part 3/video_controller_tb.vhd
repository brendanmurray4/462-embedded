library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity video_controller_tb is
end video_controller_tb;

architecture sim of video_controller_tb is

    constant clk_hz : integer := 149e6;
    constant clk_period : time := 1 sec / clk_hz;

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal SW7 : std_logic := '0';
    signal SW6 : std_logic := '0';
    signal hsync : std_logic := '1';
    signal vsync : std_logic := '1';
    signal vga_g: std_logic_vector(3 downto 0);
    signal vga_b: std_logic_vector(3 downto 0);
    signal vga_r: std_logic_vector(3 downto 0);

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.video_controller(rtl)
    port map (
        clk => clk,
        rst => rst,
        SW7 => SW7,
        SW6 => SW6,
        hsync => hsync,
        vsync => vsync,
        vga_g => vga_g,
        vga_b => vga_b,
        vga_r => vga_r 
    );

    SEQUENCER_PROC : process
    begin
        wait for clk_period * 2;

        rst <= '0';

        wait until vsync = '0';
        wait for clk_period * 1000;
        wait until vsync = '0';
        -- begin shift left (will wrap)
        SW6 <= '1';
        wait for clk_period * 1e7;
        wait until vsync = '0';
        
        --begin shift right (will wrap again)
        SW7 <= '1';
        SW6 <= '0';
        wait for clk_period * 3e7;

        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;