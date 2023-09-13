library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity luminance is
    generic (
        pwm_res : integer := 8
    );
    port (
        clock : in std_logic;
        rst : in std_logic;
        pwm_count : in std_logic_vector(pwm_res - 1 downto 0) := (others => '0');
        duty_cycle: out std_logic_vector(pwm_res - 1 downto 0) := (others => '0')
    );
end luminance;

architecture rtl of luminance is
    constant maxvalue : std_logic_vector(pwm_res - 1 downto 0) := (others => '1');
    signal sig_dutycycle : std_logic_vector(pwm_res - 1 downto 0) := (others => '0');
begin
    process(clock,rst) is
    begin
        if rising_edge(clock) then
            if rst = '1' then --synchronous reset, checked on every rising edge
                sig_dutycycle <= (others => '0');
            else
                if pwm_count = maxvalue then --once the pwm has counted enough, increase the duty cycle we are outputting to the pwm
                    sig_dutycycle <= std_logic_vector(unsigned(sig_dutycycle) + 1);
                else
                    sig_dutycycle <= sig_dutycycle;
                end if;
            end if; 
        end if;
    end process;
    duty_cycle <= sig_dutycycle;
end architecture;