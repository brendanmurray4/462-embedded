library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity iir_tb is
    signal clk, rst, valid, valid_out : std_logic := '0';
    signal x, y : std_logic_vector(23 downto 0) := (others => '0');
    signal count : integer  range 0 to 23 := 0;
    constant clk_freq: integer := 1000;
    constant clk_period: time := 1 sec/clk_freq;
end iir_tb;

architecture sim of iir_tb is

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.iir(rtl)
    generic map(bit_width => 24,
    width_internal => 32,
    a0 => 4204906,
    a1 => 8409811,
    a2 => 4204906,
    b1 => -1949206066,
    b2 => 892283864
    )
    port map(
    clk => clk,
    rst => rst,
    valid => valid,
    x => x,
    y => y,
    valid_out => valid_out
    );
    process(clk)
    begin
        if rising_edge(clk) then
            x(count) <= '1';
            if count = 23 then
                count <= 0;
                x <= (others => '0');
            else
                count <= count +1;
            end if;
        end if;
    end process;

    SEQUENCER_PROC : process
    begin
        wait for clk_period * 2;
        valid <= '1';
        rst <= '0';

        wait for clk_period * 50;
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;