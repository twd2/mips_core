library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity alu is
    port
    (
        RST: in std_logic;

        OP: in alu_op_t;
        OPERAND_0: in word_t;
        OPERAND_1: in word_t;
        
        OVERFLOW: out std_logic;
        RESULT: out word_t
    );
end;

architecture behavioral of alu is
    signal shamt: integer range 0 to 31;
begin
    shamt <= to_integer(unsigned(OPERAND_1(4 downto 0)));

    process(RST, OP, OPERAND_0, OPERAND_1, shamt)
    begin
        if RST = '1' then
            RESULT <= (others => '0');
        else
            case OP is
                when alu_addu =>
                    RESULT <= OPERAND_0 + OPERAND_1;
                when alu_subu =>
                    RESULT <= OPERAND_0 - OPERAND_1;
                when alu_or =>
                    RESULT <= OPERAND_0 or OPERAND_1;
                when alu_and =>
                    RESULT <= OPERAND_0 and OPERAND_1;
                when alu_xor =>
                    RESULT <= OPERAND_0 xor OPERAND_1;
                when alu_nor =>
                    RESULT <= OPERAND_0 nor OPERAND_1;
                when alu_sll =>
                    RESULT <= to_stdlogicvector(to_bitvector(OPERAND_0) sll shamt);
                when alu_srl =>
                    RESULT <= to_stdlogicvector(to_bitvector(OPERAND_0) srl shamt);
                when alu_sra =>
                    RESULT <= to_stdlogicvector(to_bitvector(OPERAND_0) sra shamt);
                when others =>
                    RESULT <= (others => 'X');
            end case;
        end if;
    end process;
    
    -- overflow check
    process(RST, OP, RESULT)
    begin
        if RST = '1' then
            OVERFLOW <= '0';
        else
            OVERFLOW <= '0';
            case OP is
                -- when op_add, op_sub =>
                    -- TODO
                when others =>
            end case;
        end if;
    end process;
end;