library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  generic (
    clk_hz : integer := 100e6;
    sclk_hz : integer := 4e6;
    clk_counter_bits : integer := 24 --for ready_fsm to periodically generate ready signal for chip
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    miso : in std_logic;
    cs : out std_logic;
    sclk : out std_logic;
    led_out : out std_logic_vector(7 downto 0)
  );
end top;

architecture rtl of top is

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

  component spi_controller is
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
  end component;

  component reset_sync is
    generic (
      -- Clock cycles to hold rst_out for after rst_in is released
      rst_strobe_cycles : positive := 128;
  
      -- The polarity of rst_in when reset is active
      rst_in_active_value : std_logic := '1';
  
      -- The desired polarity of rst_out when active
      rst_out_active_value : std_logic := '1'
    );
    port (
      clk : in std_logic; -- Slowest clock that uses rst_out
      rst_in : in std_logic;
      rst_out : out std_logic := rst_out_active_value
    );
  end component;

  signal rst_syncd : std_logic;
  -- SPI controller signals
  signal spi_data : std_logic_vector(7 downto 0);
  signal ready : std_logic;
  signal valid : std_logic;
  --pwm signals
  signal prescalar_out : std_logic; 
  signal led_1b : std_logic;
  signal pwm_count_sig : std_logic_vector(7 downto 0);



  --------------    READY FSM PROCESS SIGNALS   -------------------------
  -- This counter controls how often samples are fetched and sent
  signal clk_counter : unsigned(clk_counter_bits - 1 downto 0);

  type state_type is (WAITING, RECEIVING, SENDING); 
  signal state : state_type;

begin

  led_out <= (others => led_1b);

  --port map DUT/ instantiate components here -----------------------
  prescalar2 : prescalar 
    GENERIC MAP (fpga_clk => clk_hz,
                 pwm_clk => 20000,
                 pwm_res => 8
    )
    PORT MAP (clk => clk,
              rst => rst,
              clock => prescalar_out
    );

    pwm1 : pwm
      generic map(
          pwm_res => 8
      )
      port map (
          clock => prescalar_out,
          rst => rst_syncd,
          duty_cycle => spi_data,
          pwm_count => pwm_count_sig,
          pwm_out => led_1b
      );

      spi_controller1 : spi_controller
        generic map (
            clk_hz => clk_hz,
            total_bits => 16,
            sclk_hz => sclk_hz
            )
        port map (
            --fpga system
            clk => clk,
            rst => rst_syncd,
            -- slave chip
            cs => cs,
            sclk => sclk,
            miso => miso,
            -- Internal interface when obtaining data back from slave chip
            ready => ready,
            valid => valid,
            data => spi_data
        );

      reset_sync1 : reset_sync
        generic map(
          -- Clock cycles to hold rst_out for after rst_in is released
          rst_strobe_cycles => 8,
          -- The polarity of rst_in when reset is active
          rst_in_active_value => '1',
          -- The desired polarity of rst_out when active
          rst_out_active_value => '1'
        )
        port map(
          clk => prescalar_out, -- Slowest clock that uses rst_out
          rst_in => rst,
          rst_out => rst_syncd
        );


   READY_FSM_PROC : process(clk)
    begin
      if rising_edge(clk) then
        if rst_syncd = '1' then
          clk_counter <= (others => '0');
          state <= WAITING;
          ready <= '0';
          
        else
          clk_counter <= clk_counter + 1;
        
          case state is
            
            -- Wait for some time
            when WAITING =>
              -- If every bit in clk_counter is a '1'
              if signed(clk_counter) = to_signed(-1, clk_counter'length) then
                state <= RECEIVING;
                ready <= '1';
              end if;

            -- Fetch the results from the ambient light sensor
            when RECEIVING =>
              if valid = '1' then
                state <= WAITING;
                ready <= '0';
              end if;
            
            -- Wait until the UART module acknowledges the transfer
            when SENDING =>
              -- If timed out
              if clk_counter = 0 then
                state <= WAITING;
              end if;       
          end case;
        end if;
      end if;
    end process;

end architecture;