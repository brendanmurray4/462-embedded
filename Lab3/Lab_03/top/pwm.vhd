library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is
    generic(
        pwm_res : integer := 8
    );
    port (
        clock : in std_logic;
        rst: in std_logic;
        duty_cycle : in std_logic_vector(pwm_res - 1  downto 0);
        pwm_count : out std_logic_vector(pwm_res - 1  downto 0) := (others => '0');
        pwm_out : out std_logic := '0'
    );
end pwm;

architecture rtl of pwm is
    constant maxvalue : std_logic_vector(pwm_res - 1 downto 0) := (others => '1');
    signal sig_count : std_logic_vector(pwm_res - 1 downto 0) := (others => '1');
    signal sig_out : std_logic := '0';
begin
    process(clock, rst) is
    begin
        if rising_edge(clock) then --synchronous reset
            if rst = '1' then
                sig_count <= (others => '0');
                sig_out <= '0';
            else
                if sig_count <= duty_cycle then --ouput a high signal when our count is within the active range
                    sig_out <= '1';
                else                --output low when our count is outside the range
                    sig_out <= '0';
                end if;
                sig_count <= std_logic_vector(unsigned(sig_count) + 1);
            end if; 
        end if;
    end process;
    pwm_count <= sig_count;
    pwm_out <= sig_out;
end architecture;