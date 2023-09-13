library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity luminance_tb is
end luminance_tb;

architecture sim of luminance_tb is
    constant pwm_res : integer := 8;
    constant clk_hz : integer := 100000;
    constant clk_period : time := 1 sec / clk_hz;
    constant maxcount : std_logic_vector(pwm_res -1 downto 0) := (others => '1');

    signal clock : std_logic := '0';
    signal rst : std_logic := '1';
    signal pwm_count : std_logic_vector(pwm_res - 1 downto 0) := (others => '0');
    signal duty_cycle: std_logic_vector(pwm_res - 1 downto 0) := (others => '0');

begin

    clock <= not clock after clk_period / 2;

    DUT : entity work.luminance(rtl)
    port map (
        clock => clock,
        rst => rst,
        pwm_count => pwm_count,
        duty_cycle => duty_cycle
    );

    process(clock)
    begin
        if rising_edge(clock) then
            pwm_count <= std_logic_vector(unsigned(pwm_count) +1);
        end if;
    end process;

    SEQUENCER_PROC : process
    begin
        wait for clk_period * 2;

        rst <= '0';

        wait for clk_period * 100000;
        
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;