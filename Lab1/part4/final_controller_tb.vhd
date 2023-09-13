library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity final_controller_tb is
end final_controller_tb;

architecture sim of final_controller_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;
    signal sawtooth_enable : std_logic:= '0';
    signal breathing_enable :std_logic := '0';
    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal led_out : std_logic_vector(7 downto 0);

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.final_controller(rtl)
    port map (
        clock => clk,
        rst => rst,
        sawtooth_enable => sawtooth_enable,
        breathing_enable => breathing_enable,
        led_out => led_out
    );


    SEQUENCER_PROC : process
    begin
        wait for clk_period * 2;
        rst <= '0';
        wait for clk_period * 2000000;
        sawtooth_enable <= '1';
        wait for clk_period * 6000000;
        breathing_enable <= '1';
        wait for clk_period * 2000000;
        rst <= '1';
        wait for clk_period * 2000000;
        rst <= '0';
        sawtooth_enable <= '0';
        wait for clk_period * 6000000;
        rst <= '1';
        wait for clk_period * 2000000;
        rst <= '0';
        breathing_enable <= '0';
        wait for clk_period * 2000000;
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;