library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_divider_robustnes is
end entity;

architecture sim of tb_divider_robustnes is

    ----------------------------------------------------------------
    -- DUT signals
    ----------------------------------------------------------------
    signal clk_i   : std_logic := '0';
    signal rst_i   : std_logic := '1';
    signal ena_i   : std_logic := '0';

    signal num_i   : std_logic_vector(33 downto 0):=(others => '0');
    signal dnum_i  : std_logic_vector(9 downto 0):=(others => '0');

    signal quot_o  : std_logic_vector(23 downto 0);
    signal q_rdy_o : std_logic;

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

    type test_vector_t is record
        dividend : integer;
        divisor  : integer;
    end record;

    type test_vector_array_t is array(natural range <>) of test_vector_t;
    constant test_vectors : test_vector_array_t :=
    (
        -- Smallest non-zero quotient.
        -- Verifies lower quotient boundary handling.
        (1, 1),

        -- Maximum supported divisor.
        -- Verifies correct operation at the upper divisor boundary.
        (1023, 1023),

        -- Dividend one count below maximum divisor.
        -- Verifies the dividend < divisor boundary condition.
        (1022, 1023),

        -- Maximum 24-bit quotient value.
        -- Verifies quotient-width boundary handling.
        (16777215, 1),

        -- One count below maximum 24-bit quotient value.
        -- Verifies behavior immediately below the quotient limit.
        (16777214, 1)
    );

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    dut : entity work.trunc_restore_div
        port map (
            clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => ena_i,
            num_i   => num_i,
            dnum_i  => dnum_i,
            quot_o  => quot_o,
            q_rdy_o => q_rdy_o
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

            expected_q :=  test_vectors(i).dividend / test_vectors(i).divisor;

            check_result(
                "Test " & integer'image(i),
                to_integer(unsigned(quot_o)),
                expected_q,
                pass_count_v,
                fail_count_v
            );
        end loop;

        ----------------------------------------------------------------
        -- Applying reset assertion test
        ----------------------------------------------------------------
        num_i <= std_logic_vector(to_unsigned(180,num_i'length));
        dnum_i <= std_logic_vector(to_unsigned(14,dnum_i'length));
        wait until rising_edge(clk_i);
        ena_i <= '1';

        wait until rising_edge(clk_i);
        ena_i <= '0';

        for i in 0 to 4 Loop
            wait until rising_edge(clk_i);
        end loop;
        rst_i <= '1';
        wait until rising_edge(clk_i);
        rst_i <= '0';

        num_i <= std_logic_vector(to_unsigned(200,num_i'length));
        dnum_i <= std_logic_vector(to_unsigned(5,dnum_i'length));
        wait until rising_edge(clk_i);
        ena_i <= '1';

        wait until rising_edge(clk_i);
        ena_i <= '0';

        wait until q_rdy_o='1';

        expected_q :=  200 / 5;

        check_result(
            "Test Reset assertion ",
            to_integer(unsigned(quot_o)),
            expected_q,
            pass_count_v,
            fail_count_v
        );
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