library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_divider_divbyzero is
end entity;

architecture sim of tb_divider_divbyzero is

    ----------------------------------------------------------------
    -- DUT signals
    ----------------------------------------------------------------
    signal clk_i        : std_logic := '0';
    signal rst_i        : std_logic := '1';
    signal ena_i        : std_logic := '0';

    signal num_i        : std_logic_vector(33 downto 0):=(others => '0');
    signal dnum_i       : std_logic_vector(9 downto 0):=(others => '0');

    signal quot_o       : std_logic_vector(23 downto 0);
    signal q_rdy_o      : std_logic;
    signal div_err_o    : std_logic;

    procedure check_result(
        constant test_name      : string;
        constant actual_q       : integer;
        constant expected_q     : integer;
        variable pass_count_v   : inout integer;
        variable fail_count_v   : inout integer
    ) is
    begin

        if actual_q = expected_q then

            pass_count_v := pass_count_v + 1;

            report "PASS: "
                & test_name
                & " -> quotient = "
                & integer'image(actual_q)
                severity note;

        else

            fail_count_v := fail_count_v + 1;

            report "FAIL: "
                & test_name
                & " expected="
                & integer'image(expected_q)
                & " actual="
                & integer'image(actual_q)
                severity error;

        end if;

    end procedure;

    procedure check_div_error(
        constant test_name      : string;
        constant actual_q       : integer;
        constant actual_error   : std_logic;
        variable pass_count_v   : inout integer;
        variable fail_count_v   : inout integer
    )is
    begin
        if (actual_q = 0) and (actual_error = '1') then
            pass_count_v := pass_count_v + 1;
            report "PASS: "
                    & test_name
                    & " divide-by-zero handled -> quotient = "
                    & integer'image(actual_q)
                    severity note;
        else
            fail_count_v := fail_count_v + 1;
            report "FAIL: "
                    & test_name
                    & " divide-by-zero handling incorrect -> quotient = "
                    & integer'image(actual_q)
                    severity note;
        end if;
    end procedure;

    type test_vector_t is record
        dividend : integer;
        divisor  : integer;
    end record;

    type test_vector_array_t is array(natural range <>) of test_vector_t;
    constant test_vectors : test_vector_array_t :=
    (
        -- Divide-by-zero with a non-zero dividend.
        -- Verifies error detection and handling for an invalid divisor.
        (100, 0),

        -- Divide-by-zero with a zero dividend.
        -- Verifies that the error condition is still detected when both
        -- operands are zero.
        (0, 0),

        -- Valid division after divide-by-zero transactions.
        -- Verifies DUT recovery and correct operation after an error event.
        (200, 10)
    );

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    dut : entity work.trunc_restore_div
        port map (
            clk_i       => clk_i,
            rst_i       => rst_i,
            ena_i       => ena_i,
            num_i       => num_i,
            dnum_i      => dnum_i,
            quot_o      => quot_o,
            q_rdy_o     => q_rdy_o,
            div_err_o   => div_err_o
        );

    ----------------------------------------------------------------
    -- Clock generator
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk_i <= '0';
            wait for 5 ns;
            clk_i <= '1';
            wait for 5 ns;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- Stimulus process
    ----------------------------------------------------------------
    stim_proc : process
        ----------------------------------------------------------------
        -- Reference model signal
        ----------------------------------------------------------------
        variable expected_q : integer := 0;
        variable pass_count_v : integer := 0;
        variable fail_count_v : integer := 0;
    begin

        -- Reset phase
        rst_i <= '1';
        wait for 30 ns;
        wait until rising_edge(clk_i);  -- to prevent any edge simulation conflict between reset and clk_i
        rst_i <= '0';

        wait for 10 ns;

        ----------------------------------------------------------------
        -- Loop Test
        ----------------------------------------------------------------
        for i in test_vectors'range loop

            num_i <= std_logic_vector(to_unsigned(test_vectors(i).dividend,num_i'length));

            dnum_i <= std_logic_vector(to_unsigned(test_vectors(i).divisor,dnum_i'length));

            wait until rising_edge(clk_i);
            ena_i <= '1';

            wait until rising_edge(clk_i);
            ena_i <= '0';

            wait until q_rdy_o='1';

            if test_vectors(i).divisor /= 0 then
                expected_q :=  test_vectors(i).dividend / test_vectors(i).divisor;
                check_result(
                    "Test " & integer'image(i),
                    to_integer(unsigned(quot_o)),
                    expected_q,
                    pass_count_v,
                    fail_count_v
                );
            else
                check_div_error(
                    "Test " & integer'image(i),
                    to_integer(unsigned(quot_o)),
                    div_err_o,
                    pass_count_v,
                    fail_count_v
                );            
            end if;
        end loop;

        ----------------------------------------------------------------
        -- Finish simulation
        ----------------------------------------------------------------
        report "Divider reference-model verification completed"
            severity note;

        report "-----------------------------------"
            severity note;

        report "SCOREBOARD SUMMARY"
            severity note;

        report "PASS COUNT = "
            & integer'image(pass_count_v)
            severity note;

        report "FAIL COUNT = "
            & integer'image(fail_count_v)
            severity note;

        report "-----------------------------------"
            severity note;
    wait;

    end process;

end architecture;