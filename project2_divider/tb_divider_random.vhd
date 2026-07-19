library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.uniform;
use IEEE.math_real.floor;

entity tb_divider_random is
    generic(
        NUM_TESTS_G : integer := 100
    );
end entity;

architecture sim of tb_divider_random is

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

    procedure check_result(
        constant test_name : string;
        constant actual    : integer;
        constant expected  : integer;
        variable pass_count_v : inout integer;
        variable fail_count_v : inout integer
    )
    is
    begin

        if actual = expected then

            pass_count_v := pass_count_v + 1;

            report "PASS: "
            & test_name
            & " -> quotient = "
            & integer'image(actual)
            severity note;

        else

            fail_count_v := fail_count_v + 1;

            report "FAIL: "
            & test_name
            & " expected="
            & integer'image(expected)
            & " actual="
            & integer'image(actual)
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

    procedure random_slv(
        variable seed1_v : inout positive;
        variable seed2_v : inout positive;
        constant width   : integer;
        variable result  : out std_logic_vector
    )
    is
        variable rand_v : real;
    begin

        for i in result'range loop

            uniform(seed1_v, seed2_v, rand_v);

            if rand_v < 0.5 then
                result(i) := '0';
            else
                result(i) := '1';
            end if;

        end loop;

    end procedure;
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
        variable seed1_v    : positive:=491236;
        variable seed2_v    : positive:=1163;
        variable rand_num_v  : std_logic_vector(num_i'range);
        variable rand_dnum_v : std_logic_vector(dnum_i'range);
        variable pass_count_v : integer := 0;
        variable fail_count_v : integer := 0;
        variable old_fail_v     : integer := 0;
        variable full_quot_v : unsigned(33 downto 0);
        variable expected_unsigned_v : unsigned(23 downto 0);
        variable big_v          : boolean:= false;
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
        for i in 1 to NUM_TESTS_G loop

            random_slv(seed1_v, seed2_v, num_i'length, rand_num_v);
            num_i <= rand_num_v;
            random_slv(seed1_v, seed2_v, dnum_i'length, rand_dnum_v);
            dnum_i <= rand_dnum_v;
            wait until rising_edge(clk_i);
            ena_i <= '1';

            wait until rising_edge(clk_i);
            ena_i <= '0';
            big_v := false;
            old_fail_v    := fail_count_v;
            wait until q_rdy_o='1';

            if unsigned(rand_dnum_v) /= 0 then
                full_quot_v  := unsigned(rand_num_v) / unsigned(rand_dnum_v);
                if full_quot_v <= to_unsigned(2**24-1, full_quot_v'length) then
                expected_unsigned_v := resize(full_quot_v, expected_unsigned_v'length);
                    check_result(
                        "Test " & integer'image(i),
                        to_integer(unsigned(quot_o)),
                        to_integer(expected_unsigned_v),
                        pass_count_v,
                        fail_count_v
                    );
                else
                    big_v   := true;
                    report " Skipping oversized quotient test case! "
                    severity note;
                end if;
            else
                check_div_error(
                    "Test " & integer'image(i),
                    to_integer(unsigned(quot_o)),
                    div_err_o,
                    pass_count_v,
                    fail_count_v
                );            
            end if;
            if old_fail_v /= fail_count_v or big_v then
                report " Num: "
                    & "0x"
                    & to_hex(rand_num_v)
                    severity note;
                report " Denum: "
                    & "0x"
                    & to_hex(rand_dnum_v)
                    severity note;
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