library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity reg_file is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        READ_ADDR0: in reg_addr_t;
        READ_DATA0: out word_t;
        
        READ_ADDR1: in reg_addr_t;
        READ_DATA1: out word_t;
        
        WRITE_ADDR: in reg_addr_t;
        WRITE_DATA: in word_t
    );
end;

architecture behavioral of reg_file is
    signal reg: reg_file_t;
    signal read_addr0_i, read_addr1_i, write_addr_i: integer range 0 to reg_count - 1;
begin
    read_addr0_i <= to_integer(unsigned(READ_ADDR0));
    read_addr1_i <= to_integer(unsigned(READ_ADDR1));
    write_addr_i <= to_integer(unsigned(WRITE_ADDR));

    read0_proc:
    process(reg, read_addr0_i)
    begin
        if read_addr0_i /= 0 then
            READ_DATA0 <= reg(read_addr0_i);
        else
            READ_DATA0 <= (others => '0');
        end if;
    end process;
    
    read1_proc:
    process(reg, read_addr1_i)
    begin
        if read_addr1_i /= 0 then
            READ_DATA1 <= reg(read_addr1_i);
        else
            READ_DATA1 <= (others => '0');
        end if;
    end process;
    
    write_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            reg <= (others => (others => '0'));
        elsif rising_edge(CLK) then
            if write_addr_i /= 0 then
                reg(write_addr_i) <= WRITE_DATA;
            end if;
        end if;
    end process;
end;