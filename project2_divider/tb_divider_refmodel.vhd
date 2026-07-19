library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_divider_refmodel is
end entity;

architecture sim of tb_divider_refmodel is

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
    begin

        -- Reset phase
        rst_i <= '1';
        wait for 30 ns;
        rst_i <= '0';

        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test 1
        ----------------------------------------------------------------
        num_i  <= std_logic_vector(to_unsigned(100, num_i'length));
        dnum_i <= std_logic_vector(to_unsigned(10, dnum_i'length));

        wait until rising_edge(clk_i);
        ena_i <= '1';

        wait until rising_edge(clk_i);
        ena_i <= '0';

        wait until q_rdy_o = '1';
        expected_q := 100 / 10;

        assert to_integer(unsigned(quot_o)) = expected_q
            report "Mismatch Test 1"
            severity error;

        ----------------------------------------------------------------
        -- Test 2
        ----------------------------------------------------------------
        num_i  <= std_logic_vector(to_unsigned(99, num_i'length));
        dnum_i <= std_logic_vector(to_unsigned(3, dnum_i'length));

        wait until rising_edge(clk_i);
        ena_i <= '1';

        wait until rising_edge(clk_i);
        ena_i <= '0';

        wait until q_rdy_o = '1';
        expected_q := 99 / 3;

        assert to_integer(unsigned(quot_o)) = expected_q
            report "Mismatch Test 2"
            severity error;

        ----------------------------------------------------------------
        -- Test 3
        ----------------------------------------------------------------
        num_i  <= std_logic_vector(to_unsigned(200, num_i'length));
        dnum_i <= std_logic_vector(to_unsigned(5, dnum_i'length));

        wait until rising_edge(clk_i);
        ena_i <= '1';

        wait until rising_edge(clk_i);
        ena_i <= '0';

        wait until q_rdy_o = '1';
        expected_q := 200 / 5;

        assert to_integer(unsigned(quot_o)) = expected_q
            report "Mismatch Test 3"
            severity error;

        ----------------------------------------------------------------
        -- Finish simulation
        ----------------------------------------------------------------
        report "Divider reference-model verification completed"
            severity note;

        wait;

    end process;

end architecture;