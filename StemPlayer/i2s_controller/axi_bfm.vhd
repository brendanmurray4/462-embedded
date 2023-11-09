library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_bfm is
    port (
        -- Testbench interface (next sample to send)
        next_sample : in std_logic_vector(31 downto 0);

        --DUT Interface
        S_AXIS_ACLK : in std_logic; -- Source: Clock Source | The clock signal for the interface used by both the slave and master. All signals are sampled and generated from the rising edge of this clock.
        S_AXIS_ARESETN : in std_logic; -- Source: Reset Source | Active low reset for the interface.
        S_AXIS_TVALID : out std_logic; -- Source: Master | Indicates that the master is driving a valid transfer.
        S_AXIS_TLAST : out std_logic; -- Source: Master | Indicates that this transfer is the last transfer in the packet.
        S_AXIS_TDATA : out std_logic_vector(data_width-1 downto 0); -- Source: Master | The data being transferred.
        S_AXIS_TREADY : in std_logic; -- Source: Slave | Indicates the slave is ready to receive the transfer.
    );
end axi_bfm;

architecture rtl of axi_bfm is

begin

    ------     BUS Functional Model (BFM) ----------------------
    BFM_PROC : process
    --variable send_bits : std_logic_vector(15 downto 0) := (others => '0');
    begin
        
    --S_AXIS_TDATA <= 'X';
    --S_AXIS_TVALID <= '0';
    --wait until S_AXIS_ARESETN = '1';

    --set the data bits
    --send_bits(31 downto 0) := next_sample;

    --S_AXIS_TVALID <= '1';
    wait until S_AXIS_TREADY = '0';
    S_AXIS_TDATA <= next_sample;

    --for i in 15 downto 0 loop
    --    wait until S_AXIS_TREADY = '0';
    --    S_AXIS_TDATA <= send_bits(i);
    --end loop;

    end process;
    ---------------------------------------------------------------

end architecture;