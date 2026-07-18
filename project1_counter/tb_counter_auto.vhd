library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_counter_auto is
end entity;

architecture sim of tb_counter_auto is

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal count : std_logic_vector(3 downto 0);

    -- Error tracking (visible in waveform)
    signal error_detected : boolean := false;

    --------------------------------------------------------------------
    -- PROCEDURE: pure checker (NO timing inside)
    --------------------------------------------------------------------
    procedure check_count (
        signal count_sig : in std_logic_vector(3 downto 0);
        variable err     : inout boolean;
        constant exp     : in std_logic_vector(3 downto 0)
    ) is
    begin
        if count_sig /= exp then
            err := true;

            assert false
                report "ERROR: expected=" & integer'image(to_integer(unsigned(exp))) &
                       " actual=" & integer'image(to_integer(unsigned(count_sig)))
                severity error;
        end if;
    end procedure;

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    dut : entity work.counter
        port map (
            clk   => clk,
            rst   => rst,
            count => count
        );

    --------------------------------------------------------------------
    -- Clock generator
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    --------------------------------------------------------------------
    -- Stimulus (multiple verification sessions)
    --------------------------------------------------------------------
    stim : process
    begin
        -- Session 1
        rst <= '1';
        wait for 30 ns;
        wait until rising_edge(clk);    -- important for synchronisation of other processes
        rst <= '0';
        wait for 100 ns;

        -- Session 2 (reset again → regression-style idea)
        rst <= '1';
        wait for 20 ns;
        wait until rising_edge(clk);    -- important for synchronisation of other processes
        rst <= '0';
        wait for 100 ns;

        assert false report "Simulation finished" severity note;
        wait;
    end process;

    --------------------------------------------------------------------
    -- CHECKER PROCESS
    --------------------------------------------------------------------
    checker : process
        variable expected       : unsigned(3 downto 0);
        variable local_error    : boolean := false;
    begin

        wait until rst = '0';
        wait until rising_edge(clk);    -- important for synchronisation of other processes

        expected := (others => '0');
        local_error := false;
        error_detected <= false;

        ----------------------------------------------------------------
        -- verification sequence
        ----------------------------------------------------------------
        for i in 1 to 5 loop

            wait until rising_edge(clk);

            if expected < 3 then
                expected := expected + 1;
            end if;

            check_count(
                count,
                local_error,
                std_logic_vector(expected)
            );

            error_detected <= local_error;

        end loop;

        if local_error = false then
            report "Counter automated verification passed";
        else
            report "Counter automated verification FAILED";
        end if;

        -- wait for next reset assertion
        wait until rst = '1';

    end process;

end architecture;