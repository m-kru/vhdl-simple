library ieee;
   use ieee.std_logic_1164.all;

library simple;


entity tb is
end entity;


architecture test of tb is

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   constant C_WIDTH  : positive := 1;
   constant C_EXTEND : positive := 3;

   signal en : std_logic := '1';
   signal d : std_logic := '0';
   signal q : std_logic;
begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Synchronous_Pulse_Extender
   generic map (
      G_WIDTH  => C_WIDTH,
      G_EXTEND => C_EXTEND
   )
   port map (
      clk_i        => clk,
      en_mask_i(0) => en,
      d_i(0)       => d,
      q_o(0)       => q
   );


   main : process is
   begin
      wait for C_CLK_PERIOD;
      d <= '1';
      wait for C_CLK_PERIOD;
      d <= '0';

      for i in C_EXTEND downto 0 loop
         assert q = '1' report "q asserted for too short" severity failure;
         wait for C_CLK_PERIOD;
      end loop;
      assert q = '0' report "q asserted for too long" severity failure;

      -- Verify enable functionality.
      en <= '0';
      wait for C_CLK_PERIOD;
      d <= '1';
      wait for C_CLK_PERIOD;
      d <= '0';
      assert q = '1' report "q should be asserted for the same time as d" severity failure;
      wait for C_CLK_PERIOD;
      assert q = '0' report "q asserted for too long when functionality is disabled" severity failure;

      -- Verify filtering functionality.
      en <= '1';
      d <= '1';
      wait for C_CLK_PERIOD;
      assert q = '1' report "q should be asserted" severity failure;
      d <= '0';
      for i in C_EXTEND - 1 downto 0 loop
         wait for C_CLK_PERIOD;
         assert q = '1' report "q should be asserted" severity failure;
      end loop;
      d <= '1';
      assert q = '1' report "q should be asserted" severity failure;

      wait for 5 * C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
