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
    -- signals to connect parallel audio signals L & R and valid outputs to inputs for now
    signal audio_l_par_sig : std_logic_vector(23 DOWNTO 0);
    signal audio_r_par_sig : std_logic_vector(23 DOWNTO 0);
    signal audio_valid_par_sig : std_logic;
begin

end architecture;