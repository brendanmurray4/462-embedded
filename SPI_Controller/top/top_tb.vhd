library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity top_tb is
end top_tb;

architecture sim of top_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;

    constant sclk_hz : integer := 4e6; --4MHz
    constant data_bits : integer := 16; --num bits tx by slave

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';

    signal cs : std_logic := 'H';
    signal sclk : std_logic;
    signal miso : std_logic := '0';
    signal ready : std_logic := '0';
    signal valid : std_logic;
    signal data, led_out : std_logic_vector(7 downto 0);

    signal next_sample : unsigned(7 downto 0);

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.top(rtl)
    generic map(
        clk_hz => 100e6,
        sclk_hz => 4e6,
        clk_counter_bits => 6 --for ready_fsm to periodically generate ready signal for chip
    )
    port map (
        clk => clk,
        rst => rst,
        miso => miso,
        cs => cs,
        sclk => sclk,
        led_out => led_out
    );

    BFM : entity work.als_bfm(beh)
    port map (
      next_sample => next_sample,
      cs => cs,
      sclk => sclk,
      miso => miso
    );


    SEQUENCER_PROC : process
    procedure print(constant message : string) is
        variable str : line;
      begin
        write(str, message);
        writeline(output, str);
    end procedure;

    procedure verify(constant d : unsigned(7 downto 0)) is
        begin
          print("Expecting: " & to_string(d));
          next_sample <= d;
          wait for clk_period * 16777215;
          --ready <= '1';
          --wait until valid = '1';
          --ready <= '0';
        end procedure;

    begin
        wait for clk_period * 2;
        print("Releasing reset");
        rst <= '0';

        wait for clk_period * 1000000;

        verifyloop : for i in 0 to 2**(data'length) -1 loop
            verify(to_unsigned(i, 8));
        end loop verifyloop;

        
        --verify("00000001");

        print("Test: Completed");
        finish;
    end process;

end architecture;