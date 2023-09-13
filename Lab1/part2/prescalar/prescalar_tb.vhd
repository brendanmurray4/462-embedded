library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity prescalar_tb is
end prescalar_tb;

architecture sim of prescalar_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal clock : std_logic;

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.prescalar(rtl)
    generic map(
        fpga_clk => 100000000,
        pwm_clk => 100,
        pwm_res => 8
    )
    port map (
        clk => clk,
        rst => rst,
        clock => clock
    );

    SEQUENCER_PROC : process
    begin
        wait for clk_period * 2;

        rst <= '0';

        wait until clock = '1';
        wait until clock = '0';
        wait until clock = '1';
        wait until clock = '0';
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;