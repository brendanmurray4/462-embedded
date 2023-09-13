library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_audio_interface is
    generic (bit_depth : integer := 24);
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        --Internal interface
        audio_valid_pl : out std_logic;
        audio_l_pl : out std_logic_vector(bit_depth - 1 downto 0);
        audio_r_pl : out std_logic_vector(bit_depth - 1 downto 0);
        audio_valid_adau : in std_logic;
        audio_l_adau : in std_logic_vector(bit_depth - 1 downto 0);
        audio_r_adau : in std_logic_vector(bit_depth - 1 downto 0);

        --ADAU1761 Interface
        bclk : in std_logic;
        lrclk : in std_logic;
        sdata_in : in std_logic;
        sdata_out : out std_logic
    );
end i2s_audio_interface;

architecture rtl of i2s_audio_interface is
    --returns true if rising edge on vec
    function rising(vec : std_logic_vector(4 downto 0)) return boolean is
    begin
        return vec(1 downto 0) = "10";
    end function;

    --returns true if falling edge on vec
    function falling(vec : std_logic_vector(4 downto 0)) return boolean is
    begin
        return vec(1 downto 0) = "01";
    end function;

    --shift right using flip-flops
    procedure sync(signal clk : in std_logic; 
                   signal rst : in std_logic;
                   signal sig : in std_logic;
                   signal vec : inout std_logic_vector(4 downto 0)) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                vec <= (others => '0');
            else
                vec <= sig & vec(vec'high downto vec'low+1);
            end if;
        end if; 
    end procedure;

    --Previous/shifted versions of the inputs
    signal bclk_p : std_logic_vector(4 downto 0);
    signal lrclk_p : std_logic_vector(4 downto 0);
    signal sdata_in_p : std_logic_vector(4 downto 0);

    --FSM states for data input
    type state_type is (S0, S1, S2, S3, S4, S5, S6);
    signal state : state_type;

    --FSM states for data output
    type state_type_out is (D0, D1, D2, D3, D4, D5, D6, D7);
    signal state_out : state_type_out;

    --For counting bclk data bits
    signal bit_cnt : integer range 0 to bit_depth - 1;
    signal bit_out : integer range 0 to bit_depth - 1;

    --registered versions of inputs and outputs
    signal in_l_reg : std_logic_vector(bit_depth - 1 downto 0);
    signal in_r_reg : std_logic_vector(bit_depth - 1 downto 0);
    signal audio_l_adau_reg1 : std_logic_vector(bit_depth - 1 downto 0);
    signal audio_l_adau_reg2 : std_logic_vector(bit_depth - 1 downto 0);  
    signal audio_r_adau_reg1 : std_logic_vector(bit_depth - 1 downto 0);   
    signal audio_r_adau_reg2 : std_logic_vector(bit_depth - 1 downto 0);              

