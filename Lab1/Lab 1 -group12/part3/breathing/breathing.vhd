library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity breathing is
    port (
        clock : in std_logic;
        rst : in std_logic;
        led_out : out std_logic_vector(7 downto 0)
        --out_pwm_count : out std_logic_vector(7 downto 0) := (others => '0');
        --out_duty_cycle : out std_logic_vector(7 downto 0):= (others => '0')
    );
end breathing;

architecture rtl of breathing is
component prescalar is
    generic (fpga_clk : integer;
            pwm_clk : integer;
            pwm_res : integer
            );
    port (
        clk : in std_logic;
        rst : in std_logic;
        clock: out std_logic := '0'
    );
end component;
component pwm is
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
end component;
component fsm is 
    generic(
        pwm_res : integer := 8
    );
    port (
        clock : in std_logic;
        pwm_count : in std_logic_vector(pwm_res -1 downto 0);
        rst : in std_logic;
        duty_cycle : out std_logic_vector(pwm_res - 1 downto 0)
    );
end component;
signal prescale_clock: std_logic;
signal pwm_count: std_logic_vector(7 downto 0);
signal duty_cycle: std_logic_vector(7 downto 0);
signal pwm_out: std_logic;
begin

    Obj1: prescalar
    generic map(
        fpga_clk => 100000000,
        pwm_clk => 100,
        pwm_res => 8
    )
    port map(
        clk => clock,
        rst => rst,
        clock => prescale_clock
    );

    Obj2: fsm
    generic map(
        pwm_res => 8
    )
    port map(
        clock => prescale_clock,
        pwm_count => pwm_count,
        rst => rst,
        duty_cycle => duty_cycle
    );

    Obj3: pwm
    generic map(
        pwm_res => 8
    )
    port map(
        clock => prescale_clock,
        rst => rst,
        duty_cycle => duty_cycle,
        pwm_count => pwm_count,
        pwm_out => pwm_out
    );

    led_out <= (others => pwm_out);
    --out_pwm_count <= pwm_count;
    --out_duty_cycle <= duty_cycle;
end architecture;