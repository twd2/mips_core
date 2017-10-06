library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity instruction_fetch is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        STALL_REQ: out std_logic;
        STALL: in stall_t;

        ADDR: out word_t;
        DATA: in word_t;
        
        PC: out word_t;
        INS: out word_t;
        
        BRANCH_EN: in std_logic;
        BRANCH_PC: in word_t
    );
end;

architecture behavioral of instruction_fetch is
    signal pc_4, next_pc: word_t;
    signal pc_reg: word_t;
begin
    pc_4 <= pc_reg + 4;
    ADDR <= pc_reg; 
    INS <= DATA; -- TODO(twd2): bus controller
    PC <= pc_4;
    STALL_REQ <= '0'; -- TODO

    process(pc_4, BRANCH_EN, BRANCH_PC)
    begin
        if BRANCH_EN = '1' then
            next_pc <= BRANCH_PC;
        else
            next_pc <= pc_4;
        end if;
    end process;

    process(CLK, RST)
    begin
        if RST = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(CLK) then
            if STALL(stage_if downto 0) = "01" then
                pc_reg <= (others => '0');
            elsif STALL(stage_if downto 0) = "11" then
                -- do nothing
            else
                pc_reg <= next_pc;
            end if;
        end if;
    end process;
end;