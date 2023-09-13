library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_audio_interface is
    -- note: burst_size is how many packets bursted (ie num packets) at the end of this burst of packets, TLAST asserted on last packet.
    generic (data_width : integer := 32; burst_size : integer := 16);
    port (
        -- PORTS FOR AXIS (Streaming) Interface
        S_AXIS_ACLK : in std_logic; -- Source: Clock Source | The clock signal for the interface used by both the slave and master. All signals are sampled and generated from the rising edge of this clock.
        S_AXIS_ARESETN : in std_logic; -- Source: Reset Source | Active low reset for the interface.
        S_AXIS_TVALID : in std_logic; -- Source: Master | Indicates that the master is driving a valid transfer.
        S_AXIS_TLAST : in std_logic; -- Source: Master | Indicates that this transfer is the last transfer in the packet.
        S_AXIS_TDATA : in std_logic_vector(data_width-1 downto 0); -- Source: Master | The data being transferred.
        S_AXIS_TREADY : out std_logic; -- Source: Slave | Indicates the slave is ready to receive the transfer.
         
        --ADAU1761 Interface
        bclk : in std_logic;
        lrclk : in std_logic;
        --sdata_in : in std_logic; -- no longer using since we are getting data from AXIS (DMA)
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
            if rst = '0' then
                vec <= (others => '0');
            else
                vec <= sig & vec(vec'high downto vec'low+1);
            end if;
        end if; 
    end procedure;

    --Previous/shifted versions of the inputs
    signal bclk_p : std_logic_vector(4 downto 0);
    signal lrclk_p : std_logic_vector(4 downto 0);

    --FSM states for data input to buffer
    type state_type is (S1, S2, S3);
    signal state_dbuffer_read : state_type;

    --FSM states for data output
    type state_type_out is (reset, D0, D1, D2, D3, D4, D5, D6, D7);
    signal state_out : state_type_out;

    --For counting bclk data bits
    signal bit_out : integer range 0 to data_width - 1;

    --registered versions of inputs and outputs
    signal S_AXIS_TDATA_reg1 : std_logic_vector (data_width-1 downto 0);
    signal S_AXIS_TDATA_reg2 : std_logic_vector (data_width-1 downto 0);
    
    type buffer_type is array (0 to burst_size -1) of std_logic_vector(data_width - 1 downto 0); -- buffer is an array of packets (burst_size number of packets), where each packet is data_width large 
    signal dbuffer : buffer_type; -- data buffer --creates a signal called dbuffer of type buffer_type
    signal pbuffer : buffer_type; -- processing buffer

    --signals for buffer filling
    signal dbuffer_filled, dbuffer_transfer : std_logic := '0';
    signal pbuffer_empty : std_logic := '1';
    signal packet_count,p_packet_count : integer range 0 to burst_size;
    signal packet_cnt : integer range 0 to burst_size;
begin

    BCLK_SYNC_PROC : sync(S_AXIS_ACLK, S_AXIS_ARESETN, bclk, bclk_p);
    LRCLK_SYNC_PROC : sync(S_AXIS_ACLK, S_AXIS_ARESETN, lrclk, lrclk_p);


    -- READ DATA INTO DATA BUFFER (dbuffer)
    READ_DATA : process(S_AXIS_ACLK)
    begin
        if rising_edge(S_AXIS_ACLK) then
            if S_AXIS_ARESETN = '0' then
                state_dbuffer_read <= S1;
                dbuffer <= (others => (others => '0'));
                pbuffer <= (others => (others => '0'));
                dbuffer_transfer <= '0';
            else
                case state_dbuffer_read is
                    when S1 =>
                        dbuffer_transfer <= '0'; -- TEST
                        dbuffer_filled <= '0'; -- can remove this signal (unnecesary)
                        if S_AXIS_TVALID = '1' then --AND dbuffer_ready = '1'
                            state_dbuffer_read <= S2;
                            S_AXIS_TREADY <= '1';
                            packet_count <= 0;
                            dbuffer <= (others => (others => '0'));
                        elsif pbuffer_empty = '1' AND S_AXIS_TVALID = '0' then
                            S_AXIS_TREADY <= '1';
                            state_dbuffer_read <= S1;
                            pbuffer <= (others => (others => '0'));
                        else
                            state_dbuffer_read <= S1;
                        end if;

                    when S2 =>
                            if packet_count <= burst_size -1 AND S_AXIS_TLAST /= '1' AND S_AXIS_TVALID = '1' then
                                --dbuffer <= dbuffer(dbuffer'high -1 downto dbugger'low) & S_AXIS_TDATA; -- shift in the new data
                                dbuffer(packet_count) <= S_AXIS_TDATA;
                                S_AXIS_TREADY <= '1';
                                packet_count <= packet_count + 1;
                                state_dbuffer_read <= S2;
                            elsif packet_count <= burst_size -1 AND S_AXIS_TLAST = '1' AND S_AXIS_TVALID = '1' then
                                --dbuffer <= dbuffer(dbuffer'high -1 downto dbugger'low) & S_AXIS_TDATA; -- shift in the new data
                                dbuffer(packet_count) <= S_AXIS_TDATA; -- note left data will be in 
                                S_AXIS_TREADY <= '0';
                                packet_count <= packet_count + 1;
                                dbuffer_filled <= '1';
                                state_dbuffer_read <= S3;
                            --elsif 
                            else -- if packet_count > burst_size-1 (ie: packet_count=16) or TVALID = 0
                                S_AXIS_TREADY <= '0';
                                state_dbuffer_read <= S3;
                                dbuffer_filled <= '1';
                            end if;
                    when S3 =>
                            if pbuffer_empty = '1' then -- do transfer dbuff -> pbuff, pass on packet_count to output FSM, move back to state S1
                                pbuffer <= dbuffer;
                                state_dbuffer_read <= S1;
                                p_packet_count <= packet_count -1;
                                dbuffer_transfer <= '1';
                            else -- wait here (waiting for pbuff_empty, ie waiting for output serialization to finish)
                                state_dbuffer_read <= S3;
                                --p_packet_count <= 0;
                                dbuffer_transfer <= '0';
                            end if;
                end case;
            end if;
        end if;
    end process;

    

    --FSM FOR OUTPUT (serialize to sdata_out)
    FSM_PROC_OUT : process(S_AXIS_ACLK)
    begin
        if rising_edge(S_AXIS_ACLK) then
            if S_AXIS_ARESETN = '0' then
                state_out <= reset;
                sdata_out <= '0';
                bit_out <= 0;
            else
                case state_out is
                    when reset =>
                        packet_cnt <= 0;
                        pbuffer_empty <= '1';
                        if dbuffer_transfer = '1' then
                            state_out <= D0;
                            --pbuffer_empty <= '0';
                        else
                            state_out <= reset;
                        end if;

                    --wait for LRCLK to be pulled low
                    when D0 =>
                        pbuffer_empty <= '0';
                        if falling(lrclk_p) then
                            state_out <= D1;
                        end if;

                    --wait for rising edge BCLK
                    when D1 =>
                        if rising(bclk_p) then
                            state_out <= D2;
                            bit_out <= data_width -1;
                        end if;

                     --wait for falling edge BCLK, place MSB and continue to serialize until LSB
                    when D2 => --LEFT channel first
                        if falling(bclk_p) then
                            if bit_out = 15 then
                                state_out <= D3;
                            else
                                sdata_out <= pbuffer(packet_cnt)(bit_out); -- SERIALIZE LEFT CHANNEL
                                bit_out <= bit_out - 1;
                            end if;
                        end if;

                    --wait for next falling edge after LSB to finish transmission of final bit, then output '0'
                    when D3 =>
                        if falling(bclk_p) then
                            state_out <= D4;
                            sdata_out <= '0'; -- SPACING BITS
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
                            --bit_out <= bit_depth-1;
                        end if;

                    --wait for falling edge BCLK, place MSB and continue to serialize until LSB
                    when D6 =>
                        if falling(bclk_p) then
                            if bit_out = 0 then
                                state_out <= D7;
                                packet_cnt <= packet_cnt + 1;
                            else
                                sdata_out <= pbuffer(packet_cnt)(bit_out); -- SERIALIZE RIGHT CHANNEL
                                bit_out <= bit_out - 1;
                            end if;
                        end if;

                    -- Wait for falling bclk to finish tx of the final bit, go back to D0
                    when D7 =>
                        if falling(bclk_p) then
                            state_out <= D0;
                            sdata_out <= '0';
                        end if;
                        if packet_cnt = p_packet_count + 1 then -- to triger transfer of dbuff -> pbuff
                            pbuffer_empty <= '1';
                            packet_cnt <= 0;
                        else
                            pbuffer_empty <= '0';
                        end if;
                end case;
    
            end if;
        end if;
    end process;

end architecture;