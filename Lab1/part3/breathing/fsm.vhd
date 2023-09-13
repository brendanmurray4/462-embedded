library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fsm is
    generic(
        pwm_res : integer := 8
    );
    port (
        clock : in std_logic;
        pwm_count : in std_logic_vector(pwm_res -1 downto 0);
        rst : in std_logic;
        duty_cycle : out std_logic_vector(pwm_res - 1 downto 0)
    );
end fsm;

architecture rtl of fsm is
    type t_state is (incr, decr);
    signal state : t_state := decr;
    signal addr : integer range 0 to 127 := 127;
    signal is_decring : std_logic; -- 
    constant minaddr: integer := 0;
    constant maxaddr: integer := 127;
    constant maxpwm : std_logic_vector(pwm_res -1 downto 0):= (others => '1');
    type rom_type is array (0 to 127) of unsigned(pwm_res - 1 downto 0);

    function create_rom return rom_type is
        variable rom_v : rom_type; --return type
        variable angle : real;
        variable sin_scaled : integer;
        begin
        for i in minaddr to maxaddr loop 
            angle := real(i+(2**pwm_res/4))*real(2)*real(MATH_PI)/real(2)**real(pwm_res);
            sin_scaled := integer(ceil(((real(1.0) + real(sin(angle)))*(real(2**pwm_res) - real(1)))/real(2.0)));
            rom_v(i) := to_unsigned(sin_scaled, duty_cycle'length);
        end loop;
        return rom_v;
    end function;
    
    constant rom : rom_type := create_rom; --creates a constant called rom of type rom_type, instantiated with the function create_rom
       
begin

    process(clock)
    begin
        if rising_edge(clock) then
            if rst = '1' then
                state <= decr;
                addr <= maxaddr;
            else
				case state is 
					when decr =>
						if addr = minaddr then
							state <= incr;
                            if pwm_count = maxpwm then
                                addr <= addr + 1;
                            else
                                addr <= addr;
                            end if;
						else
							state <= decr;
                            if pwm_count = maxpwm then
                                addr <= addr - 1;
                            elsif rst = '1' then
                                addr <= maxaddr;
                            else
                                addr <= addr;
                            end if;
						end if;
					when incr =>
						if addr = maxaddr then
							state <= decr;
                            if pwm_count = maxpwm then
                                addr <= addr - 1;
                            elsif rst = '1' then
                                addr <= maxaddr;
                            else
                                addr <= addr;
                            end if;
						else
							state <= incr;
                            if pwm_count = maxpwm then
                                addr <= addr + 1;
                            else
                                addr <= addr;
                            end if;
						end if;
				end case;
            end if;   
        end if;
    end process;

    --process(clock)
    --begin
        --if rising_edge(clock) then
        --    if 
        --end if;
    --end process;
	
	-- mealy part of FSM - addr is an FSM output dependent on both state and inputs pwm_count and rst
	--process(state, pwm_count, rst)
	--begin
		--case state is
			--when decr =>
				--if pwm_count = maxpwm then
				--	addr <= addr - 1;
				--elsif rst = '1' then
				--	addr <= maxaddr;
				--else
				--	addr <= addr;
				--end if;
			--when incr =>
				--if pwm_count = maxpwm then
				--	addr <= addr + 1;
				--else
				--	addr <= addr;
				--end if;
		--end case;
	--end process;
 
	duty_cycle <= std_logic_vector(rom(addr));
end architecture;