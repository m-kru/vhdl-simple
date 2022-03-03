library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

library simple;


entity tb is
end entity;


architecture test of tb is

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   constant C_TEST_PULSE_WIDTH : positive := 3;

   constant C_MAX_PULSE_WIDTH : positive := 14;
   constant C_WIDTH : positive := integer(ceil(log2(real(C_MAX_PULSE_WIDTH))));

   signal width : unsigned(C_WIDTH - 1 downto 0) := (others => '0');
   signal stb   : std_logic := '0';
   signal q     : std_logic;

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Dynamic_Pulse_Generator
   generic map (
      MAX_PULSE_WIDTH => C_MAX_PULSE_WIDTH
   )
   port map (
      clk_i   => clk,
      width_i => width,
      stb_i   => stb,
      q_o     => q
   );



   main : process is
   begin
      wait for C_CLK_PERIOD;

      width <= to_unsigned(C_TEST_PULSE_WIDTH, C_WIDTH);
      stb <= '1';
      wait for C_CLK_PERIOD;
      stb <= '0';

      for i in 0 to C_TEST_PULSE_WIDTH - 1 loop
         assert q = '1' report "Output pulse is too short" severity failure;
         wait for C_CLK_PERIOD;
      end loop;

      assert q = '0' report "Output pulse is too long" severity failure;


      -- Test behavior when width is 0
      width <= to_unsigned(0, C_WIDTH);
      stb <= '1';
      wait for C_CLK_PERIOD;
      stb <= '0';
      assert q = '0' report "Output high after width = 0" severity failure;
      wait for C_CLK_PERIOD;
      assert q = '0' report "Output high after width = 0" severity failure;

      wait for 10 * C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
