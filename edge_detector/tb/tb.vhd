library ieee;
   use ieee.std_logic_1164.all;

library simple;

entity tb_edge_detector is
end entity;

architecture test of tb_edge_detector is

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal data : std_logic;

   signal edge    : std_logic;
   signal rising  : std_logic;
   signal falling : std_logic;

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Edge_Detector
   generic map (
      WIDTH => 1
   )
   port map (
      clk_i  => clk,
      d_i(0) => data,
      e_o(0) => edge,
      r_o(0) => rising,
      f_o(0) => falling
   );


   main : process is
   begin
      wait for C_CLK_PERIOD;
      data <= '0';
      wait for 3 * C_CLK_PERIOD;
      data <= '1';
      wait for C_CLK_PERIOD;
      assert edge = '1' report "Transition not detected" severity failure;
      assert rising = '1' report "0 -> 1 not detected" severity failure;

      data <= '0';
      wait for C_CLK_PERIOD;
      assert edge = '1' report "Transition not detected" severity failure;
      assert falling = '1' report "1 -> 0 not detected" severity failure;

      wait for 3 * C_CLK_PERIOD;
      data <= '1';
      wait for C_CLK_PERIOD;
      assert edge = '1' report "Transition not detected" severity failure;
      assert rising = '1' report "0 -> 1 not detected" severity failure;


      wait for C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
