library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity reg_forward is
    port
    (
        RST: in std_logic;
        
        ID_READ_ADDR0: in reg_addr_t;
        ID_READ_DATA0: out word_t;
        
        ID_READ_ADDR1: in reg_addr_t;
        ID_READ_DATA1: out word_t;
        
        -- read from reg file
        REG_READ_ADDR0: out reg_addr_t;
        REG_READ_DATA0: in word_t;
        
        REG_READ_ADDR1: out reg_addr_t;
        REG_READ_DATA1: in word_t;
        
        -- ex
        EX_WRITE_EN: in std_logic;
        EX_WRITE_ADDR: in reg_addr_t;
        EX_WRITE_DATA: in word_t;
        
        -- mem
        MEM_WRITE_EN: in std_logic;
        MEM_WRITE_ADDR: in reg_addr_t;
        MEM_WRITE_DATA: in word_t;
        
        -- wb
        WB_WRITE_EN: in std_logic;
        WB_WRITE_ADDR: in reg_addr_t;
        WB_WRITE_DATA: in word_t
    );
end;

architecture behavioral of reg_forward is
    signal ex_write_en_real, mem_write_en_real, wb_write_en_real: std_logic;
begin
    REG_READ_ADDR0 <= ID_READ_ADDR0;
    REG_READ_ADDR1 <= ID_READ_ADDR1;
    
    ex_write_en_real <= '1' when EX_WRITE_EN = '1' and EX_WRITE_ADDR /= "00000" else '0';
    mem_write_en_real <= '1' when MEM_WRITE_EN = '1' and MEM_WRITE_ADDR /= "00000" else '0';
    wb_write_en_real <= '1' when WB_WRITE_EN = '1' and WB_WRITE_ADDR /= "00000" else '0';

    read0_proc:
    process(all)
    begin
        if ex_write_en_real = '1' and ID_READ_ADDR0 = EX_WRITE_ADDR then
            ID_READ_DATA0 <= EX_WRITE_DATA;
        elsif mem_write_en_real = '1' and ID_READ_ADDR0 = MEM_WRITE_ADDR then
            ID_READ_DATA0 <= MEM_WRITE_DATA;
        elsif wb_write_en_real = '1' and ID_READ_ADDR0 = WB_WRITE_ADDR then
            ID_READ_DATA0 <= WB_WRITE_DATA;
        else
            ID_READ_DATA0 <= REG_READ_DATA0;
        end if;
    end process;
    
    read1_proc:
    process(all)
    begin
        if ex_write_en_real = '1' and ID_READ_ADDR1 = EX_WRITE_ADDR then
            ID_READ_DATA1 <= EX_WRITE_DATA;
        elsif mem_write_en_real = '1' and ID_READ_ADDR1 = MEM_WRITE_ADDR then
            ID_READ_DATA1 <= MEM_WRITE_DATA;
        elsif wb_write_en_real = '1' and ID_READ_ADDR1 = WB_WRITE_ADDR then
            ID_READ_DATA1 <= WB_WRITE_DATA;
        else
            ID_READ_DATA1 <= REG_READ_DATA1;
        end if;
    end process;
end;