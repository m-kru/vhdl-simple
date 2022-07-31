library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

library simple;


entity tb_binary_counter_down_counting is
end entity;


architecture test of tb_binary_counter_down_counting is

   constant C_MAX_VALUE : positive := 13;
   constant C_WIDTH : positive := integer(ceil(log2(real(C_MAX_VALUE))));

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal d, q, q_prev : unsigned(C_WIDTH - 1 downto 0);
   signal stb  : std_logic := '0';
   signal min, max : std_logic;

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Binary_Counter
   generic map (
      COUNTER_MAX_VALUE => C_MAX_VALUE
   )
   port map (
      clk_i  => clk,
      d_i    => d,
      stb_i  => stb,
      down_i => '1',
      q_o    => q,
      min_o  => min,
      max_o  => max
   );


   reloader : process is
   begin
      d <= to_unsigned(C_MAX_VALUE, C_WIDTH);
      loop
         wait for C_CLK_PERIOD;
         stb <= '1';
         wait for C_CLK_PERIOD;
         stb <= '0';
         wait for (C_MAX_VALUE + 1) * C_CLK_PERIOD;
      end loop;
   end process;


   main : process is
   begin
      wait for 3 * C_MAX_VALUE * C_CLK_PERIOD;
      std.env.finish;
   end process;


   -- Asert min is '1' when q = 0
   min_assert : process (clk) is
   begin
      if rising_edge(clk) then
         q_prev <= q;
         assert (min = '1' and q_prev = 1 and q = 0) or (min = '0' and q_prev /= 1)
            report "min = " & to_string(min) & ", q = " & to_string(q)
            severity failure;
      end if;
   end process;


   -- Assert max is always '0'.
   max_assert : process (clk) is
   begin
      if rising_edge(clk) then
         assert max = '0' report "max = '1'" severity failure;
      end if;
   end process;

end architecture;
