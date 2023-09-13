library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_controller is
    generic (
        clk_hz : integer; --FPGA clock - 100 MHz
        total_bits : integer; --total bits tx by sensor chip
        sclk_hz : integer --sensor’s frequency - 4 MHz
        ); 
    port (
        --fpga system
        clk : in std_logic;
        rst : in std_logic;
        -- slave chip
        cs : out std_logic;
        sclk : out std_logic;
        miso : in std_logic;
        -- Internal interface when obtaining data back from slave chip
        ready : in std_logic;
        valid : out std_logic;
        data : out std_logic_vector(7 downto 0)
    );
end spi_controller;

architecture rtl of spi_controller is
    component prescalar is
        generic (fpga_clk : integer;
                pwm_clk : integer;
                pwm_res : integer
                );
        port (
            clk : in std_logic;
            rst : in std_logic;
            clock: out std_logic
        );
    end component;

    --Synchronize input: shift right using flip-flops
    procedure sync(signal clk : in std_logic; 
        signal rst : in std_logic;
        signal sig : in std_logic;
        signal vec : inout std_logic_vector(2 downto 0)) is
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    vec <= (others => '0');
                else
                    vec <= sig & vec(vec'high downto vec'low+1);
                end if;
            end if; 
    end procedure;

    -- rising function
    function rising(vec : std_logic_vector(2 downto 0)) return boolean is
        begin
            return vec(1 downto 0) = "10";
    end function;

    --returns true if falling edge on vec
    function falling(vec : std_logic_vector(2 downto 0)) return boolean is
        begin
            return vec(1 downto 0) = "01";
        end function;

    type state_type is (IDLE, TRANSMISSION);
    signal state : state_type;
    signal prescalar_out : std_logic := '0';
    signal bit_count : integer range 0 to total_bits := 0;
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal miso_p, prescalar_out_p : std_logic_vector(2 downto 0);
begin

    MISO_SYNC_PROC : sync(clk, rst, miso, miso_p);
    PRESCALER_OUT_SYNC_PROC : sync(clk, rst, prescalar_out, prescalar_out_p);

    prescalar1 : prescalar 
    GENERIC MAP (fpga_clk => clk_hz,
                 pwm_clk => sclk_hz,
                 pwm_res => 1
    )
    PORT MAP (clk => clk,
              rst => rst,
              clock => prescalar_out
    );


    fsm : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                sclk <= '1';
                cs <= '1';
                shift_reg <= (others => '0');
            else
                case state is
                    when IDLE =>
                        if ready = '1' then
                            bit_count <= 0;
                            cs <= '0';
                            state <= TRANSMISSION;
                        end if;
                    
                    when TRANSMISSION =>
                        sclk <= prescalar_out;
                        valid <= '0';
                        if falling(prescalar_out_p) then
                            if bit_count /= total_bits then
                                bit_count <= bit_count +1;
                            else
                                sclk <= '1';
                                cs <= '1';
                                state <= IDLE;
                            end if;  
                        elsif rising(prescalar_out_p) then
                            if bit_count > 2 AND bit_count < (total_bits - 4) then
                                -- place incoming data into 8 bit shift register (left shift)
                                shift_reg <=  shift_reg(shift_reg'high-1 downto shift_reg'low) & miso_p(2); 
                            elsif bit_count = (total_bits - 4) then
                                valid <= '1';
                                data <= shift_reg;
                            elsif bit_count = (total_bits - 3) then
                                valid <='0';
                            end if;
                        end if; 
                end case;
            end if;
        end if;
    end process;
end architecture;