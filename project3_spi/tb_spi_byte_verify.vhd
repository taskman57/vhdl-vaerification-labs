library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity tb_spi_byte_verify is
end entity;

architecture stim of tb_spi_byte_verify is

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
    -- constant RESP_DATA  : std_logic_vector(7 downto 0) := x"3C";
    constant clk_per    : time:= 50 ns;
    type spi_t is array(0 to 7) of std_logic_vector(7 downto 0);
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
    signal bit_ctr_s    : integer range 0 to 7 := 0;

    function to_hex(slv : std_logic_vector) return string is
        variable v   : std_logic_vector(slv'length - 1 downto 0) := slv;
        constant nd  : integer := (slv'length + 3) / 4;
        variable pad : std_logic_vector(nd*4 - 1 downto 0) := (others => '0');
        variable nib : std_logic_vector(3 downto 0);
        variable r   : string(1 to nd);
    begin
        pad(v'length - 1 downto 0) := v;
        for i in 0 to nd - 1 loop
            nib := pad(i*4 + 3 downto i*4);
            case nib is
                when "0000" => r(nd-i) := '0';  when "0001" => r(nd-i) := '1';
                when "0010" => r(nd-i) := '2';  when "0011" => r(nd-i) := '3';
                when "0100" => r(nd-i) := '4';  when "0101" => r(nd-i) := '5';
                when "0110" => r(nd-i) := '6';  when "0111" => r(nd-i) := '7';
                when "1000" => r(nd-i) := '8';  when "1001" => r(nd-i) := '9';
                when "1010" => r(nd-i) := 'A';  when "1011" => r(nd-i) := 'B';
                when "1100" => r(nd-i) := 'C';  when "1101" => r(nd-i) := 'D';
                when "1110" => r(nd-i) := 'E';  when "1111" => r(nd-i) := 'F';
                when others => r(nd-i) := 'X';
            end case;
        end loop;
        return r;
    end function;

    ---- read SPI ports
    procedure capture_spi_byte(
        signal spi_clk      : in std_logic;
        signal spi_mosi     : in std_logic;
        variable sfr_tx     : inout std_logic_vector(7 downto 0)
    ) is
    begin
        for i in 0 to 7 loop
            wait until rising_edge(spi_clk);
            sfr_tx(i)   := spi_mosi;
        end loop;
    end procedure;

    ---- check SPI transmitted byte via MOSI
    procedure check_mosi(
        constant test_name      : in string;
        constant actual_tx      : in std_logic_vector(7 downto 0);
        constant expected_tx    : in std_logic_vector(7 downto 0)
    ) is
    begin
        if unsigned(actual_tx) = unsigned(expected_tx) then

            report "PASS: "
                & test_name
                & " -> MOSI SFR = "
                & "0X"
                & to_hex(actual_tx)
                severity note;
        else

            report "FAIL: "
                & test_name
                & " -> MOSI expected = "
                & "0X"
                & to_hex(expected_tx)
                & " actual SFR = "
                & "0X"
                & to_hex(actual_tx)
                severity error;
        end if;
    end procedure;

    ---- check SPI received byte via MISO
    procedure check_spi_rx_byte(
        constant test_name      : in string;
        constant actual_rx      : in std_logic_vector(7 downto 0);
        constant expected_rx    : in std_logic_vector(7 downto 0)
    ) is
    begin
        if unsigned(actual_rx) = unsigned(expected_rx) then

            report "PASS: "
                & test_name
                & " -> MISO SFR = "
                & "0X"
                & to_hex(actual_rx)
                severity note;
        else

            report "FAIL: "
                & test_name
                & " -> MISO expected SFR = "
                & "0X"
                & to_hex(expected_rx)
                & " actual = "
                & "0X"
                & to_hex(actual_rx)
                severity error;
        end if;
    end procedure;

    procedure spi_slave_send_byte(
        signal spi_clk          : in std_logic;
        signal spi_miso         : out std_logic;
        variable slave_tx_sfr   : in std_logic_vector(7 downto 0)
    ) is
    begin
        for i in 0 to 7 loop
            wait until falling_edge(spi_clk);
            spi_miso    <= slave_tx_sfr(i);
        end loop;
        
    end procedure;

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
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

    ----------------------------------------------------------------
    -- Clock generator
    ----------------------------------------------------------------
    CLK_STIM_ISNT:
    process
    begin
        clk_i <= not clk_i;
        wait for clk_per/2;
    end process;

    ----------------------------------------------------------------
    -- Reset Stimulus process
    ----------------------------------------------------------------
    RESET_PROC : process
    begin
        rst_i <= '1';
        wait for 30 ns;
        wait until rising_edge(clk_i);
        rst_i <= '0';

        -- Wait forever unless a test intentionally changes reset
        wait;
    end process;

    ----------------------------------------------------------------
    -- transfer byte Stimulus process
    ----------------------------------------------------------------
    stim_proc : process
        ----------------------------------------------------------------
        -- Reference model signal
        ----------------------------------------------------------------
        variable exp_byte_v     : std_logic_vector(7 downto 0);
        variable sfr_byte_v     : std_logic_vector(7 downto 0);
    begin

        -- Synchronize with reset de-assertion
        wait until rst_i = '0';
        wait until rising_edge(clk_i);

        ----------------------------------------------------------------
        -- MOSI SFR Loop Test
        ----------------------------------------------------------------
        for i in spi_sample_s'range loop

            tx_byte_i   <= spi_sample_s(i);
            exp_byte_v  := spi_sample_s(i);
            --wait until rising_edge(clk_i);
            start_i     <= '1';
            wait until rising_edge(clk_i);
            start_i     <= '0';

            capture_spi_byte(sclk_o, mosi_o, sfr_byte_v);
            wait until done_o = '1';

            check_mosi(
                "Test " & integer'image(i)
                ,sfr_byte_v
                ,exp_byte_v);

        end loop;
        ----------------------------------------------------------------
        -- Finish simulation
        ----------------------------------------------------------------
        report "SPI byte send Directed Self-Checking completed"
            severity note;

        wait;
    end process stim_proc;

    ----------------------------------------------------------------
    -- Verify Received byte process
    ----------------------------------------------------------------
    RX_REC: process
        ----------------------------------------------------------------
        -- Reference model signal
        ----------------------------------------------------------------
        variable exp_byte_v     : std_logic_vector(7 downto 0);
        variable sfr_byte_v     : std_logic_vector(7 downto 0);
        variable slave_byte_v   : std_logic_vector(7 downto 0);
    begin

        -- Synchronize with reset de-assertion
        wait until rst_i = '0';
        wait until rising_edge(clk_i);
        ----------------------------------------------------------------
        -- rx_byte_o Loop Test
        ----------------------------------------------------------------
        for i in spi_sample_s'range loop
            slave_byte_v    := spi_sample_s(i);
            exp_byte_v      := spi_sample_s(i);
            wait until start_i = '1';
            spi_slave_send_byte(sclk_o, miso_i, slave_byte_v);
            wait until done_o = '1';
            check_spi_rx_byte(
                "Test " & integer'image(i)
                ,rx_byte_o
                ,exp_byte_v);

        end loop;
        ----------------------------------------------------------------
        -- Finish simulation
        ----------------------------------------------------------------
        report "SPI byte receive Directed Self-Checking completed"
            severity note;

        wait;
    end process RX_REC;

end stim;