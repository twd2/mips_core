library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity write_back is
    port
    (
        RST: in std_logic;

        PC: in word_t;
        OP: in op_t;
        FUNCT: in funct_t;
        WRITE_ADDR: in reg_addr_t;
        WRITE_DATA: in word_t;
        
        WRITE_ADDR_O: out reg_addr_t;
        WRITE_DATA_O: out word_t
    );
end;

architecture behavioral of write_back is
begin
    process(RST, WRITE_ADDR, WRITE_DATA)
    begin
        if RST = '1' then
            WRITE_ADDR_O <= (others => '0');
            WRITE_DATA_O <= (others => '0');
        else
            WRITE_ADDR_O <= WRITE_ADDR;
            WRITE_DATA_O <= WRITE_DATA;
        end if;
    end process;
end;