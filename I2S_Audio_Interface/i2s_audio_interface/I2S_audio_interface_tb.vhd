library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity I2S_audio_interface_tb is
end I2S_audio_interface_tb;

architecture sim of I2S_audio_interface_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;
    constant lrclk_hz : integer := 48e3;
    constant lrclk_period : time := 1 sec/ lrclk_hz;
    constant bclk_hz : integer := 3072e3;
    constant bclk_period : time := 1 sec/ bclk_hz;
    constant sdata_hz : integer := 100e3;
    constant sdata_period : time := 1 sec / sdata_hz;
    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal lrclk: std_logic := '1';
    signal bclk: std_logic := '1';
    signal audio_valid_adau,  audio_valid_pl :  std_logic := '0';
    signal audio_l_pl, audio_r_pl : std_logic_vector(23 DOWNTO 0) := (others => '0');
    signal sdata_in, sdata_out : std_logic := '0';
begin

    clk <= not clk after clk_period / 2;
    lrclk <= not lrclk after lrclk_period / 2;
    bclk <= not bclk after bclk_period / 2;
    DUT : entity work.I2S_audio_interface(rtl)
    port map (
        ip_clk => clk,
        rst => rst,
        lrclk => lrclk,
        bclk => bclk,
        audio_l_adau => audio_l_pl,
        audio_r_adau => audio_r_pl,
        audio_valid_adau => audio_valid_pl,
        audio_valid_pl => audio_valid_pl,
        audio_l_pl => audio_l_pl,
        audio_r_pl => audio_r_pl,
        sdata_in => sdata_in,
        sdata_out => sdata_out
    );

    SEQUENCER_PROC : process
    begin
        wait for clk_period * 2;
        rst <= '0';
        for i in 0 to 7 loop
            sdata_in <=
            wait for clk_period * 10e5;    
        end loop;
        wait for clk_period * 1e6;
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;