begin

    BCLK_SYNC_PROC : sync(clk, rst, bclk, bclk_p);
    LRCLK_SYNC_PROC : sync(clk, rst, lrclk, lrclk_p);
    SDATA_IN_SYNC_PROC : sync(clk, rst, sdata_in, sdata_in_p);

    --samples audio to adau when valid
    SAMPLE_AUDIO_PL_PROC : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                audio_l_adau_reg1 <= (others => '0');
                audio_r_adau_reg1 <= (others => '0');               
            else
                if audio_valid_adau = '1' then --sample the 24bit data
                    audio_l_adau_reg1 <= audio_l_adau;
                    audio_r_adau_reg1 <= audio_r_adau;
                end if;
            end if;
        end if;
    end process;


    FSM_PROC_IN : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= S0;
                --parallel output from serial data in
                audio_valid_pl <= '0';
                audio_l_pl <= (others => '0');
                audio_r_pl <= (others => '0');
                in_l_reg <= (others => '0');
                in_r_reg <= (others => '0');
                bit_cnt <= 0;

            else
                --default value, since valid should only be pulsed
                audio_valid_pl <= '0';

                case state is
                    --wait for lrclk's falling edge (L channel)
                    when S0 =>
                        if falling(lrclk_p) then
                            state <= S1;
                        end if;

                    --wait for bclk rising edge
                    when S1 =>
                        if rising(bclk_p) then
                            state <= S2;
                            bit_cnt <= bit_depth-1;
                        end if;

                    --sample receive data on next bclk rising edge
                    when S2 =>
                        if rising(bclk_p) then
                            if bit_cnt = 0 then
                                state <= S3;
                            else 
                                in_l_reg(bit_cnt) <= sdata_in_p(0);
                                bit_cnt <= bit_cnt - 1;
                            end if;
                        end if;

                    --wait for lrclk's rising edge (R channel)
                    when S3 =>
                        if rising(lrclk_p) then
                            state <= S4;    
                        end if;

                    --wait for bclk rising edge
                    when S4 =>
                        if rising(bclk_p) then
                            state <= S5;
                            bit_cnt <= bit_depth-1;
                        end if;

                    --sample receive data on next bclk rising edge
                    when S5 =>
                        if rising(bclk_p) then
                            if bit_cnt = 0 then
                                state <= S6;
                            else
                                in_r_reg(bit_cnt) <= sdata_in_p(0);
                                bit_cnt <= bit_cnt - 1;
                            end if;
                        end if;

                    --output LR 24 bit data + valid to PL
                    when S6 =>
                        audio_valid_pl <= '1';
                        audio_l_pl <= in_l_reg;
                        audio_r_pl <= in_r_reg;
                        state <= S0;

                    when others =>
                end case;
            end if;
        end if;
    end process;

    FSM_PROC_OUT : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_out <= D0;
                sdata_out <= '0';
                audio_l_adau_reg2 <= (others => '0');
                audio_r_adau_reg2 <= (others => '0');
                bit_out <= 0;
            else
                case state_out is
                    --wait for LRCLK to be pulled low
                    when D0 =>
                        if falling(lrclk_p) then
                            audio_l_adau_reg2 <= audio_l_adau_reg1;
                            audio_r_adau_reg2 <= audio_r_adau_reg1;
                            state_out <= D1;
                        end if;

                    --wait for rising edge BCLK
                    when D1 =>
                        if rising(bclk_p) then
                            state_out <= D2;
                            bit_out <= bit_depth -1;
                        end if;

                     --wait for falling edge BCLK, place MSB and continue to serialize until LSB
                    when D2 => --LEFT channel first
                        if falling(bclk_p) then
                            if bit_out = 0 then
                                state_out <= D3;
                            else
                                sdata_out <= audio_l_adau_reg2(bit_out);
                                bit_out <= bit_out - 1;
                            end if;
                        end if;

                    --wait for next falling edge after LSB to finish transmission of final bit, then output '0'
                    when D3 =>
                        if falling(bclk_p) then
                            state_out <= D4;
                            sdata_out <= '0';
                        end if;

                    --wait for LRCLK to be pulled high (R channel)
                    when D4 =>
                        if rising(lrclk_p) then
                            state_out <= D5;
                        end if;

                    --wait for rising edge BCLK
                    when D5 =>
                        if rising(bclk_p) then
                            state_out <= D6;
                            bit_out <= bit_depth-1;
                        end if;

                    --wait for falling edge BCLK, place MSB and continue to serialize until LSB
                    when D6 =>
                        if falling(bclk_p) then
                            if bit_out = 0 then
                                state_out <= D7;
                            else
                                sdata_out <= audio_r_adau_reg2(bit_out);
                                bit_out <= bit_out - 1;
                            end if;
                        end if;

                    -- Wait for falling bclk to finish tx of the final bit, go back to D0
                    when D7 =>
                        if falling(bclk_p) then
                            state_out <= D0;
                            sdata_out <= '0';
                        end if;
                end case;
    
            end if;
        end if;
    end process;

end architecture;