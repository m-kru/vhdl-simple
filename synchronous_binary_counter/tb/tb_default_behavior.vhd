library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

library simple;


entity tb is
end entity;


architecture test of tb is

   constant C_MAX_VALUE : positive := 11;
   constant C_WIDTH : positive := integer(ceil(log2(real(C_MAX_VALUE))));

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal d, q : unsigned(C_WIDTH - 1 downto 0);
   signal stb  : std_logic := '0';
   signal min, max : std_logic;

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Synchronous_Binary_Counter
   generic map (
      COUNTER_MAX_VALUE => C_MAX_VALUE
   )
   port map (
      clk_i => clk,
      d_i   => d,
      stb_i => stb,
      q_o   => q,
      min_o => min,
      max_o => max
   );


   main : process is

   begin
      wait for C_CLK_PERIOD;
      d <= to_unsigned(0, C_WIDTH);
      stb <= '1';
      wait for C_CLK_PERIOD;
      stb <= '0';

      for i in 0 to C_MAX_VALUE - 2 loop
         wait for C_CLK_PERIOD;
         assert max = '0'
            report "max = " & to_string(max) & ", expected '0'"
            severity failure;
      end loop;

      wait for C_CLK_PERIOD;
      assert max = '1'
         report "max = " & to_string(max) & ", expected '1'"
         severity failure;

      wait for C_CLK_PERIOD;
      assert max = '0'
         report "max = " & to_string(max) & ", expected '0'"
         severity failure;

      wait for 3 * C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
