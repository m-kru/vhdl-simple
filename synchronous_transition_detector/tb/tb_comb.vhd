library ieee;
   use ieee.std_logic_1164.all;

library simple;

entity tb_comb is
end entity;

architecture test of tb_comb is
   constant C_WIDTH : positive := 2;

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal data : std_logic_vector(C_WIDTH - 1 downto 0);

   signal transition  : std_logic_vector(C_WIDTH - 1 downto 0);
   signal zero_to_one : std_logic_vector(C_WIDTH - 1 downto 0);
   signal one_to_zero : std_logic_vector(C_WIDTH - 1 downto 0);

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.synchronous_transition_detector
   generic map (
      WIDTH => C_WIDTH,
      REGISTER_OUTPUTS => false
   )
   port map (
      clk_i         => clk,
      d_i           => data,
      transition_o  => transition,
      zero_to_one_o => zero_to_one,
      one_to_zero_o => one_to_zero
   );


   main : process is
   begin
      wait for C_CLK_PERIOD;
      data <= "00";
      wait for 3 * C_CLK_PERIOD;
      data <= "11";
      wait for C_CLK_PERIOD / 10;
      assert transition = "11" report "Transition not detected" severity failure;
      assert zero_to_one = "11" report "0 -> 1 not detected" severity failure;
      wait for 3 * C_CLK_PERIOD;

      data <= "01";
      wait for C_CLK_PERIOD / 10;
      assert transition = "10" report "Transition not detected" severity failure;
      assert one_to_zero = "10" report "0 -> 1 not detected" severity failure;

      wait for 2*C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
