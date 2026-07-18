library ieee;
use ieee.std_logic_1164.all;

entity tb_hello is
end entity;

architecture sim of tb_hello is
signal done : boolean := false;
begin

    process
    begin
        report "Hello Verification Lab!"
        wait for 100 ns;
        done <= true;       -- to see the waveform in the gtkwave software
        wait;
    end process;

end architecture;