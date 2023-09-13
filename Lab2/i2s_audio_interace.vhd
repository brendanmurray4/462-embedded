library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity is2_audio_interface is
    port (
        clk : in std_logic;
        rst : in std_logic;
        sdata_in : in std_logic;
        sdata_out : out std_logic;
        bclk : in std_logic;
        lrclk : in std_logic;
        audio_l_pl, audio_r_pl : out std_logic_vector(23 downto 0);
        audio_valid_pl : out std_logic;
        audio_l_adau, audio_r_adau : in std_logic_vector(23 downto 0);
        audio_valid_adau: in std_logic
    );
end is2_audio_interface;

architecture rtl of is2_audio_interface is
    function rising(data : std_logic) return std_logic is
    begin

    end function;
    function falling(data : std_logic) return std_logic is
    begin

    end function;
    signal bclk_sync : std_logic;
    signal bclk_sync_chain : std_logic_vector(2 downto 0) := (others => '0');
    signal lrclk_sync : std_logic;
    signal lrclk_sync_chain : std_logic_vector(2 downto 0) := (others => '0');
    signal sdata_sync : std_logic;
    signal sdata_sync_chain : std_logic_vector(2 downto 0) := (others => '0');
begin

    Synchronize: process(clk, rst)
        begin
            if rst = '1' then
                bclk_sync <= '0';
                bclk_sync_chain <= (others => '0');
                lrclk_sync <= '0';
                lrclk_sync_chain <= (others => '0');
                sdata_sync <= '0';
                sdata_sync_chain <= (others => '0');
            elsif rising_edge(clk)
                bclk_sync_chain(1 downto 0) & bclk;
                lrclk_sync_chain(1 downto 0) & lrclk;
                sdata_sync_chain(1 downto 0) & sdata_in;
            end if;
        bclk_sync <= bclk_sync_chain(2);
        lrclk_sync <= lrclk_sync_chain(2);
        sdata_sync <= sdata_sync_chain(2);
    end process;
    
end architecture;