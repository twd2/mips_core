library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.types.all;

entity ram is
    port
    (
        CLK: in std_logic;
        
        ADDR: in word_t;
        DATA: out word_t
    );
end;

architecture behavioral of ram is
    component rom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END component;
    
    signal q: word_t;
begin
    rom_inst: rom
    port map
    (
        address => ADDR(11 downto 2),
        clock => not CLK,
        q => q
    );

    process (ADDR, q)
    begin
        if ADDR(1 downto 0) = "00" then
            DATA <= q;
        else
            DATA <= x"DEADBEEF";
        end if;
    end process;
end;