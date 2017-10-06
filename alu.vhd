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
        OPERAND0: in word_t;
        OPERAND1: in word_t;
        
        OVERFLOW: out std_logic;
        RESULT: out word_t
    );
end;

architecture behavioral of alu is
    signal shamt: integer range 0 to 31;
begin
    shamt <= to_integer(unsigned(OPERAND1(4 downto 0)));

    process(RST, OP, OPERAND0, OPERAND1, shamt)
    begin
        if RST = '1' then
            RESULT <= (others => '0');
        else
            case OP is
                when alu_addu =>
                    RESULT <= OPERAND0 + OPERAND1;
                when alu_subu =>
                    RESULT <= OPERAND0 - OPERAND1;
                when alu_or =>
                    RESULT <= OPERAND0 or OPERAND1;
                when alu_and =>
                    RESULT <= OPERAND0 and OPERAND1;
                when alu_xor =>
                    RESULT <= OPERAND0 xor OPERAND1;
                when alu_not =>
                    RESULT <= not OPERAND0;
                when alu_neg =>
                    RESULT <= not OPERAND0 + 1;
                when alu_sll =>
                    RESULT <= to_stdlogicvector(to_bitvector(OPERAND0) sll shamt);
                when alu_slr =>
                    RESULT <= to_stdlogicvector(to_bitvector(OPERAND0) srl shamt);
                when alu_sar =>
                    RESULT <= to_stdlogicvector(to_bitvector(OPERAND0) sra shamt);
                when alu_sel0 =>
                    RESULT <= OPERAND0;
                when alu_sel1 =>
                    RESULT <= OPERAND1;
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