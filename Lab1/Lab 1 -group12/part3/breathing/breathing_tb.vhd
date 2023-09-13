library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity breathing_tb is
end breathing_tb;

architecture sim of breathing_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;
    signal clock: std_logic := '1';
    signal rst : std_logic := '1';
    signal led_out : std_logic_vector(7 downto 0) := (others => '0');

begin

    clock <= not clock after clk_period / 2;

    DUT : entity work.breathing(rtl)
    port map (
        clock => clock,
        rst => rst,
        led_out => led_out
    );

    SEQUENCER_PROC : process
    begin
        rst <= '1';
        wait for clk_period * 2;

        rst <= '0';

        wait for clk_period * 50000000;
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;