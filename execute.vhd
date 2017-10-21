library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity execute is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        PC: in word_t;
        OP: in op_t;
        FUNCT: in funct_t;
        ALU_OP: in alu_op_t;
        OPERAND_0: in word_t;
        OPERAND_1: in word_t;
        WRITE_EN: in std_logic;
        WRITE_ADDR: in reg_addr_t;
        WRITE_MEM_DATA: in word_t;
        HI: in word_t;
        LO: in word_t;
        
        PC_O: out word_t;
        OP_O: out op_t;
        FUNCT_O: out funct_t;
        ALU_RESULT: out word_t;
        WRITE_EN_O: out std_logic;
        WRITE_ADDR_O: out reg_addr_t;
        WRITE_DATA: out word_t;
        WRITE_MEM_DATA_O: out word_t;
        HI_WRITE_EN: out std_logic;
        HI_WRITE_DATA: out word_t;
        LO_WRITE_EN: out std_logic;
        LO_WRITE_DATA: out word_t
    );
end;

architecture behavioral of execute is
    component alu is
        port
        (
            RST: in std_logic;

            OP: in alu_op_t;
            OPERAND_0: in word_t;
            OPERAND_1: in word_t;
            
            OVERFLOW: out std_logic;
            RESULT: out word_t
        );
    end component;

    signal alu_result_buff: word_t;
    signal overflow: std_logic;
begin
    alu_inst: alu
    port map
    (
        RST => RST,
        OP => ALU_OP,
        OPERAND_0 => OPERAND_0,
        OPERAND_1 => OPERAND_1,
        
        OVERFLOW => overflow,
        result => alu_result_buff
    );

    STALL_REQ <= '0'; -- TODO
    
    process(all)
    begin
        if RST = '1' then
            PC_O <= (others => '0');
            OP_O <= (others => '0');
            FUNCT_O <= (others => '0');
            ALU_RESULT <= (others => '0');
            WRITE_EN_O <= '0';
            WRITE_ADDR_O <= (others => '0');
            WRITE_DATA <=  (others => '0');
            WRITE_MEM_DATA_O <= (others => '0');
            HI_WRITE_EN <= '0';
            HI_WRITE_DATA <= (others => '0');
            LO_WRITE_EN <= '0';
            LO_WRITE_DATA <= (others => '0');
        else
            PC_O <= PC;
            OP_O <= OP;
            FUNCT_O <= FUNCT;
            ALU_RESULT <= alu_result_buff;
            WRITE_EN_O <= WRITE_EN;
            WRITE_ADDR_O <= WRITE_ADDR;
            WRITE_DATA <= alu_result_buff;
            WRITE_MEM_DATA_O <= WRITE_MEM_DATA;
            HI_WRITE_EN <= '0';
            HI_WRITE_DATA <= (others => '0');
            LO_WRITE_EN <= '0';
            LO_WRITE_DATA <= (others => '0');

            -- TODO(twd2): address of load/store
            case OP is
                when op_special =>
                    case FUNCT is
                        when func_mfhi =>
                            WRITE_DATA <= HI;
                        when func_mflo =>
                            WRITE_DATA <= LO;
                        when func_mthi =>
                            HI_WRITE_EN <= '1';
                            HI_WRITE_DATA <= OPERAND_0;
                        when func_mtlo =>
                            LO_WRITE_EN <= '1';
                            LO_WRITE_DATA <= OPERAND_0;
                        when others =>
                    end case;
                when others =>
            end case;
        end if;
    end process;
end;