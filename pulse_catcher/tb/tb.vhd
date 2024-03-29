library ieee;
   use ieee.std_logic_1164.all;

library simple;


entity tb_pulse_catcher is
end entity;


architecture test of tb_pulse_catcher is

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   constant C_WIDTH : positive := 7;
   constant C_ALL_0 : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');

   signal d : std_logic_vector(C_WIDTH - 1 downto 0);
   signal expected         : std_logic_vector(C_WIDTH - 1 downto 0);
   signal clear_mask       : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
   signal clear_stb        : std_logic                              := '0';
   signal catch_mask       : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
   signal q_mask           : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
   signal q_or_reduce_mask : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');

   signal q : std_logic_vector(C_WIDTH - 1 downto 0);
   signal q_or_reduced : std_logic;

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Pulse_Catcher
   generic map (
      WIDTH => C_WIDTH
   )
   port map (
      clk_i              => clk,
      d_i                => d,
      clear_mask_i       => clear_mask,
      clear_stb_i        => clear_stb,
      catch_mask_i       => catch_mask,
      q_mask_i           => q_mask,
      q_or_reduce_mask_i => q_or_reduce_mask,
      q_o                => q,
      q_or_reduced_o     => q_or_reduced
   );


   main : process is
   begin
      wait for C_CLK_PERIOD;
      d <= "0000101";
      wait for 2 * C_CLK_PERIOD;
      assert q = C_ALL_0 report "Pulse catched while catch_mask is (others => '0')" severity failure;
      assert q_or_reduced = '0' report "q_or_reduced_o = '1' while catch_mask is (others => '0')" severity failure;


      catch_mask <= (others => '1');
      wait for C_CLK_PERIOD;
      assert q = C_ALL_0 report "Pulse catched while q_mask is (others => '0')" severity failure;
      assert q_or_reduced = '0' report "q_or_reduced_o = '1' while q_or_reduce_mask is (others => '0')" severity failure;
      q_mask <= (others => '1');
      wait for C_CLK_PERIOD;
      assert q = d report "q /= d after setting q_mask to (others => '1')" severity failure;
      q_or_reduce_mask <= (others => '1');
      wait for C_CLK_PERIOD;
      assert q_or_reduced = '1' report "q /= '1' after setting q_or_reduce_mask to (others => '1')" severity failure;


      clear_mask <= d;
      clear_stb <= '1';
      d <= (others => '0');
      wait for C_CLK_PERIOD;
      clear_stb <= '0';
      wait for C_CLK_PERIOD;
      assert q = C_ALL_0 report "q not cleared after clear_stb" severity failure;
      assert q_or_reduced = '0' report "q_or_reduced not cleared after clear_stb" severity failure;


      d <= "1101000";
      q_or_reduce_mask <= "0010111";
      wait for C_CLK_PERIOD;
      expected <= d;
      d <= (others => '0');
      wait for 2 * C_CLK_PERIOD;
      assert q = expected report "q /= expected" severity failure;
      assert q_or_reduced = '0' report "q_or_reduced /= '0' after masking" severity failure;
      q_or_reduce_mask <= not q_or_reduce_mask;
      wait for C_CLK_PERIOD;
      assert q_or_reduced = '1' report "q_or_reduced /= '1' after unmasking" severity failure;


      wait for 2 * C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
