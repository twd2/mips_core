library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity if_id is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        STALL: in stall_t;

        IF_PC: in word_t;
        IF_INS: in word_t;
        
        ID_PC: out word_t;
        ID_INS: out word_t
    );
end;

architecture behavioral of if_id is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            ID_PC <= (others => '0');
            ID_INS <= (others => '0');
        elsif rising_edge(CLK) then
            if STALL(stage_id downto 0) = "011" then
                ID_PC <= (others => '0');
                ID_INS <= ins_nop;
            elsif STALL(stage_id downto 0) = "111" then
                -- do nothing
            else
                ID_PC <= IF_PC;
                ID_INS <= IF_INS;
            end if;
        end if;
    end process;
end;