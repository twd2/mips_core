library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.types.all;

entity mips_sopc is
    port
    (
        CLK: in std_logic;
        nRST: in std_logic;

        testen: out std_logic;
        test_0: out reg_addr_t;
        test_1: out word_t
    );
end;

architecture behavioral of mips_sopc is
    component mips_core is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;

            INS_BUS_REQ: out bus_request_t;
            INS_BUS_RES: in bus_response_t;
            DATA_BUS_REQ: out bus_request_t;
            DATA_BUS_RES: in bus_response_t;

            IRQ: in std_logic_vector(5 downto 0);

            testen: out std_logic;
            test_0: out reg_addr_t;
            test_1: out word_t
        );
    end component;

    component ram is
        port
        (
            CLK: in std_logic;
            
            BUS_REQ: in bus_request_t;
            BUS_RES: out bus_response_t
        );
    end component;

    component memory IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            byteena		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            wren		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END component;

    signal RST: std_logic;
    signal ins_bus_req: bus_request_t;
    signal ins_bus_res: bus_response_t;
    signal data_bus_req: bus_request_t;
    signal data_bus_res: bus_response_t;
begin
    RST <= not nRST;

    ram_inst: ram
    port map
    (
        CLK => CLK,

        BUS_REQ => ins_bus_req,
        BUS_RES => ins_bus_res
    );

    memory_inst: memory
    port map
    (
        address => data_bus_req.addr(11 downto 2),
        byteena => data_bus_req.byte_mask,
        clock => not CLK,
        data => data_bus_req.data,
        wren => data_bus_req.nread_write,
        q => data_bus_res.data
    );

    -- TODO: real bus
    data_bus_res.done <= '1';
    data_bus_res.tlb_miss <= '0';
    data_bus_res.page_fault <= '0';
    data_bus_res.error <= '0';
    
    mips_core_inst: mips_core
    port map
    (
        CLK => CLK,
        RST => RST,
        
        INS_BUS_REQ => ins_bus_req,
        INS_BUS_RES => ins_bus_res,
        DATA_BUS_REQ => data_bus_req,
        DATA_BUS_RES => data_bus_res,
        
        IRQ => (others => '0'),
        
        testen => testen,
        test_0 => test_0,
        test_1 => test_1
    );
end;