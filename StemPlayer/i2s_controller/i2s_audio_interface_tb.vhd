library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity i2s_audio_interface_tb is
end i2s_audio_interface_tb;

architecture sim of i2s_audio_interface_tb is

    --FPGA clock
    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;

    --LR Clock constants
    constant lr_hz : integer := 41100; --41.1 kHz
    constant lr_period : time := 1 sec / lr_hz;

    --Bit clock (BCLK) constants
    constant bclk_hz : integer := 2630400; -- 2.6304 MHz
    constant bclk_period : time := 1 sec / bclk_hz;

    -- use below for generics
    constant bit_depth : integer := 16;
    constant data_width : integer := 32;
    constant burst_size : integer := 16;

    signal clk : std_logic := '1';

    signal bclk, lrclk : std_logic := '1';
    signal sdata_out : std_logic;

    --signal S_AXIS_ACLK : std_logic := '1';
    signal S_AXIS_ARESETN : std_logic := '0';
    signal S_AXIS_TVALID : std_logic := '0';
    signal S_AXIS_TLAST : std_logic := '0';
    signal S_AXIS_TDATA : std_logic_vector(data_width-1 downto 0) := (others => '0');
    signal S_AXIS_TREADY : std_logic := '0';


begin

    clk <= not clk after clk_period / 2; --FPGA clk process
    bclk <= not bclk after bclk_period / 2; --Bit clock process

    process --to generate LR clock, use bclk and count 32 cycles
    begin
      lrclk <= not lrclk;
      for i in 1 to 32 loop  --64 samples, but only 16 used in I2S protocol for each left and right channel
        wait until falling_edge(bclk); --Constantly generating 0XAAAAA (i.e. A = 1010)
      end loop;
    end process;

    -- process for generating T_VALID
    ---process(S_AXIS_TREADY)
    ---begin
    ---    if S_AXIS_TREADY = '1' then
   ---         S_AXIS_TVALID <= '1';
    ---        S_AXIS_TDATA <= 0x"AAAAFFFF";
     ---   else
     ---       S_AXIS_TVALID <= '0';
     ---   end if;
    --end process;

    DUT : entity work.i2s_audio_interface(rtl)
    generic map(
        data_width => data_width, burst_size => burst_size
    )
    port map (
        -- PORTS FOR AXIS (Streaming) Interface
        S_AXIS_ACLK => clk,
        S_AXIS_ARESETN  => S_AXIS_ARESETN,
        S_AXIS_TVALID  => S_AXIS_TVALID,
        S_AXIS_TLAST  => S_AXIS_TLAST,
        S_AXIS_TDATA  => S_AXIS_TDATA,
        S_AXIS_TREADY  => S_AXIS_TREADY,
        --ADAU1761 Interface
        bclk  => bclk,
        lrclk  => lrclk,
        sdata_out  => sdata_out
    );

    SEQUENCER_PROC : process
    begin
        wait for bclk_period * 2;

        S_AXIS_ARESETN <= '1'; -- note: active low reset

        wait for bclk_period * 10;

        --wait until S_AXIS_TREADY = '1';
        S_AXIS_TVALID <= '1';
        S_AXIS_TDATA <= x"AAAAFFFF";

        wait until S_AXIS_TREADY = '0';

        S_AXIS_TVALID <= '1';
        S_AXIS_TDATA <= x"0000BBBB";

        wait until S_AXIS_TREADY = '0';

        S_AXIS_TVALID <= '1';
        S_AXIS_TDATA <= x"EEEE5555";

        wait until S_AXIS_TREADY = '0';

        S_AXIS_TVALID <= '1';
        S_AXIS_TDATA <= x"1111CCCC";

        wait until S_AXIS_TREADY = '0';

        -- NOW DO A BURST OF LESS THAN 16 PACKETS
        S_AXIS_TVALID <= '1';
        S_AXIS_TDATA <= x"55551111";
        wait until S_AXIS_TREADY = '1'; 

        wait for clk_period * 3;
        S_AXIS_TVALID <= '1';
        S_AXIS_TLAST <= '1';
        S_AXIS_TDATA <= x"1111EEEE";

        wait for clk_period * 1;

        S_AXIS_TVALID <= '0';
        S_AXIS_TDATA <= x"00000000";

        wait until S_AXIS_TREADY = '1';
        
        wait for lr_period * 100;
        assert false
            report "Test Ok :)"
            severity failure;

        finish;
    end process;

end architecture;