library ieee;
use ieee.std_logic_1164.all;

entity FlipFlop is
    port (DIN : in std_logic;
       DOUT : out std_logic;
       ENABLE : in std_logic;
       CLK,RST : in std_logic		 
    );
end entity;

architecture comportamento of FlipFlop is
begin
    -- In Altera devices, register signals have a set priority.
    -- The HDL design should reflect this priority.
    process(RST, CLK)
    begin
		-- At a clock edge, if asynchronous signals have not taken priority,
		-- respond to the appropriate synchronous signal.
		-- Check for synchronous reset, then synchronous load.
		-- If none of these takes precedence, update the register output
		-- to be the register input.
		-- The asynchronous reset signal has the highest priority
        if (RST = '1') then
            DOUT <= '0';    -- Código reconfigurável.
        else
            -- At a clock edge, if asynchronous signals have not taken priority,
            -- respond to the appropriate synchronous signal.
            -- Check for synchronous reset, then synchronous load.
            -- If none of these takes precedence, update the register output
            -- to be the register input.
            if (rising_edge(CLK)) then
                if (ENABLE = '1') then
                        DOUT <= DIN;
                end if;
            end if;
			end if;
 end process;
end architecture;