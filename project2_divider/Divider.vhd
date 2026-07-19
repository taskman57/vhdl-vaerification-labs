library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity trunc_restore_div is
    generic(
        NUMERATOR_WIDTH_G       : integer := 34;
        DENUMERATOR_WIDTH_G     : integer := 10;
        QUOTIENT_WIDTH_G        : integer := 24
    );
    Port (
        clk_i       : in STD_LOGIC;
        rst_i       : in STD_LOGIC;
        ena_i       : in std_logic;
        num_i       : in STD_LOGIC_VECTOR(NUMERATOR_WIDTH_G-1 downto 0);
        dnum_i      : in STD_LOGIC_VECTOR(DENUMERATOR_WIDTH_G-1 downto 0);
        quot_o      : out STD_LOGIC_VECTOR(QUOTIENT_WIDTH_G-1 downto 0);
        q_rdy_o     : out std_logic
    );
end trunc_restore_div;

architecture Behavioral of trunc_restore_div is
    signal num_tmp_s    : unsigned(DENUMERATOR_WIDTH_G downto 0);
    signal rem_tmp_s    : unsigned(QUOTIENT_WIDTH_G-1 downto 0);
    signal quot_s       : std_logic_vector(QUOTIENT_WIDTH_G-1 downto 0);
    signal divisor_s    : unsigned(DENUMERATOR_WIDTH_G-1 downto 0);
    signal div_tsk_s    : integer range 0 to 3:=0;
    signal div_itr_s    : integer range 0 to QUOTIENT_WIDTH_G-1:=0;

begin
    SEQ_DIV_PROC:
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                quot_o      <= (others => '0');
                num_tmp_s   <= (others => '0');
                rem_tmp_s   <= (others => '0');
                quot_s      <= (others => '0');
                divisor_s   <= (others => '0');
                div_tsk_s   <= 0;
                q_rdy_o     <= '0';
            else
                q_rdy_o     <= '0';
                case div_tsk_s is
                    when 0  =>
                        if ena_i = '1' then
                            num_tmp_s   <= unsigned('0' & num_i(NUMERATOR_WIDTH_G-1 downto QUOTIENT_WIDTH_G));
                            rem_tmp_s   <= unsigned(num_i(QUOTIENT_WIDTH_G-1 downto 0));
                            divisor_s   <= unsigned(dnum_i);
                            quot_s      <= (others => '0');
                            div_tsk_s   <= 1;
                            div_itr_s   <= 0;
                        end if;
                    when 1  =>
                        quot_s(0) <= '0';
                        if num_tmp_s >= divisor_s then
                            num_tmp_s   <= num_tmp_s - divisor_s;
                            quot_s(0)   <= '1';
                        end if;
                        div_tsk_s       <= 2;
                    when 2  =>
                        num_tmp_s   <= num_tmp_s(num_tmp_s'length-2 downto 0) & rem_tmp_s(QUOTIENT_WIDTH_G-1-div_itr_s);
                        quot_s      <= quot_s(quot_s'length-2 downto 0) & '0';
                        if div_itr_s < QUOTIENT_WIDTH_G-1 then
                            div_itr_s   <= div_itr_s +1;
                            div_tsk_s   <= 1;
                        else
                            div_tsk_s   <= 3;
                        end if;
                    when 3  =>
                        if num_tmp_s >= divisor_s then
                            quot_o(0) <= '1';
                        else
                            quot_o(0) <= '0';
                        end if;
                        quot_o(QUOTIENT_WIDTH_G-1 downto 1) <= quot_s(QUOTIENT_WIDTH_G-1 downto 1);
                        div_tsk_s   <= 0;
                        q_rdy_o     <= '1';
                        div_itr_s   <= 0;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
end Behavioral;