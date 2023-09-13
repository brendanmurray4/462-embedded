library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2S_audio_interface is
    port (
        ip_clk : in std_logic; -- our IP clock
        bclk, lrclk, sdata_in : in std_logic; -- I2S interface block inputs
        audio_l_adau, audio_r_adau,  : in std_logic_vector(23 DOWNTO 0); -- parallel audio inputs L & R
        audio_valid_adau : in std_logic; -- valid input for parallel audio inputs
        audio_l_pl, audio_r_pl : out std_logic_vector(23 DOWNTO 0); -- parallel audio outputs L & R
        audio_valid_pl :  out std_logic; --valid output for parallel audio inputs
        sdata_out : out std_logic -- I2S interface block output
    );
end I2S_audio_interface;

architecture rtl of I2S_audio_interface is
    -- signals for audio data L & R and valid
    signal audio_l_temp_sig : std_logic_vector(23 DOWNTO 0);
    signal audio_r_temp_sig : std_logic_vector(23 DOWNTO 0);
    signal audio_valid_temp_sig : std_logic;
    signal audio_l_pl_captured, audio_r_pl_captured : std_logic_vector(23 DOWNTO 0);
    signal audio_tx_sig : std_logic; -- serialized signal from TX

    -- rising edge detection
    function rising(data : std_logic_vector(2 downto 1)) return boolean is
    begin
        if data = "01" then
            return true;
        else
            return false;
        end if;
    end function;

    -- falling edge detection
    function falling(data : std_logic_vector(2 downto 1)) return boolean is
    begin
        if data = "10" then
            return true;
        else
            return false;
        end if;
    end function;

    -- signals for synchronizer (serial chain of 3 flip flops)
    signal bclk_sync : std_logic_vector(2 downto 1);
    signal bclk_sync_chain : std_logic_vector(2 downto 0) := (others => '0');
    signal lrclk_sync : std_logic_vector(2 downto 1);
    signal lrclk_sync_chain : std_logic_vector(2 downto 0) := (others => '0');
    signal sdata_sync : std_logic;
    signal sdata_sync_chain : std_logic_vector(2 downto 0) := (others => '0');

    -- states
    type t_state is (0, 1, 2, 3, 4, 5, 6, 7);
    signal rx_state, tx_state : t_state := 0;
    
    -- signals for FSM counting
    signal samp_bit_count : integer range 0 to 23 := 23;

begin

    -- Synchronize : chain of 3 flip flops for each input
    Synchronize: process(clk, rst)
    begin
        if rst = '1' then
            bclk_sync <= "00";
            bclk_sync_chain <= (others => '0');
            lrclk_sync <= "00";
            lrclk_sync_chain <= (others => '0');
            sdata_sync <= '0';
            sdata_sync_chain <= (others => '0');
        elsif rising_edge(clk)
            bclk_sync_chain(1 downto 0) & bclk;
            lrclk_sync_chain(1 downto 0) & lrclk;
            sdata_sync_chain(1 downto 0) & sdata_in;
        end if;
    bclk_sync <= bclk_sync_chain(2 downto 1);
    lrclk_sync <= lrclk_sync_chain(2 downto 1);
    sdata_sync <= sdata_sync_chain(2);
    end process;

    -- deserialize process (RX)
    RX_deserializing : process(ip_clk)
    begin
        if rising_edge(ip_clk) then
            case rx_state is
                when 0 =>
                    samp_bit_count <= 24;
                    audio_valid_temp_sig <= '0';
                    if falling(lrclk_sync) then
                        rx_state <= 1;
                    else
                        rx_state <= 0;
                    end if;

                when 1 =>
                    if rising(bclk_sync) then
                        rx_state <= 2;
                    else
                        rx_state <= 1;
                    end if;

                when 2 => -- this state is for left channel bit extraction/sampling
                    if rising(bclk_sync) then
                        rx_state <= 2;
                        if samp_bit_count >= 1 then
                            audio_l_temp_sig(samp_bit_count -1) <= sdata_sync;
                            samp_bit_count <= samp_bit_count -1;
                        end if;
                    elsif rising(lrclk_sync) then
                        rx_state <= 3;
                    else
                        rx_state <= 2;
                    end if;

                when 3 =>
                    samp_bit_count <= 24;
                    if rising(bclk_sync) then
                        rx_state <= 4;
                    else
                        rx_state <= 3;
                    end if;
                        
                when 4 => -- this state is for right channel bit extraction/sampling
                    if rising(bclk_sync) then -- ready to sample right channel
                        rx_state <= 4;
                        if samp_bit_count >= 1 then
                            audio_r_temp_sig(samp_bit_count -1) <= sdata_sync;
                            samp_bit_count <= samp_bit_count -1;
                        end if;
                    elsif falling(lrclk_sync) then
                        rx_state <= 5;
                    else
                        rx_state <= 4;
                    end if;

                when 5 =>
                    audio_valid_temp_sig <= '1';
                    rx_state <= 0;
                    
            end case;
        end if;
    end process;
    
    -- assign RX signals to outputs
    audio_l_pl <= audio_l_temp_sig;
    audio_r_pl <= audio_r_temp_sig;
    audio_valid_pl <= audio_valid_temp_sig;


    -- capture the valid parallel data from RX deserializer
    pardata_capture : process(ip_clk)
    begin
        if rising_edge(ip_clk) then
            if audio_valid_adau = '1' then
                audio_l_pl_captured <= audio_l_pl;
                audio_r_pl_captured <= audio_r_pl;
            else
                audio_l_pl_captured <= audio_l_pl_captured;
                audio_r_pl_captured <= audio_r_pl_captured;
            end if;
        end if;
    end process;
            

    -- Serialize process (TX)
    TX_serializing : process(ip_clk)
    begin
        if rising_edge(ip_clk) then
            case tx_state is
                when 0 =>
                    samp_bit_count <= 24;
                    if falling(lrclk_sync) then
                        tx_state <= 1;
                    else
                        tx_state <= 0;
                    end if;

                when 1 =>
                    if rising(bclk_sync) then
                        tx_state <= 2;
                    else
                        tx_state <= 1;
                    end if;

                when 2 => -- this state is for left channel serializing
                    if falling(bclk_sync) then
                        tx_state <= 2;
                        if samp_bit_count >= 1 then
                            audio_tx_sig <= audio_l_pl_captured(samp_bit_count);
                            samp_bit_count <= samp_bit_count -1;
                        end if;
                    elsif rising(lrclk_sync) then
                        tx_state <= 3;
                    else
                        tx_state <= 2;
                    end if;

                when 3 =>
                    samp_bit_count <= 23;
                    if rising(bclk_sync) then
                        tx_state <= 4;
                    else
                        tx_state <= 3;
                    end if;
    end process;
end architecture;