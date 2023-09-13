library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity final_controller is
    generic(
        pwm_res : integer := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        sawtooth_enable : in std_logic;
        breathing_enable : in std_logic;
        led_out : out std_logic_vector(pwm_res-1 downto 0)
    );
end final_controller;

architecture rtl of final_controller is
component breathing is
    port (
        clock : in std_logic;
        rst : in std_logic;
        led_out : out std_logic_vector(7 downto 0)
    );
end component;
component sawtooth is
    port (
        clock : in std_logic;
        rst : in std_logic;
        led_out : out std_logic_vector(7 downto 0)
    );
end component;
signal breathing_out : std_logic_vector(pwm_res - 1 downto 0);
signal sawtooth_out : std_logic_vector(pwm_res -1 downto 0);
begin

    Obj1: breathing
    port map(
        clk => clock,
        rst => rst,
        led_out => breathing_out
    );

    Obj2: sawtooth
    port map(
        clk => clock,
        rst => rst,
        led_out => sawtooth_out
    );

    process(sawtooth_enable, breathing_enable)
    begin
        if sawtooth_enable = '1' AND breathing_enable = '0' then
            led_out <= sawtooth_out;
        elsif breathing_enable = '1' AND sawtooth_enable = '0' then
            led_out <= breathing_out;
        else
            led_out <= (others => '0');
        end if;
    end process;

end architecture;