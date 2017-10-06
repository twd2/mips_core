library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity memory_access is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        PC: in word_t;
        OP: in op_t;
        FUNCT: in funct_t;
        ALU_RESULT: in word_t;
        WRITE_EN: in std_logic;
        WRITE_ADDR: in reg_addr_t;
        WRITE_DATA: in word_t;
        WRITE_MEM_DATA: in word_t;
        
        PC_O: out word_t;
        OP_O: out op_t;
        FUNCT_O: out funct_t;
        WRITE_EN_O: out std_logic;
        WRITE_ADDR_O: out reg_addr_t;
        WRITE_DATA_O: out word_t;
        
        -- bus
        BUS_ADDR: out word_t;
        BUS_DATA_IN: in word_t;
        BUS_DATA_OUT: out word_t;
        BUS_BYTE_MASK: out std_logic_vector(3 downto 0);
        BUS_EN: out std_logic;
        BUS_nREAD_WRITE: out std_logic;
        BUS_DONE: in std_logic;
        BUS_ERROR: in std_logic
    );
end;

architecture behavioral of memory_access is
begin
    STALL_REQ <= '0'; -- TODO

    process(all)
    begin
        if RST = '1' then
            PC_O <= (others => '0');
            OP_O <= (others => '0');
            FUNCT_O <= (others => '0');
            WRITE_EN_O <= '0';
            WRITE_ADDR_O <= (others => '0');
            WRITE_DATA_O <= (others => '0');
            BUS_ADDR <= (others => '0');
            BUS_DATA_OUT <= (others => '0');
            BUS_BYTE_MASK <= (others => '0');
            BUS_EN <= '0';
            BUS_nREAD_WRITE <= '0';
        else
            PC_O <= PC;
            OP_O <= OP;
            FUNCT_O <= FUNCT;
            WRITE_EN_O <= WRITE_EN;
            WRITE_ADDR_O <= WRITE_ADDR;
            WRITE_DATA_O <= WRITE_DATA;
            BUS_ADDR <= (others => 'X');
            BUS_DATA_OUT <= (others => 'X');
            BUS_BYTE_MASK <= (others => '0');
            BUS_EN <= '0';
            BUS_nREAD_WRITE <= '0';
            
            case OP is
                when op_lw =>
                    BUS_ADDR <= ALU_RESULT;
                    BUS_BYTE_MASK <= (others => '1');
                    BUS_EN <= '1';
                    BUS_nREAD_WRITE <= '0';
                    WRITE_DATA_O <= BUS_DATA_IN;
                when op_sw =>
                    BUS_ADDR <= ALU_RESULT;
                    BUS_BYTE_MASK <= (others => '1');
                    BUS_EN <= '1';
                    BUS_nREAD_WRITE <= '1';
                    BUS_DATA_OUT <= WRITE_MEM_DATA;
                when others =>
            end case;
            -- TODO: check BUS_DONE or BUS_ERROR
        end if;
    end process;
end;