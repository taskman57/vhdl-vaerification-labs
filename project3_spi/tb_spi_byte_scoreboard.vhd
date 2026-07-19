library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity tb_spi_byte_scoreboard is
end entity;

architecture scoreboard of tb_spi_byte_scoreboard is

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

    type spi_rec_t is array(0 to 9) of std_logic_vector(7 downto 0);
    signal spi_scoreboard_samples_s : spi_rec_t :=(
        x"55",  -- alternating pattern
        x"AA",  -- alternating inverse
        x"00",  -- all zeros
        x"FF",  -- all ones
        x"01",  -- only LSB set
        x"80",  -- only MSB set
        x"FE",  -- all except LSB
        x"7F",  -- all except MSB
        x"0F",  -- lower nibble
        x"F0"   -- upper nibble
    );

    ---- testbench signals
    signal tx_shift_s   : std_logic_vector(7 downto 0);
    signal bit_ctr_s    : integer range 0 to 7 := 0;
    signal test_done_s  : std_logic := '0';

    type spi_transaction_t is record
        expected : std_logic_vector(7 downto 0);
        actual   : std_logic_vector(7 downto 0);
    end record;

    type spi_transaction_array_t is array (natural range <>) of spi_transaction_t;

    signal tx_scoreboard_s : spi_transaction_array_t(0 to 9);
    signal rx_scoreboard_s : spi_transaction_array_t(0 to 9);

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
        signal slave_tx_sfr     : in std_logic_vector(7 downto 0)
    ) is
    begin
        for i in 0 to 7 loop
            wait until falling_edge(spi_clk);
            spi_miso    <= slave_tx_sfr(i);
        end loop;
        
    end procedure;

    procedure check_score(
        constant test_string    : string;
        variable test_no        : integer;
        variable pass_ctr       : inout integer;
        variable fail_ctr       : inout integer;
        variable expected       : std_logic_vector(7 downto 0);
        variable actual         : std_logic_vector(7 downto 0)
    ) is
    begin
        if unsigned(actual) = unsigned(expected) then

            pass_ctr := pass_ctr + 1;

            report "PASS: "
                & test_string
                & integer'image(test_no)
                & " match : "
                & "0X"
                & to_hex(actual)
                severity note;

        else

            fail_ctr := fail_ctr + 1;

            report "FAIL: "
                & test_string
                & integer'image(test_no)
                & " expec = "
                & "0X"
                & to_hex(expected)
                & " transferred = "
                & "0X"
                & to_hex(actual)
                severity error;

        end if;

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
        for i in spi_scoreboard_samples_s'range loop

            tx_byte_i           <= spi_scoreboard_samples_s(i);
            exp_byte_v          := spi_scoreboard_samples_s(i);
            tx_scoreboard_s(i).expected  <= spi_scoreboard_samples_s(i);
            --wait until rising_edge(clk_i);
            start_i     <= '1';
            wait until rising_edge(clk_i);
            start_i     <= '0';

            capture_spi_byte(sclk_o, mosi_o, sfr_byte_v);
            wait until done_o = '1';
            tx_scoreboard_s(i).actual <= sfr_byte_v;

        end loop;
        ----------------------------------------------------------------
        -- Finish simulation
        ----------------------------------------------------------------
        report "All bytes for scoreboard verification(transmit path) transferred"
            severity note;
        test_done_s     <= '1';
        wait;
    end process stim_proc;

    ----------------------------------------------------------------
    -- Verify Received byte process
    ----------------------------------------------------------------
    RX_REC: process
        ----------------------------------------------------------------
        -- Reference model signal
        ----------------------------------------------------------------
        variable sfr_byte_v     : std_logic_vector(7 downto 0);
    begin

        -- Synchronize with reset de-assertion
        wait until rst_i = '0';
        wait until rising_edge(clk_i);
        ----------------------------------------------------------------
        -- rx_byte_o Loop Test
        ----------------------------------------------------------------
        for i in spi_scoreboard_samples_s'range loop
            tx_shift_s <= spi_scoreboard_samples_s(i);
            rx_scoreboard_s(i).expected <= spi_scoreboard_samples_s(i);
            wait until start_i = '1';
            spi_slave_send_byte(sclk_o, miso_i, tx_shift_s);
            wait until done_o = '1';
            rx_scoreboard_s(i).actual   <= rx_byte_o;

        end loop;
        ----------------------------------------------------------------
        -- Finish simulation
        ----------------------------------------------------------------
        report "All bytes scoreboard verification (receive path) completed"
            severity note;

        wait;
    end process RX_REC;

    --------------------------------------------------------------------
    -- mini scoreboard verification
    --------------------------------------------------------------------
    scoreboad_phase: process
        variable tx_pass_count_v : integer := 0;
        variable tx_fail_count_v : integer := 0;
        variable rx_pass_count_v : integer := 0;
        variable rx_fail_count_v : integer := 0;
        variable testno          : integer := 0;
        variable expec           : std_logic_vector(7 downto 0);
        variable actual          : std_logic_vector(7 downto 0);
    begin
        -- Synchronize with reset de-assertion
        wait until rst_i = '0';
        wait until rising_edge(clk_i);

        ---- wait until all test vectors have been transmitted
        wait until test_done_s = '1';
        ----------------------------------------------------------------
        -- scoreboard chcker
        ----------------------------------------------------------------
        for i in spi_scoreboard_samples_s'range loop
            testno  := i;
            expec   := tx_scoreboard_s(i).expected;
            actual  := tx_scoreboard_s(i).actual;
            check_score(
                "tx Score Test "
                , testno
                ,tx_pass_count_v, tx_fail_count_v
                , expec
                , actual);

            expec   := rx_scoreboard_s(i).expected;
            actual  := rx_scoreboard_s(i).actual;
            check_score(
                "rx Score Test " 
                , testno
                ,rx_pass_count_v, rx_fail_count_v
                ,expec
                ,actual);

        end loop;

        report LF & " socreboard results: "
                -- severity note;
                & LF
                & "-------------------------"
                & LF
                & " TX MOSI pass: "
                & LF
                & "-------------------------"
                & LF
                & integer'image(tx_pass_count_v)
                & LF
                & "-------------------------"
                & LF
                &  " TX MOSI fail: "
                & LF
                &  "-------------------------"
                & LF
                &  integer'image(tx_fail_count_v)
                & LF
                &  "-------------------------"
                & LF
                &  " RX MISO pass: "
                & LF
                &  "-------------------------"
                & LF
                &  integer'image(rx_pass_count_v)
                & LF
                &  "-------------------------"
                & LF
                &  " RX MISO fail: "
                & LF
                &  "-------------------------"
                & LF
                &  integer'image(rx_fail_count_v)
                & LF
        severity note;

        wait;
    end process scoreboad_phase;

end scoreboard;