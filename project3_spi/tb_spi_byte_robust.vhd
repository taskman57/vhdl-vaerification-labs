library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity tb_spi_byte_robust is
end entity;

architecture robustness of tb_spi_byte_robust is

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
    constant clk_per    : time:= 50 ns;

    ---- testbench signals
    signal tx_shift_s   : std_logic_vector(7 downto 0);
    signal bit_ctr_s    : integer range 0 to 7 := 0;
    signal test_done_s  : std_logic := '0';

    type capture_status_t is (
        COMPLETE,
        ABORTED_BY_RESET
    );

    type done_status_t is (
        SINGLE_DONE,
        LNEGTHY_DONE,
        MULTIPLE_DONE,
        MULTIPLE_LENGTHY_DONE,
        UNKNOWN_DONE
    );
    ----    start during busy robustness test
    signal scenario2_active_s   : std_logic;
    signal robust_start_s       : std_logic;
    signal tx_mux_start_s       : std_logic;
    signal robust_start_data_s  : std_logic_vector(7 downto 0);
    signal tx_mux_byte_s        : std_logic_vector(7 downto 0);


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

    ---- read SPI MOSI port
    procedure capture_spi_byte_until_reset(
        signal reset_i      : in std_logic;
        signal spi_clk      : in std_logic;
        signal spi_mosi     : in std_logic;
        variable sfr_tx     : inout std_logic_vector(7 downto 0);
        variable status     : out capture_status_t
    ) is
    begin

        status := COMPLETE;

        for i in 0 to 7 loop

            wait until rising_edge(spi_clk) or reset_i = '1';

            if reset_i = '1' then
                status := ABORTED_BY_RESET;
                exit;
            end if;

            sfr_tx(i) := spi_mosi;

        end loop;

    end procedure;

    ---- check done_o shape in multiple
    procedure check_done_shape (
        signal clk                      : in std_logic;
        signal dut_done                 : in std_logic;
        constant scenario_msg           : string;
        variable clk_cyc_no             : integer;
        variable done_stat              : out done_status_t
    ) is
        variable old_done_v             : std_logic := '0';
        variable done_rise_sample_ctr   : integer   := 0;
        variable done_fall_sample_ctr   : integer   := 0;
        variable done_high_sample_ctr   : integer   := 0;
    begin

        for i in 0 to clk_cyc_no-1 loop
            wait until rising_edge(clk);
            if dut_done = '1' and old_done_v = '0' then
                done_rise_sample_ctr  := done_rise_sample_ctr + 1;
            elsif dut_done = '0' and old_done_v = '1' then
                done_fall_sample_ctr  := done_fall_sample_ctr + 1;
            elsif dut_done = '1' and old_done_v = '1' then
                done_high_sample_ctr   := done_high_sample_ctr + 1;
            end if;
            old_done_v := dut_done;
        end loop;
        if done_rise_sample_ctr = 1 and done_fall_sample_ctr = 1 and done_high_sample_ctr = 0 then
            report scenario_msg
                & " : successful. Done signal asserted one cycle as expected."
                severity note;
            done_stat   := SINGLE_DONE;
        elsif done_high_sample_ctr > 0 and done_rise_sample_ctr = 1 and done_fall_sample_ctr = 1 then
            report scenario_msg
                & " : failed. Done signal asserted more than one cycle!."
                severity error;
            done_stat   := LNEGTHY_DONE;
        elsif done_high_sample_ctr > 0 and (done_rise_sample_ctr /= 1 or done_fall_sample_ctr /= 1) then
            report scenario_msg
                & " : failed. Done signal asserted more than once and one cycle!."
                severity error;
            done_stat   := MULTIPLE_LENGTHY_DONE;
        elsif done_high_sample_ctr = 0 and (done_rise_sample_ctr /= 1 or done_fall_sample_ctr /= 1) then
            report scenario_msg
                & " : failed. Done signal asserted more than once and one cycle!."
                severity error;
            done_stat   := MULTIPLE_DONE;
        else
            report scenario_msg
                & " : failed. Unknown done behavior!."
                & LF
                & " pos_edge_ctr: "
                & integer'image(done_rise_sample_ctr)
                & LF 
                & " neg_edge_ctr: "
                & integer'image(done_fall_sample_ctr)
                & LF
                & " extended_length_ctr: "
                & integer'image(done_high_sample_ctr)
                & LF
                severity error;
            done_stat   := UNKNOWN_DONE;
        end if;
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
            tx_byte_i   => tx_mux_byte_s,
            start_i     => tx_mux_start_s,
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

        -- reset robust test scenario
        wait until busy_o = '1';
        for i in 0 to 2 loop
            wait until falling_edge(sclk_o);
        end loop;
            rst_i <= '1';
            wait until rising_edge(clk_i);
            rst_i <= '0';
        wait;
    end process;

    ----------------------------------------------------------------
    -- transfer byte Stimulus process
    ----------------------------------------------------------------
    stim_proc : process
        variable sfr_byte_v     : std_logic_vector(7 downto 0);
        variable status_v       : capture_status_t;
        variable done_stat_v    : done_status_t;
        variable cycle_no       : integer := 0;
    begin

        scenario2_active_s       <= '0';

        -- Synchronize with reset de-assertion
        wait until rst_i = '0';
        wait until rising_edge(clk_i);

        ----------------------------------------------------------------
        -- Scenario 1 : Reset during active transfer
        ----------------------------------------------------------------

        tx_byte_i <= x"64";     -- for reset test

        start_i <= '1';
        wait until rising_edge(clk_i);
        start_i <= '0';

        capture_spi_byte_until_reset(
            rst_i,
            sclk_o,
            mosi_o,
            sfr_byte_v,
            status_v
        );

        if status_v = ABORTED_BY_RESET then
            report "SPI TX correctly aborted by reset"
                severity note;
        end if;

        wait until rst_i = '0';
        -- optional could be removed to check immidiate start after reset too.
        wait until rising_edge(clk_i);

        report "Starting recovery transaction"
            severity note;
    
        tx_byte_i   <= x"AA";   --  for recovery after test purpose
        start_i     <= '1';
        wait until rising_edge(clk_i);
        start_i     <= '0';
        capture_spi_byte_until_reset(rst_i, sclk_o, mosi_o, sfr_byte_v, status_v);

        wait until done_o = '1';

        if status_v = COMPLETE then
            report "Recovery transaction completed"
                severity note;
        else
            report "Recovery transaction failed: unexpected reset abort"
                severity error;
        end if;

        check_mosi(
            "Recovery TX after reset",
            sfr_byte_v,
            x"AA"
        );

        report "Scenario 1 PASSED: Reset during active transfer"
            severity note;

        ----------------------------------------------------------------
        -- Scenario 2 : start_i asserted while busy_o = '1'
        ----------------------------------------------------------------

        tx_byte_i           <= x"33";
        start_i             <= '1';
        wait until rising_edge(clk_i);
        start_i             <= '0';

        scenario2_active_s       <= '1';     -- here robustness test of start_i begins

        capture_spi_byte_until_reset(rst_i, sclk_o, mosi_o, sfr_byte_v, status_v);

        wait until done_o = '1';

        if status_v = COMPLETE then
            report " Transaction with multiple start_i completed"
                severity note;
        else
            report " Transaction failed"
                severity error;
        end if;

        check_mosi(
            " TX during nmultiple start_i: ",
            sfr_byte_v,
            tx_byte_i
        );

        scenario2_active_s      <= '0';     -- finsih robustness test of start_i begins
    ----------------------------------------------------------------
    -- Scenario 3 : Back-to-back transfers
    ----------------------------------------------------------------
        report " Starting Back-to-back transfers "
               & " First B2B transfer "
            severity note;
    
        tx_byte_i   <= x"55";   -- value for first B2B test
        start_i     <= '1';
        wait until rising_edge(clk_i);
        start_i     <= '0';
        capture_spi_byte_until_reset(rst_i, sclk_o, mosi_o, sfr_byte_v, status_v);

        wait until done_o = '1';

        if status_v = COMPLETE then
            report " First B2B transaction completed"
                severity note;
        else
            report " First B2B transaction failed"
                severity error;
        end if;

        check_mosi(
            " First B2B transfer ",
            sfr_byte_v,
            tx_byte_i
        );

        report " Now, second B2B transfer "
            severity note;
    
        tx_byte_i   <= x"AA";   -- value for second B2B test
        start_i     <= '1';
        wait until rising_edge(clk_i);
        start_i     <= '0';
        capture_spi_byte_until_reset(rst_i, sclk_o, mosi_o, sfr_byte_v, status_v);

        wait until done_o = '1';

        if status_v = COMPLETE then
            report " Second B2B transaction completed"
                severity note;
        else
            report " Second B2B transaction failed"
                severity error;
        end if;

        check_mosi(
            " Second B2B transfer ",
            sfr_byte_v,
            tx_byte_i
        );

        report " Scenario 3 PASSED: back to back transfer completed"
            severity note;

    ----------------------------------------------------------------
    -- Scenario 4 : start_i pulse-width variation
    ----------------------------------------------------------------
        report " Starting Scenario 4: start_i pulse-width variation"
            severity note;
        cycle_no := 5;
        report " Check done events "
                & integer'image(cycle_no)
                & " clocks after transmission"
            severity note;
    ----------------------------------------------------------------
    -- Scenario 4.1 : Single-clock start_i pulse
    ----------------------------------------------------------------

        tx_byte_i   <= x"73";   -- value for scenario 4.1
        start_i     <= '1';
        wait until rising_edge(clk_i);
        start_i     <= '0';
        capture_spi_byte_until_reset(rst_i, sclk_o, mosi_o, sfr_byte_v, status_v);

        wait until done_o = '1';

        check_done_shape(clk_i, done_o, " Scenario 4.1", cycle_no, done_stat_v);

        if status_v = COMPLETE then
            report " Scenario 4.1 single clock start_i transaction completed"
                severity note;
        else
            report " Scenario 4.1 single clock start_i transaction failed"
                severity error;
        end if;

        check_mosi(
            " Scenario 4.1 transfer ",
            sfr_byte_v,
            tx_byte_i
        );

    ----------------------------------------------------------------
    -- Scenario 4.2 : Two-clock start_i pulse
    ----------------------------------------------------------------

        tx_byte_i   <= x"9F";   -- value for scenario 4.2
        start_i     <= '1';
        wait until rising_edge(clk_i);
        wait until rising_edge(clk_i);
        start_i     <= '0';
        capture_spi_byte_until_reset(rst_i, sclk_o, mosi_o, sfr_byte_v, status_v);

        wait until done_o = '1';

        check_done_shape(clk_i, done_o, " Scenario 4.2", cycle_no,  done_stat_v);

        if status_v = COMPLETE then
            report " Scenario 4.2 two clocks transaction completed"
                severity note;
        else
            report " Scenario 4.2 two clocks transaction failed"
                severity error;
        end if;

        check_mosi(
            " Scenario 4.2 transfer ",
            sfr_byte_v,
            tx_byte_i
        );

    ----------------------------------------------------------------
    -- Scenario 4.3 : Three-clock start_i pulse
    ----------------------------------------------------------------

        tx_byte_i   <= x"44";   -- value for scenario 4.3
        start_i     <= '1';
        wait until rising_edge(clk_i);
        wait until rising_edge(clk_i);
        wait until rising_edge(clk_i);
        start_i     <= '0';
        capture_spi_byte_until_reset(rst_i, sclk_o, mosi_o, sfr_byte_v, status_v);

        wait until done_o = '1';

        check_done_shape(clk_i, done_o, " Scenario 4.3", cycle_no,   done_stat_v);

        if status_v = COMPLETE then
            report " Scenario 4.3 three clocks transaction completed"
                severity note;
        else
            report " Scenario 4.3 three clocks transaction failed"
                severity error;
        end if;

        check_mosi(
            " Scenario 4.3 transfer ",
            sfr_byte_v,
            tx_byte_i
        );

        report " Scenario 4 PASSED: start_i pulse-width variation"
            severity note;

    ----------------------------------------------------------------
    -- Scenario 4 PASSED : start_i pulse-width variation
    ----------------------------------------------------------------

        test_done_s             <= '1';
        wait;
    end process stim_proc;

    ----------------------------------------------------------------
    -- Scenario 2 : start_i asserted while busy_o = '1'
    ----------------------------------------------------------------
    tx_mux_byte_s   <= tx_byte_i when scenario2_active_s  = '0' else
                        robust_start_data_s;

    tx_mux_start_s  <= start_i when scenario2_active_s  = '0' else
                        robust_start_s;
    busy_retrigger_driver: process
    begin
        robust_start_s      <= '0';
        robust_start_data_s <= (others => '0');
        -- Synchronize with reset de-assertion
        wait until rst_i = '0';
        wait until rising_edge(clk_i);

        wait until scenario2_active_s  = '1';    -- start during transfer robustness test

        for i in 0 to 3 loop
            wait until rising_edge(clk_i);
        end loop;

        robust_start_data_s <= x"f9";
        robust_start_s      <= '1';
        wait until rising_edge(clk_i);
        robust_start_s      <= '0';
        
        wait until busy_o = '1';            -- transmission on going
        wait;
    end process busy_retrigger_driver;

    ----------------------------------------------------------------
    -- Scenario 2 Checker : Busy/Done protocol verification
    ----------------------------------------------------------------
    done_monitor: process
        variable done_ctr_v     : integer :=0;
        variable done_old_v     : std_logic:= '0';
        variable busy_seen_v    : boolean := false;
    begin
        -- Synchronize with reset de-assertion
        wait until rst_i = '0';
        wait until rising_edge(clk_i);

        wait until scenario2_active_s  = '1';    -- start during transfer robustness test

        loop

            wait until rising_edge(clk_i);

            if busy_o = '1' then
                busy_seen_v := true;
            end if;
    
            if done_o = '1' and done_old_v = '0' then
                done_ctr_v := done_ctr_v + 1;
            end if;

            done_old_v := done_o;

            exit when busy_o = '0';

        end loop;

        if busy_seen_v = false then
            report "FAIL: No busy_o activity detected during Scenario 2"
                severity error;
        end if;

        if done_ctr_v = 1 then
            report " PASS: done_o checking is correct."
                & " Number of assertion: "
                & integer'image(done_ctr_v)
            severity note;
        else
            report " FAILED: done_o asserted: "
                & integer'image(done_ctr_v)
            severity error;
        end if;
        wait;
    end process done_monitor;

end robustness;