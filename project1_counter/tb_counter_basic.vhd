library ieee;
use ieee.std_logic_1164.all;

entity tb_counter_basic is
end entity;

architecture sim of tb_counter_basic is

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal count : std_logic_vector(3 downto 0);

begin

    -- DUT
    dut : entity work.counter
        port map (
            clk   => clk,
            rst   => rst,
            count => count
        );

    -- Clock generator
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus
    stim : process
    begin
        rst <= '1';
        wait for 25 ns;

        rst <= '0';
        wait for 200 ns;

        -- report "Simulation finished";
        -- wait;
        std.env.stop;
    end process;

    -- Checker (DIRECTED / STEP-BY-STEP)
    checker : process
    begin

        wait until rst = '0';

        wait until rising_edge(clk);
        assert count = "0001"
            report "ERROR: expected 1"
            severity error;

        wait until rising_edge(clk);
        assert count = "0010"
            report "ERROR: expected 2"
            severity error;

        wait until rising_edge(clk);
        assert count = "0011"
            report "ERROR: expected HOLD at 3"
            severity error;

        report "Counter basic verification passed";

        wait;

    end process;

end architecture;