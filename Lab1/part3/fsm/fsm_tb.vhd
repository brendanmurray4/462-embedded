library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity fsm_tb is
end fsm_tb;

architecture sim of fsm_tb is

    constant clk_hz : integer := 100000;
    constant clk_period : time := 1 sec / clk_hz;

    signal clock : std_logic := '1';
    signal rst : std_logic := '1';
    signal pwm_count : std_logic_vector(7 downto 0) := (others => '0');
    signal duty_cycle : std_logic_vector(7 downto 0) := (others => '0');

begin

    clock <= not clock after clk_period / 2;

    DUT : entity work.fsm(rtl)
    generic map (
        pwm_res => 8
    )
    port map (
        clock => clock,
        rst => rst,
        pwm_count => pwm_count,
        duty_cycle => duty_cycle    
    );

    process(clock)
    begin
        if rising_edge(clock) then
            if rst = '1' then
                pwm_count <= (others => '0');
            else
                pwm_count <= std_logic_vector(unsigned(pwm_count) +1);
            end if;
        end if;
    end process;

    SEQUENCER_PROC : process
    begin
        wait for clk_period * 2;

        rst <= '0';

        wait for clk_period * 500000;
		
		rst <= '1';
		
		wait for clk_period * 4;
		
		rst <= '0';
		
		wait for clk_period * 2;
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;