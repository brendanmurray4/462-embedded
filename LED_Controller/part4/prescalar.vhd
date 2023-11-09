library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prescalar is
    generic (fpga_clk : integer;
            pwm_clk : integer;
            pwm_res : integer
            );
    port (
        clk : in std_logic;
        rst : in std_logic;
        clock: out std_logic := '0'
    );
end prescalar;

architecture rtl of prescalar is
    constant maxcount : integer := fpga_clk / (pwm_clk*((2**pwm_res)-1)); 
    signal count : integer := 0;
    signal sig_clk : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then -- synchronous reset
            if rst ='1' then
                count <= 0;
            else
                count <= count + 1; --increment our count
                if count >= maxcount/2 then --to create a proper clock pulse, have our signal be high for half the clock time
                    sig_clk <= not sig_clk;
                    count <= 0;
                else
                    sig_clk <= sig_clk;
                end if;
            end if;
        end if;
    end process; 
    clock <= sig_clk;
end architecture;