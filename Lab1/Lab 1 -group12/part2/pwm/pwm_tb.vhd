library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity pwm_tb is
end pwm_tb;

architecture sim of pwm_tb is
    constant pwm_res : integer := 8;
    constant clk_hz : integer := 1000;
    constant clk_period : time := 1 sec / clk_hz;
    constant maxcount : std_logic_vector(7 downto 0) := (others => '1');

    signal rst : std_logic := '1';
    signal clock : std_logic := '0';
    signal duty_cycle : std_logic_vector(pwm_res - 1  downto 0) := (others => '0');
    signal pwm_count : std_logic_vector(pwm_res - 1  downto 0) := (others => '0');
    signal pwm_out : std_logic := '0';

begin

    clock <= not clock after clk_period / 2;

    DUT : entity work.pwm(rtl)
    generic map(
        pwm_res => 8
    )
    port map (
        rst => rst,
        clock => clock,
        duty_cycle => duty_cycle,
        pwm_count => pwm_count,
        pwm_out => pwm_out
        
    );

    process(pwm_count)
    begin
        if pwm_count = maxcount then
            duty_cycle <= std_logic_vector(unsigned(duty_cycle) + 1);
        end if;
    end process;

    SEQUENCER_PROC : process
    begin
        wait for clk_period * 2;
        rst <= '0';

        wait for clk_period * 600000;
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;