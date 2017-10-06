library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.types.all;

entity mips_core is
    port
    (
        CLK: in std_logic;
        nRST: in std_logic;
        
        
        test0: out reg_addr_t;
        test1: out word_t
    );
end;

architecture behavioral of mips_core is
    component ram is
        port
        (
            CLK: in std_logic;
            
            ADDR: in word_t;
            DATA: out word_t
        );
    end component;
    
    component reg_file is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            READ_ADDR0: in reg_addr_t;
            READ_DATA0: out word_t;
            
            READ_ADDR1: in reg_addr_t;
            READ_DATA1: out word_t;
            
            WRITE_ADDR: in reg_addr_t;
            WRITE_DATA: in word_t
        );
    end component;
    
    component reg_forward is
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
    end component;

    component controller is
        port
        (
            RST: in std_logic;

            IF_STALL_REQ: in std_logic;
            ID_STALL_REQ: in std_logic;
            EX_STALL_REQ: in std_logic;
            MEM_STALL_REQ: in std_logic;
            
            STALL: out stall_t
        );
    end component;
    
    component instruction_fetch is
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
    end component;
    
    component if_id is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;

            IF_PC: in word_t;
            IF_INS: in word_t;
            
            ID_PC: out word_t;
            ID_INS: out word_t
        );
    end component;

    component instruction_decode is
        port
        (
            RST: in std_logic;
            
            STALL_REQ: out std_logic;

            PC: in word_t;
            INS: in word_t;
            
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
    end component;
    
    component id_ex is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;

            ID_PC: in word_t;
            ID_OP: in op_t;
            ID_FUNCT: in funct_t;
            ID_ALU_OP: in alu_op_t;
            ID_OPERAND0: in word_t;
            ID_OPERAND1: in word_t;
            ID_WRITE_ADDR: in reg_addr_t;
            ID_WRITE_MEM_DATA: in word_t;
            ID_IS_LOAD: in std_logic;

            EX_PC: out word_t;
            EX_OP: out op_t;
            EX_FUNCT: out funct_t;
            EX_ALU_OP: out alu_op_t;
            EX_OPERAND0: out word_t;
            EX_OPERAND1: out word_t;
            EX_WRITE_ADDR: out reg_addr_t;
            EX_WRITE_MEM_DATA: out word_t;
            EX_IS_LOAD: out std_logic
        );
    end component;

    component execute is
        port
        (
            RST: in std_logic;
            
            STALL_REQ: out std_logic;

            PC: in word_t;
            OP: in op_t;
            FUNCT: in funct_t;
            ALU_OP: in alu_op_t;
            OPERAND0: in word_t;
            OPERAND1: in word_t;
            WRITE_ADDR: in reg_addr_t;
            WRITE_MEM_DATA: in word_t;
            
            PC_O: out word_t;
            OP_O: out op_t;
            FUNCT_O: out funct_t;
            ALU_RESULT: out word_t;
            WRITE_ADDR_O: out reg_addr_t;
            WRITE_DATA: out word_t;
            WRITE_MEM_DATA_O: out word_t
        );
    end component;
 
    component ex_mem is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;

            EX_PC: in word_t;
            EX_OP: in op_t;
            EX_FUNCT: in funct_t;
            EX_ALU_RESULT: in word_t;
            EX_WRITE_ADDR: in reg_addr_t;
            EX_WRITE_DATA: in word_t;
            EX_WRITE_MEM_DATA: in word_t;
            
            MEM_PC: out word_t;
            MEM_OP: out op_t;
            MEM_FUNCT: out funct_t;
            MEM_ALU_RESULT: out word_t;
            MEM_WRITE_ADDR: out reg_addr_t;
            MEM_WRITE_DATA: out word_t;
            MEM_WRITE_MEM_DATA: out word_t
        );
    end component;
 
    component memory_access is
        port
        (
            RST: in std_logic;
            
            STALL_REQ: out std_logic;

            PC: in word_t;
            OP: in op_t;
            FUNCT: in funct_t;
            ALU_RESULT: in word_t;
            WRITE_ADDR: in reg_addr_t;
            WRITE_DATA: in word_t;
            WRITE_MEM_DATA: in word_t;
            
            PC_O: out word_t;
            OP_O: out op_t;
            FUNCT_O: out funct_t;
            WRITE_ADDR_O: out reg_addr_t;
            WRITE_DATA_O: out word_t;
            
            -- bus
            BUS_ADDR: out word_t;
            BUS_DATA_IN: in word_t;
            BUS_DATA_OUT: out word_t;
            BUS_BYTE_MASK: out std_logic_vector(3 downto 0);
            BUS_EN: out std_logic;
            BUS_nREAD_WRITE: out std_logic;
            BUS_DONE: in std_logic
        );
    end component;

    component mem_wb is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;

            MEM_PC: in word_t;
            MEM_OP: in op_t;
            MEM_FUNCT: in funct_t;
            MEM_WRITE_ADDR: in reg_addr_t;
            MEM_WRITE_DATA: in word_t;
            
            WB_PC: out word_t;
            WB_OP: out op_t;
            WB_FUNCT: out funct_t;
            WB_WRITE_ADDR: out reg_addr_t;
            WB_WRITE_DATA: out word_t
        );
    end component;

    component write_back is
        port
        (
            RST: in std_logic;

            PC: in word_t;
            OP: in op_t;
            FUNCT: in funct_t;
            WRITE_ADDR: in reg_addr_t;
            WRITE_DATA: in word_t;
            
            WRITE_ADDR_O: out reg_addr_t;
            WRITE_DATA_O: out word_t
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
    signal addr, data: word_t;
    
    signal reg_read_addr0: reg_addr_t;
    signal reg_read_data0: word_t;
    signal reg_read_addr1: reg_addr_t;
    signal reg_read_data1: word_t;
    
    signal if_stall_req: std_logic;
    signal id_stall_req: std_logic;
    signal ex_stall_req: std_logic;
    signal mem_stall_req: std_logic;
    signal stall: stall_t;
    
    signal if_pc, if_ins: word_t;
    
    signal id_pc, id_ins, id_pc_o: word_t;
    
    signal id_read_addr0: reg_addr_t;
    signal id_read_data0: word_t;
    signal id_read_addr1: reg_addr_t;
    signal id_read_data1: word_t;
    
    signal id_op: op_t;
    signal id_funct: funct_t;
    signal id_alu_op: alu_op_t;
    signal id_operand0: word_t;
    signal id_operand1: word_t;
    signal id_write_addr: reg_addr_t;
    signal id_write_mem_data: word_t;
    signal id_branch_en: std_logic;
    signal id_branch_pc: word_t;
    signal id_is_load: std_logic;
    
    signal ex_pc: word_t;
    signal ex_op: op_t;
    signal ex_funct: funct_t;
    signal ex_alu_op: alu_op_t;
    signal ex_operand0: word_t;
    signal ex_operand1: word_t;
    signal ex_write_addr: reg_addr_t;
    signal ex_write_mem_data: word_t;
    signal ex_is_load: std_logic;
    
    signal ex_pc_o: word_t;
    signal ex_op_o: op_t;
    signal ex_funct_o: funct_t;
    signal ex_alu_result: word_t;
    signal ex_write_addr_o: reg_addr_t;
    signal ex_write_data: word_t;
    signal ex_write_mem_data_o: word_t;

    signal mem_pc: word_t;
    signal mem_op: op_t;
    signal mem_funct: funct_t;
    signal mem_alu_result: word_t;
    signal mem_write_addr: reg_addr_t;
    signal mem_write_data: word_t;
    signal mem_write_mem_data: word_t;
    
    signal mem_pc_o: word_t;
    signal mem_op_o: op_t;
    signal mem_funct_o: funct_t;
    signal mem_write_addr_o: reg_addr_t;
    signal mem_write_data_o: word_t;
    
    signal bus_addr: word_t;
    signal bus_data_in: word_t;
    signal bus_data_out: word_t;
    signal bus_byte_mask: std_logic_vector(3 downto 0);
    signal bus_en: std_logic;
    signal bus_nread_write: std_logic;
    signal bus_done: std_logic;

    signal wb_pc: word_t;
    signal wb_op: op_t;
    signal wb_funct: funct_t;
    signal wb_write_addr: reg_addr_t;
    signal wb_write_data: word_t;
    
    signal wb_write_addr_o: reg_addr_t;
    signal wb_write_data_o: word_t;
begin
    RST <= not nRST;
    
    test0 <= wb_write_addr_o;
    test1 <= wb_write_data_o;
    
    ram_inst: ram
    port map
    (
        CLK => CLK,
    
        ADDR => addr,
        DATA => data
    );
    
    reg_file_inst: reg_file
    port map
    (
        CLK => CLK,
        RST => RST,
        
        READ_ADDR0 => reg_read_addr0,
        READ_DATA0 => reg_read_data0,
        READ_ADDR1 => reg_read_addr1,
        READ_DATA1 => reg_read_data1,
        WRITE_ADDR => wb_write_addr_o,
        WRITE_DATA => wb_write_data_o
    );
    
    reg_forward_inst: reg_forward
    port map
    (
        RST => RST,
        
        ID_READ_ADDR0 => id_read_addr0,
        ID_READ_DATA0 => id_read_data0,
        
        ID_READ_ADDR1 => id_read_addr1,
        ID_READ_DATA1 => id_read_data1,
        
        -- read from reg file
        REG_READ_ADDR0 => reg_read_addr0,
        REG_READ_DATA0 => reg_read_data0,
        
        REG_READ_ADDR1 => reg_read_addr1,
        REG_READ_DATA1 => reg_read_data1,
        
        -- ex
        EX_WRITE_EN => '1', -- TODO
        EX_WRITE_ADDR => ex_write_addr_o,
        EX_WRITE_DATA => ex_write_data,
        
        -- mem
        MEM_WRITE_EN => '1', -- TODO
        MEM_WRITE_ADDR => mem_write_addr_o,
        MEM_WRITE_DATA => mem_write_data_o,
        
        -- wb
        WB_WRITE_EN => '1', -- TODO
        WB_WRITE_ADDR => wb_write_addr_o,
        WB_WRITE_DATA => wb_write_data_o
    );
    
    controller_inst: controller
    port map
    (
        RST => RST,

        IF_STALL_REQ => if_stall_req,
        ID_STALL_REQ => id_stall_req,
        EX_STALL_REQ => ex_stall_req,
        MEM_STALL_REQ => mem_stall_req,
        
        STALL => stall
    );
    
    instruction_fetch_inst: instruction_fetch
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL_REQ => if_stall_req,
        STALL => stall,
        
        ADDR => addr,
        DATA => data,
        
        PC => if_pc,
        INS => if_ins,
        
        BRANCH_EN => id_branch_en,
        BRANCH_PC => id_branch_pc
    );
    
    if_id_inst: if_id
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,
        
        IF_PC => if_pc,
        IF_INS => if_ins,
        
        ID_PC => id_pc,
        ID_INS => id_ins
    );
    
    instruction_decode_inst: instruction_decode
    port map
    (
        RST => RST,
        
        STALL_REQ => id_stall_req,
        
        PC => id_pc,
        INS => id_ins,
        
        READ_ADDR0 => id_read_addr0,
        READ_DATA0 => id_read_data0,
        READ_ADDR1 => id_read_addr1,
        READ_DATA1 => id_read_data1,
        
        PC_O => id_pc_o,
        OP => id_op,
        FUNCT => id_funct,
        ALU_OP => id_alu_op,
        OPERAND0 => id_operand0,
        OPERAND1 => id_operand1,
        WRITE_ADDR => id_write_addr,
        WRITE_MEM_DATA => id_write_mem_data,
        IS_LOAD => id_is_load,
        
        EX_IS_LOAD => ex_is_load,
        EX_WRITE_ADDR => ex_write_addr,
		  
        BRANCH_EN => id_branch_en,
        BRANCH_PC => id_branch_pc
    );
    
    id_ex_inst: id_ex
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,

        ID_PC => id_pc_o,
        ID_OP => id_op,
        ID_FUNCT => id_funct,
        ID_ALU_OP => id_alu_op,
        ID_OPERAND0 => id_operand0,
        ID_OPERAND1 => id_operand1,
        ID_WRITE_ADDR => id_write_addr,
        ID_WRITE_MEM_DATA => id_write_mem_data,
        ID_IS_LOAD => id_is_load,
        
        EX_PC => ex_pc,
        EX_OP => ex_op,
        EX_FUNCT => ex_funct,
        EX_ALU_OP => ex_alu_op,
        EX_OPERAND0 => ex_operand0,
        EX_OPERAND1 => ex_operand1,
        EX_WRITE_ADDR => ex_write_addr,
        EX_WRITE_MEM_DATA => ex_write_mem_data,
        EX_IS_LOAD => ex_is_load
    );
    
    execute_inst: execute
    port map
    (
        RST => RST,
        
        STALL_REQ => ex_stall_req,

        PC => ex_pc,
        OP => ex_op,
        FUNCT => ex_funct,
        ALU_OP => ex_alu_op,
        OPERAND0 => ex_operand0,
        OPERAND1 => ex_operand1,
        WRITE_ADDR => ex_write_addr,
        WRITE_MEM_DATA => ex_write_mem_data,
        
        PC_O => ex_pc_o,
        OP_O => ex_op_o,
        FUNCT_O => ex_funct_o,
        ALU_RESULT => ex_alu_result,
        WRITE_ADDR_O => ex_write_addr_o,
        WRITE_DATA => ex_write_data,
        WRITE_MEM_DATA_O => ex_write_mem_data_o
    );
    
    ex_mem_inst: ex_mem
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,

        EX_PC => ex_pc_o,
        EX_OP => ex_op_o,
        EX_FUNCT => ex_funct_o,
        EX_ALU_RESULT => ex_alu_result,
        EX_WRITE_ADDR => ex_write_addr_o,
        EX_WRITE_DATA => ex_write_data,
        EX_WRITE_MEM_DATA => ex_write_mem_data_o,
        
        MEM_PC => mem_pc,
        MEM_OP => mem_op,
        MEM_FUNCT => mem_funct,
        MEM_ALU_RESULT => mem_alu_result,
        MEM_WRITE_ADDR => mem_write_addr,
        MEM_WRITE_DATA => mem_write_data,
        MEM_WRITE_MEM_DATA => mem_write_mem_data
    );
    
    memory_access_inst: memory_access
    port map
    (
        RST => RST,
        
        STALL_REQ => mem_stall_req,

        PC => mem_pc,
        OP => mem_op,
        FUNCT => mem_funct,
        ALU_RESULT => mem_alu_result,
        WRITE_ADDR => mem_write_addr,
        WRITE_DATA => mem_write_data,
        WRITE_MEM_DATA => mem_write_mem_data,
        
        PC_O => mem_pc_o,
        OP_O => mem_op_o,
        FUNCT_O => mem_funct_o,
        WRITE_ADDR_O => mem_write_addr_o,
        WRITE_DATA_O => mem_write_data_o,
        
        BUS_ADDR => bus_addr,
        BUS_DATA_IN => bus_data_in,
        BUS_DATA_OUT => bus_data_out,
        BUS_BYTE_MASK => bus_byte_mask,
        BUS_EN => bus_en,
        BUS_nREAD_WRITE => bus_nread_write,
        BUS_DONE => '1' -- TODO
    );
    
    mem_wb_inst: mem_wb
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,

        MEM_PC => mem_pc_o,
        MEM_OP => mem_op_o,
        MEM_FUNCT => mem_funct_o,
        MEM_WRITE_ADDR => mem_write_addr_o,
        MEM_WRITE_DATA => mem_write_data_o,
        
        WB_PC => wb_pc,
        WB_OP => wb_op,
        WB_FUNCT => wb_funct,
        WB_WRITE_ADDR => wb_write_addr,
        WB_WRITE_DATA => wb_write_data
    );
    
    write_back_inst: write_back
    port map
    (
        RST => RST,

        PC => wb_pc,
        OP => wb_op,
        FUNCT => wb_funct,
        WRITE_ADDR => wb_write_addr,
        WRITE_DATA => wb_write_data,
        
        WRITE_ADDR_O => wb_write_addr_o,
        WRITE_DATA_O => wb_write_data_o
    );
    
    memory_inst: memory
    port map
    (
        address => bus_addr(11 downto 2),
        byteena => bus_byte_mask,
        clock => not CLK,
        data => bus_data_out,
        wren => bus_nread_write,
        q => bus_data_in
    );
end;