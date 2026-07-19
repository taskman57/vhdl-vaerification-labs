library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_byte_txrx is
    Port (
        clk_i       : in std_logic;
        rst_i       : in std_logic;
        ----    upper level write signals
        tx_byte_i   : in std_logic_vector(07 downto 0);
        start_i     : in std_logic;
        ----    upper level read signals
        rx_byte_o   : out std_logic_vector(07 downto 0);
        busy_o      : out std_logic;
        done_o      : out std_logic;
        ----    SPI slave interface
        miso_i      : in std_logic;
        sclk_o      : out std_logic;
        mosi_o      : out std_logic
    );
end spi_byte_txrx;

architecture Behavioral of spi_byte_txrx is

    type stat_t    is (idle, shift_data);
    signal stat_s    : stat_t := idle;

    signal sfr_wdat_s   : STD_LOGIC_VECTOR(07 downto 0):=(others => '0');
    signal sfr_rdat_s   : STD_LOGIC_VECTOR(07 downto 0):=(others => '0');
    signal sclk_s       : std_logic:= '0';
    signal done_s       : std_logic:= '0';
    signal sfr_ctr_s    : integer range 0 to 8-1:=0;
    signal sclk_dly_s   : std_logic;
    signal sfr_rena_s   : boolean := false;
    signal sfr_rctr_s   : integer range 0 to 8-1:=0;
    signal busy_act_s   : std_logic:='0';

begin

    sclk_o <= sclk_dly_s;
    SPI_SEND_PROC:
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                sclk_dly_s  <= '1';
                sclk_s      <= '1';
                mosi_o      <= '0';
                sfr_ctr_s   <= 0;
                stat_s      <= idle;
                sfr_wdat_s  <= (others => '0');
            else
                sclk_dly_s  <= sclk_s;
                case stat_s is
                    when idle       =>
                        if start_i = '1' then
                            stat_s      <= shift_data;
                            sfr_wdat_s  <= tx_byte_i;
                            sfr_ctr_s   <= 0;
                        end if;
                    when shift_data    =>
                        if sclk_s = '0' then
                            mosi_o      <= sfr_wdat_s(sfr_ctr_s);
                            if sfr_ctr_s < 7 then
                                sfr_ctr_s   <= sfr_ctr_s + 1;
                            else
                                stat_s   <= idle;
                                sfr_ctr_s   <= 0;
                            end if;
                        end if;
                        sclk_s      <= not sclk_s;
                    when others     =>
                        null;
                end case;
            end if;
        end if;
    end process SPI_SEND_PROC;

    SPI_READ_PROC:
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                sfr_rena_s  <= false;
                sfr_rctr_s  <= 0;
                done_s      <= '0';
                done_o      <= '0';
                busy_o      <= '0';
                sfr_rdat_s  <= (others => '0');
                rx_byte_o   <= (others => '0');
            else
                done_s      <= '0';
                busy_o      <= '0';
                done_o      <= done_s;
                if done_s = '1' then
                    rx_byte_o   <= sfr_rdat_s;
                end if;
                if busy_act_s = '1' then
                    busy_o  <= '1';
                end if;
                if sfr_rena_s then
                    if sclk_s = '1' and sclk_dly_s = '0' then   --sclk edge!
                        sfr_rdat_s      <= miso_i & sfr_rdat_s(7 downto 1);
                        if sfr_rctr_s < 7 then
                            sfr_rctr_s    <= sfr_rctr_s + 1;
                        else
                            sfr_rena_s  <= false;
                            done_s      <= '1';
                        end if;
                    end if;
                end if;
                if (sclk_s = '0' and sclk_dly_s = '1') and ( not sfr_rena_s ) then   -- first falling edge of sclk!
                    sfr_rena_s  <= true;
                    sfr_rctr_s  <= 0;
               end if;
            end if;
        end if;
    end process SPI_READ_PROC;

    busy_act_s <= '1' when ((start_i = '1') or (stat_s = shift_data) or sfr_rena_s)
                    else '0';

end Behavioral;
