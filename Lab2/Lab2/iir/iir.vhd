library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir is
    generic(bit_width : integer := 24;
    width_internal : integer := 32;
    a0 : in integer;
    a1 : in integer;
    a2 : in integer;
    b1 : in integer;
    b2 : in integer
    );
    port (
    clk : in std_logic;
    rst : in std_logic;
    valid : in std_logic;
    x : in std_logic_vector(bit_width-1 downto 0);
    y : out std_logic_vector(bit_width-1 downto 0);
    valid_out : out std_logic
    );
end iir;

architecture rtl of iir is
    signal  ff0, ff1, ff2, fb0, fb1, fb2: signed (width_internal - 1 downto 0) := (others => '0');
    signal ff0gain, ff1gain, ff2gain, fb1gain, fb2gain, fb12sum, ff12sum, fftotal: signed (width_internal -1 downto 0) := (others => '0');
    signal validx : signed(width_internal-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ff1 <= (others => '0');
                ff2 <= (others => '0');
                fb1 <= (others => '0');
                fb2 <= (others => '0');
            end if;
            if valid = '1' then
                ff1 <= validx;
                ff2 <= ff1;
                fb1 <= fb0;
                fb2 <= fb1;
            end if;
            valid_out <= valid; 
        end if;
    end process;
    
    VALIDATE: process(valid, x, fb0)
    begin
        if valid = '1' then
            validx <= resize(signed(x), validx'length);
            y <= std_logic_vector(resize(fb0, y'length));
        end if;
    end process;

    FEEDFORWARD : process(validx, ff1, ff2, ff1gain, ff2gain, ff12sum, ff0gain)
    begin
        ff0gain <= resize(shift_right(a0 * validx, 30), ff0gain'length);
        ff1gain <= resize(shift_right(ff1 * a1, 30), ff1gain'length);
        ff2gain <= resize(shift_right(ff2 * a2, 30), ff2gain'length);

        ff12sum <= ff1gain + ff2gain;
        fftotal <= ff12sum + ff0gain;
    end process;

    FEEDBACK : process(fb1, fb2, fb1gain, fb2gain, fftotal, fb12sum)
    begin
        fb1gain <= resize(shift_right(fb1 * (-1) * b1, 30), fb1gain'length);
        fb2gain <= resize(shift_right(fb2 * (-1) * b2, 30), fb2gain'length);

        fb12sum <= fb1gain + fb2gain;
        fb0 <= fftotal + fb12sum;
    end process;

end architecture;