library IEEE;
use IEEE.std_logic_1164.all;

package types is
    subtype word_t is std_logic_vector(31 downto 0);
    subtype op_t is std_logic_vector(5 downto 0);
    subtype funct_t is std_logic_vector(5 downto 0);
    subtype reg_addr_t is std_logic_vector(4 downto 0);
    subtype stall_t is std_logic_vector(5 downto 0);
    type reg_file_t is array(31 downto 0) of word_t;
end;