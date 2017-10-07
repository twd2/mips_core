library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.types.all;

entity ram is
    port
    (
        CLK: in std_logic;
        
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t
    );
end;

architecture behavioral of ram is
    component rom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END component;
begin
    rom_inst: rom
    port map
    (
        address => BUS_REQ.addr(11 downto 2),
        clock => not CLK,
        q => BUS_RES.data
    );

    BUS_RES.done <= '1';
    BUS_RES.tlb_miss <= '0';
    BUS_RES.page_fault <= '0';
    BUS_RES.error <= '1' when BUS_REQ.nread_write = '1' or BUS_REQ.addr(1 downto 0) /= "00" else '0';
end;