library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity tb_spi is
end entity;

architecture stim of tb_spi is

    ---- input
    signal clk_i       : std_logic := '0';
    signal rst_i       : std_logic := '1';
    signal tx_byte_i   : std_logic_vector(07 downto 0):=(others => '0');
    signal start_i     : std_logic := '0';
    signal miso_i      : std_logic := '0';

    ---- output
    signal rx_byte_o    : std_logic_vector(07 downto 0);
    signal busy_o       : std_logic;
    signal done_o       : std_logic;
    signal sclk_o       : std_logic;
    signal mosi_o       : std_logic;

    ---- Constants
    constant RESP_DATA  : std_logic_vector(7 downto 0) := x"3C";
    constant clk_per    : time:= 50 ns;
    type spi_t is array(7 downto 0) of std_logic_vector(7 downto 0);
    signal spi_sample_s : spi_t :=(
        x"13",
        x"AA",
        x"10",
        x"88",
        x"52",
        x"F7",
        x"55",
        x"11"
    );

    ---- testbench signals
    signal tx_shift_s   : std_logic_vector(7 downto 0) := RESP_DATA;
    signal bit_ctr_s    : integer range 0 to 7 := 0;

begin

    CLK_STIM_ISNT:
    process
    begin
        clk_i <= not clk_i;
        wait for clk_per/2;
    end process;

    rst_i   <= '0' after 2* clk_per;

    DUT: entity work.spi_byte_txrx
        port map(
            clk_i       => clk_i,
            rst_i       => rst_i,
            tx_byte_i   => tx_byte_i,
            start_i     => start_i,
            rx_byte_o   => rx_byte_o,
            busy_o      => busy_o,
            done_o      => done_o,
            miso_i      => miso_i,
            sclk_o      => sclk_o,
            mosi_o      => mosi_o
        );

    TX_STIM:
    process(clk_i)
        variable ctr_v  : integer range 0 to 8 := 0;
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                tx_byte_i   <= (others => '0');
                start_i     <= '0';
                ctr_v       := 0;
            else
                start_i     <= '0';
                if ctr_v < 8 and busy_o = '0' and start_i = '0' then
                    tx_byte_i   <= spi_sample_s(ctr_v);
                    start_i     <= '1';
                    ctr_v       := ctr_v + 1;
                end if;
            end if;
        end if;
    end process;

    RX_STIM:
    process(sclk_o, start_i)
        variable vec_v  : integer range 0 to spi_sample_s'length-1 := spi_sample_s'length-1;
    begin
        if rst_i = '1' then
            miso_i      <= '0';
            tx_shift_s  <= spi_sample_s(spi_sample_s'length-1);
            vec_v       := spi_sample_s'length-1;
        elsif falling_edge(sclk_o) then
            miso_i      <= tx_shift_s(0);
            tx_shift_s  <= '0' & tx_shift_s(7 downto 1);

            if bit_ctr_s < 7 then
                bit_ctr_s   <= bit_ctr_s + 1;
            else
                bit_ctr_s   <= 0;
                if vec_v > 0 then
                    vec_v   := vec_v - 1;
                end if;
                tx_shift_s <= spi_sample_s(vec_v);
            end if;
        end if;
    end process;
    
end stim;