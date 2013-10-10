library verilog;
use verilog.vl_types.all;
entity alu is
    port(
        A               : in     vl_logic_vector(15 downto 0);
        B               : in     vl_logic_vector(15 downto 0);
        op              : in     vl_logic_vector(2 downto 0);
        imm             : in     vl_logic_vector(3 downto 0);
        \Out\           : out    vl_logic_vector(15 downto 0)
    );
end alu;
