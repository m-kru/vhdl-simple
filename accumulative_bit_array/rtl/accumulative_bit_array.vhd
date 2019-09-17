library ieee;
use ieee.std_logic_1164.all;

entity accumulative_bit_array is
  generic (
    G_WIDTH : positive := 32
  );
  port (
    clk_i          : in std_logic;
    rst_i          : in std_logic;
    write_enable_i : in std_logic := '1';
    d_i            : in  std_logic_vector(G_WIDTH-1 downto 0);
    q_o            : out std_logic_vector(G_WIDTH-1 downto 0)
  );
end accumulative_bit_array;

architecture rtl of accumulative_bit_array is
    
  signal q_r : std_logic_vector(G_WIDTH-1 downto 0);

begin

  q_o <= q_r;
  
  process (clk_i)
  begin
    if (rising_edge(clk_i)) then
      if rst_i = '1' then
        q_r   <= (others => '0');
      elsif write_enable_i = '1' then
        
        for_each_bit : for i in 0 to G_WIDTH-1 loop
          if q_r(i) = '0' then
            q_r(i) <= d_i(i);
          end if;
        end loop;
        
      end if;
    end if;
  end process;

end  rtl;
