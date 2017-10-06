library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity instruction_decode is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        PC: in word_t;
        INS: in word_t;
        
        -- reg file
        READ_ADDR0: out reg_addr_t;
        READ_DATA0: in word_t;
        
        READ_ADDR1: out reg_addr_t;
        READ_DATA1: in word_t;
        
        PC_O: out word_t;
        OP: out op_t;
        FUNCT: out funct_t;
        ALU_OP: out alu_op_t;
        OPERAND0: out word_t;
        OPERAND1: out word_t;
        WRITE_ADDR: out reg_addr_t;
        WRITE_MEM_DATA: out word_t;
        IS_LOAD: out std_logic;
        
        EX_IS_LOAD: in std_logic;
        EX_WRITE_ADDR: in reg_addr_t;
        
        BRANCH_EN: out std_logic;
        BRANCH_PC: out word_t
    );
end;

architecture behavioral of instruction_decode is
    signal reg0_data, reg1_data: word_t;
    signal rs, rt, rd: reg_addr_t;
    signal shamt_buff: std_logic_vector(4 downto 0);
    signal op_buff: op_t;
    signal funct_buff: funct_t;
    signal imm, zero_bits, sign_bits: std_logic_vector(15 downto 0);
    signal ins_addr: std_logic_vector(25 downto 0);
begin
    op_buff <= INS(31 downto 26);
    rs <= INS(25 downto 21);
    rt <= INS(20 downto 16);
    rd <= INS(15 downto 11);
    shamt_buff <= INS(10 downto 6);
    funct_buff <= INS(5 downto 0);
    imm <= INS(15 downto 0);
    zero_bits <= (others => '0');
    sign_bits <= (others => imm(15));
    ins_addr <= INS(25 downto 0);
    
    -- read reg 0
    process(READ_DATA0)
    begin
        reg0_data <= READ_DATA0;
    end process;
    
    -- read reg 1
    process(READ_DATA1)
    begin
        reg1_data <= READ_DATA1;
    end process;
    
    process(all)
    begin
        if RST = '1' then
            READ_ADDR0 <= (others => '0');
            READ_ADDR1 <= (others => '0');
            PC_O <= (others => '0');
            OP <= (others => '0');
            FUNCT <= (others => '0');
            ALU_OP <= alu_nop;
            OPERAND0 <= (others => '0');
            OPERAND1 <= (others => '0');
            WRITE_ADDR <= (others => '0');
            WRITE_MEM_DATA <= (others => '0');
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => '0');
            IS_LOAD <= '0';
        else
            READ_ADDR0 <= rs;
            READ_ADDR1 <= rt;
            PC_O <= PC;
            OP <= op_buff;
            FUNCT <= funct_buff;
            ALU_OP <= alu_nop;
            OPERAND0 <= (others => 'X');
            OPERAND1 <= (others => 'X');
            WRITE_ADDR <= (others => '0');
            WRITE_MEM_DATA <= (others => 'X');
            BRANCH_EN <= '0';
            BRANCH_PC <= PC;
            IS_LOAD <= '0';

            case op_buff is
                when op_special => -- type R
                    OPERAND0 <= reg0_data;
                    OPERAND1 <= reg1_data;
                    WRITE_ADDR <= rd;
                    case funct_buff is
                        when func_addu =>
                            ALU_OP <= alu_addu;
                        when others =>
                            
                    end case;
                when op_ori => -- type I, zero extended
                    ALU_OP <= alu_or;
                    OPERAND0 <= reg0_data;
                    OPERAND1 <= zero_bits & imm;
                    WRITE_ADDR <= rt;
                /*when op_addiu => -- type I, sign extended
                    ALU_OP <= alu_addu;
                    OPERAND0 <= reg0_data;
                    OPERAND1 <= sign_bits & imm;
                    WRITE_ADDR <= rt;
                */
                when op_lw =>
                    ALU_OP <= alu_addu;
                    OPERAND0 <= reg0_data;
                    OPERAND1 <= sign_bits & imm;
                    WRITE_ADDR <= rt;
                    IS_LOAD <= '1';
                when op_sw =>
                    ALU_OP <= alu_addu;
                    OPERAND0 <= reg0_data;
                    OPERAND1 <= sign_bits & imm;
                    WRITE_MEM_DATA <= reg1_data;
                when op_j => -- type J
                    OPERAND0 <= (others => 'X');
                    OPERAND1 <= (others => 'X');
                    WRITE_ADDR <= "0" & x"0";
                    
                    BRANCH_EN <= '1';
                    BRANCH_PC <= PC(31 downto 28) & ins_addr & "00";
                when op_jal => -- type J
                    -- retaddr = PC + 4
                    -- PC points to next ins, +4 is caused by branch delay slot
                    ALU_OP <= alu_addu;
                    OPERAND0 <= PC;
                    OPERAND1 <= x"00000004";
                    WRITE_ADDR <= "11111"; -- 31
                    
                    BRANCH_EN <= '1';
                    BRANCH_PC <= PC(31 downto 28) & ins_addr & "00";
                when others =>
            end case;
        end if;
    end process;
    
    -- load hazard
    STALL_REQ <= '1' when EX_IS_LOAD = '1' and 
                          (EX_WRITE_ADDR = READ_ADDR0 or EX_WRITE_ADDR = READ_ADDR1) else '0';
end;